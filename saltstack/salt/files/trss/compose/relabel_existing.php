#!/usr/bin/env php
<?php
/*
 * relabel_existing.php
 *
 * Retroactively applies *label* filter actions to already-imported articles,
 * reusing TT-RSS's own filter engine so behaviour matches the import path
 * exactly (rule matching, category inheritance, match_any_rule, inverse, stop).
 *
 * It ONLY assigns labels. It never deletes, marks read, scores, or unsubscribes.
 * Labels::add_article() is idempotent, so this script is safe to re-run.
 *
 * Docker compose:
 *
 *   docker compose exec -u app app php /opt/tt-rss/relabel_existing.php
 *
 * Usage (inside the container, as the 'app' user):
 *   php relabel_existing.php --dry-run            # show what would happen
 *   php relabel_existing.php                      # apply to all feeds
 *   php relabel_existing.php --feed=42            # limit to one feed
 *   php relabel_existing.php --user=1             # limit to one owner_uid
 *
 * The script can live anywhere; set TTRSS_ROOT if your install isn't at the
 * default supahgreg path.
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

$dry_run   = in_array('--dry-run', $argv, true);
$only_feed = null;
$only_user = null;
foreach ($argv as $a) {
    if (preg_match('/^--feed=(\d+)$/', $a, $m)) $only_feed = (int)$m[1];
    if (preg_match('/^--user=(\d+)$/', $a, $m)) $only_user = (int)$m[1];
}

$pdo = Db::pdo();

$feed_sql = "SELECT id, owner_uid, title FROM ttrss_feeds";
$where = [];
$params = [];
if ($only_feed !== null) { $where[] = "id = ?";        $params[] = $only_feed; }
if ($only_user !== null) { $where[] = "owner_uid = ?"; $params[] = $only_user; }
if ($where) $feed_sql .= " WHERE " . implode(" AND ", $where);
$feed_sql .= " ORDER BY owner_uid, id";

$fsth = $pdo->prepare($feed_sql);
$fsth->execute($params);
$feeds = $fsth->fetchAll(PDO::FETCH_ASSOC);

$scanned = 0;
$assigned = 0;
$feeds_with_filters = 0;
$started = microtime(true);

foreach ($feeds as $feed) {
    $feed_id   = (int)$feed['id'];
    $owner_uid = (int)$feed['owner_uid'];

    $filters = RSSUtils::load_filters($feed_id, $owner_uid);
    if (!$filters) continue;

    // Skip feeds whose applicable filters define no label actions at all.
    $has_label_action = false;
    foreach ($filters as $f) {
        foreach (($f['actions'] ?? []) as $act) {
            if (($act['type'] ?? '') === 'label') { $has_label_action = true; break 2; }
        }
    }
    if (!$has_label_action) continue;
    $feeds_with_filters++;

    fwrite(STDERR, sprintf("feed %d (%s) [uid %d] ... ", $feed_id, $feed['title'], $owner_uid));

    $asth = $pdo->prepare(
        "SELECT e.id AS ref_id, e.title, e.content, e.link, e.author, ue.tag_cache
           FROM ttrss_entries e
           JOIN ttrss_user_entries ue ON ue.ref_id = e.id
          WHERE ue.feed_id = ? AND ue.owner_uid = ?");
    $asth->execute([$feed_id, $owner_uid]);

    $feed_scanned = 0;
    $feed_assigned = 0;

    while ($row = $asth->fetch(PDO::FETCH_ASSOC)) {
        $scanned++;
        $feed_scanned++;

        $tags = array_values(array_filter(array_map('trim',
            explode(',', (string)$row['tag_cache']))));

        $actions = RSSUtils::eval_article_filters(
            $filters,
            (string)$row['title'],
            (string)$row['content'],
            (string)$row['link'],
            (string)$row['author'],
            $tags
        );

        $label_actions = RSSUtils::find_article_filter_actions($actions, 'label');
        if (!$label_actions) continue;

        if ($dry_run) {
            foreach ($label_actions as $la) {
                printf("[dry] ref_id=%d  label=%s\n", (int)$row['ref_id'], $la['param']);
                $assigned++; $feed_assigned++;
            }
        } else {
            // Reuses the exact import-time helper; [] = let add_article() dedup.
            $before = $assigned;
            RSSUtils::assign_article_to_label_filters(
                (int)$row['ref_id'], $label_actions, $owner_uid, []);
            // count intended assignments (add_article is idempotent)
            $assigned += count($label_actions);
            $feed_assigned += count($label_actions);
        }
    }

    fwrite(STDERR, sprintf("%d scanned, %d label hits\n", $feed_scanned, $feed_assigned));
}

printf(
    "\nDone%s. Feeds with label filters: %d. Articles scanned: %d. Label assignments: %d. (%.1fs)\n",
    $dry_run ? " (DRY RUN — nothing written)" : "",
    $feeds_with_filters, $scanned, $assigned, microtime(true) - $started
);
