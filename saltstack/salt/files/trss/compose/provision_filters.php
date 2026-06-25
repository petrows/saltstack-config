#!/usr/bin/env php
<?php
/*
 * provision_filters.php
 *
 * Declaratively provisions TT-RSS labels + filters from a YAML file.
 * The config is the single source of truth ("hard provision"):
 *
 *   - labels referenced in the config are auto-created if missing
 *   - one filter per config object is created:
 *       * match_any_rule = true
 *       * one "title" rule per `match` entry (regex, applies to ALL feeds)
 *       * one "assign label" action per `labels` entry
 *       * filter title = the YAML object key (e.g. "filter-1")
 *   - EVERY other filter belonging to the user is DELETED
 *
 * It never deletes labels, and never touches article<->label assignments
 * (those live in ttrss_user_labels2 and survive filter deletion).
 *
 * Config format:
 *
 *   user: 5
 *   filters:
 *     filter-1:
 *       match:
 *         - texta
 *         - textb
 *       labels:
 *         - textl
 *         - textw
 *
 * Usage (inside the container, as the 'app' user):
 *   php provision_filters.php config.yml --dry-run
 *   php provision_filters.php config.yml
 *   php provision_filters.php config.yml --user=5   # override config 'user'
 *
 * Set TTRSS_ROOT if your install isn't at the default supahgreg path.
 */

define('DISABLE_SESSIONS', true);

$root = getenv('TTRSS_ROOT') ?: '/var/www/html/tt-rss';
chdir($root);
require_once $root . '/include/autoload.php';

Config::sanity_check();

if (php_sapi_name() != 'cli') {
    fwrite(STDERR, "Run this from the CLI.\n");
    exit(1);
}

/* ---- filter/action type constants (from ttrss_filter_types / _actions seed) ---- */
const FILTER_TYPE_TITLE  = 1;
const FILTER_ACTION_LABEL = 7;

/* ---------------------------- args ---------------------------- */
$config_path = null;
$dry_run     = false;
$user_override = null;
foreach (array_slice($argv, 1) as $a) {
    if ($a === '--dry-run')                              $dry_run = true;
    elseif (preg_match('/^--user=(\d+)$/', $a, $m))      $user_override = (int)$m[1];
    elseif ($a[0] !== '-' && $config_path === null)      $config_path = $a;
}
if ($config_path === null || !is_readable($config_path)) {
    fwrite(STDERR, "Usage: php provision_filters.php <config.yml> [--dry-run] [--user=N]\n");
    exit(1);
}

/* ----------------------- YAML loading ------------------------- */
/* Prefer the libyaml extension; fall back to a small block-style parser
 * that covers exactly this schema (mappings + scalar sequences). */
function load_config(string $path): array {
    $raw = file_get_contents($path);
    if ($raw === false) throw new RuntimeException("cannot read $path");

    if (extension_loaded('yaml')) {
        $data = @yaml_parse($raw);
        if (!is_array($data)) throw new RuntimeException("YAML parse failed (libyaml)");
        return $data;
    }
    return parse_yaml_subset($raw);
}

/* Minimal indentation-aware block YAML parser (maps + scalar sequences). */
function parse_yaml_subset(string $text): array {
    $tokens = [];
    foreach (preg_split('/\R/', $text) as $line) {
        if (str_contains($line, "\t"))
            throw new RuntimeException("tabs are not allowed in YAML indentation");
        $no_comment = preg_replace('/(?:^|\s)#.*$/', '', $line); // strip full-line + inline comments
        if (trim((string)$no_comment) === '') continue;
        $indent = strlen($no_comment) - strlen(ltrim($no_comment, ' '));
        $tokens[] = ['indent' => $indent, 'text' => trim($no_comment)];
    }
    $i = 0;
    return yaml_parse_block($tokens, $i, -1);
}

function yaml_scalar(string $v) {
    $v = trim($v);
    if ($v === '' )            return '';
    if ($v === '~' || strtolower($v) === 'null') return null;
    if (preg_match('/^-?\d+$/', $v)) return (int)$v;
    if (in_array(strtolower($v), ['true','false'], true)) return strtolower($v) === 'true';
    if ((str_starts_with($v, '"') && str_ends_with($v, '"')) ||
        (str_starts_with($v, "'") && str_ends_with($v, "'")))
        return substr($v, 1, -1);
    return $v;
}

function yaml_parse_block(array $tokens, int &$i, int $parent_indent) {
    // peek
    if ($i >= count($tokens)) return [];
    $cur_indent = $tokens[$i]['indent'];

    if (str_starts_with($tokens[$i]['text'], '- ')) {
        // sequence
        $seq = [];
        while ($i < count($tokens) && $tokens[$i]['indent'] === $cur_indent
               && str_starts_with($tokens[$i]['text'], '- ')) {
            $seq[] = yaml_scalar(substr($tokens[$i]['text'], 2));
            $i++;
        }
        return $seq;
    }

    // mapping
    $map = [];
    while ($i < count($tokens) && $tokens[$i]['indent'] === $cur_indent
           && !str_starts_with($tokens[$i]['text'], '- ')) {
        $t = $tokens[$i]['text'];
        $colon = strpos($t, ':');
        if ($colon === false) throw new RuntimeException("malformed YAML line: '$t'");
        $key = trim(substr($t, 0, $colon));
        $inline = trim(substr($t, $colon + 1));
        $i++;
        if ($inline !== '') {
            $map[$key] = yaml_scalar($inline);
        } else {
            // nested block belongs to this key if next token is deeper
            if ($i < count($tokens) && $tokens[$i]['indent'] > $cur_indent) {
                $map[$key] = yaml_parse_block($tokens, $i, $cur_indent);
            } else {
                $map[$key] = null;
            }
        }
    }
    return $map;
}

/* ----------------------- validation --------------------------- */
$cfg = load_config($config_path);

$owner_uid = $user_override ?? (isset($cfg['user']) ? (int)$cfg['user'] : 0);
if ($owner_uid <= 0)
    { fwrite(STDERR, "config 'user' (owner_uid) is missing or invalid\n"); exit(1); }

if (empty($cfg['filters']) || !is_array($cfg['filters']))
    { fwrite(STDERR, "config 'filters' is missing or empty\n"); exit(1); }

$pdo = Db::pdo();

// sanity: does the user exist?
$usth = $pdo->prepare("SELECT login FROM ttrss_users WHERE id = ?");
$usth->execute([$owner_uid]);
$urow = $usth->fetch(PDO::FETCH_ASSOC);
if (!$urow) { fwrite(STDERR, "no user with id $owner_uid in ttrss_users\n"); exit(1); }

// normalise + validate every filter definition up front
$desired = [];        // title => ['match'=>[...], 'labels'=>[...]]
$all_labels = [];
foreach ($cfg['filters'] as $name => $def) {
    $title = (string)$name;
    if (!is_array($def))             throw new RuntimeException("filter '$title' is not a mapping");
    $match  = $def['match']  ?? null;
    $labels = $def['labels'] ?? null;
    if (!is_array($match)  || !$match)  throw new RuntimeException("filter '$title': 'match' must be a non-empty list");
    if (!is_array($labels) || !$labels) throw new RuntimeException("filter '$title': 'labels' must be a non-empty list");
    $match  = array_values(array_map('strval', $match));
    $labels = array_values(array_map('strval', $labels));
    $desired[$title] = ['match' => $match, 'labels' => $labels];
    foreach ($labels as $l) $all_labels[$l] = true;
}
$all_labels = array_keys($all_labels);

/* ----------------- report what's going to change -------------- */
$esth = $pdo->prepare("SELECT id, title FROM ttrss_filters2 WHERE owner_uid = ? ORDER BY id");
$esth->execute([$owner_uid]);
$existing = $esth->fetchAll(PDO::FETCH_ASSOC);

printf("User: %s (uid %d)\n", $urow['login'], $owner_uid);
printf("Labels referenced: %s\n", implode(', ', $all_labels));
printf("Filters to provision (%d): %s\n", count($desired), implode(', ', array_keys($desired)));
printf("Existing filters to be REMOVED (%d): %s\n",
    count($existing), implode(', ', array_map(fn($r) => "{$r['title']}#{$r['id']}", $existing)) ?: '(none)');

if ($dry_run) {
    echo "\n[DRY RUN] no changes written.\n";
    foreach ($desired as $title => $d) {
        printf("  filter '%s': match_any(title) [%s] -> labels [%s]\n",
            $title, implode(' | ', $d['match']), implode(', ', $d['labels']));
    }
    exit(0);
}

/* ----------------------- apply changes ------------------------ */
$pdo->beginTransaction();
try {
    // 1) auto-create missing labels (idempotent)
    $labels_created = 0;
    foreach ($all_labels as $caption) {
        if (Labels::create($caption, '', '', $owner_uid) !== false) $labels_created++;
    }

    // 2) hard provision: wipe ALL existing filters for this user
    //    (FK ON DELETE CASCADE removes their rules + actions)
    $dsth = $pdo->prepare("DELETE FROM ttrss_filters2 WHERE owner_uid = ?");
    $dsth->execute([$owner_uid]);
    $filters_removed = $dsth->rowCount();

    // 3) recreate desired filters
    $ins_filter = $pdo->prepare(
        "INSERT INTO ttrss_filters2 (owner_uid, match_any_rule, enabled, title, inverse)
         VALUES (?, ?, ?, ?, ?) RETURNING id");
    $ins_rule = $pdo->prepare(
        "INSERT INTO ttrss_filters2_rules (filter_id, reg_exp, filter_type, feed_id, cat_id, match_on, inverse)
         VALUES (?, ?, ?, NULL, NULL, ?, ?)");
    $ins_action = $pdo->prepare(
        "INSERT INTO ttrss_filters2_actions (filter_id, action_id, action_param)
         VALUES (?, ?, ?)");

    $match_on_all_feeds = json_encode([0]); // "[0]" == apply to all feeds/cats

    $filters_created = 0; $rules_created = 0; $actions_created = 0;
    foreach ($desired as $title => $d) {
        // match_any_rule=1, enabled=1, inverse=0  (booleans as int, like TT-RSS)
        $ins_filter->execute([$owner_uid, 1, 1, $title, 0]);
        $frow = $ins_filter->fetch(PDO::FETCH_ASSOC);
        $filter_id = (int)$frow['id'];
        $filters_created++;

        foreach ($d['match'] as $reg_exp) {
            $ins_rule->execute([$filter_id, ".*$reg_exp.*", FILTER_TYPE_TITLE, $match_on_all_feeds, 0]);
            $rules_created++;
        }
        foreach ($d['labels'] as $caption) {
            $ins_action->execute([$filter_id, FILTER_ACTION_LABEL, $caption]);
            $actions_created++;
        }
    }

    $pdo->commit();

    printf("\nDone. Labels created: %d. Filters removed: %d. Filters created: %d (rules: %d, label actions: %d).\n",
        $labels_created, $filters_removed, $filters_created, $rules_created, $actions_created);

} catch (Throwable $e) {
    $pdo->rollBack();
    fwrite(STDERR, "ROLLED BACK — no changes written. Error: " . $e->getMessage() . "\n");
    exit(1);
}
