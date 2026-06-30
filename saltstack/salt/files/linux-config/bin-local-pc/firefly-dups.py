#!/usr/bin/env python3
"""
ff-dupes.py — find likely duplicate transactions in Firefly III within a period.

Config (env vars or flags):
  FIREFLY_URL    e.g. https://firefly.example.com     (or --url)
  FIREFLY_TOKEN  Personal Access Token                (or --token)

What counts as a duplicate is controlled by --match:
  amount-date       same currency + amount + date   (default; catches double-imports)
  amount-date-desc  also the same description        (stricter)
  amount-desc       same amount + description, any date
  amount            same currency + amount, any date (loosest; noisy for recurring bills)

Comparison is scoped per account via --account:
  both          same source AND destination account (default; true double-entry)
  source        same source account only (e.g. one asset account charged twice)
  destination   same destination account only
  off           ignore accounts entirely

Usage:
  ./ff-dupes.py                                 # current year, default match
  ./ff-dupes.py --year 2025
  ./ff-dupes.py --year 2025 --match amount-date-desc
  ./ff-dupes.py -f 2025-01-01 -t 2025-06-30 -q freenet
  ./ff-dupes.py --year 2025 --clip              # copy flagged dupes (TSV) for Sheets
  ./ff-dupes.py --year 2025 --format csv > dupes.csv

Notes:
  * --year YYYY covers the whole year; otherwise any omitted bound defaults to
    the start/end of the CURRENT year (no interactive prompt).
  * -q narrows by description first (e.g. only look for dupes among 'freenet').
  * Amounts are compared at cent precision, per currency, sign included.
"""

import argparse
import csv
import datetime as dt
import json
import os
import shutil
import ssl
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request
from collections import defaultdict


def iso(d):
    return d.strftime("%Y-%m-%d")


def parse_date(s):
    return dt.datetime.strptime(s.strip(), "%Y-%m-%d").date()


def build_query(text, dfrom, dto):
    after = iso(dfrom - dt.timedelta(days=1))
    before = iso(dto + dt.timedelta(days=1))
    parts = []
    if text:
        parts.append(text)
    parts.append(f"date_after:{after}")
    parts.append(f"date_before:{before}")
    return " ".join(parts)


def resolve_dates(year, dfrom, dto, today=None):
    today = today or dt.date.today()
    if year is not None:
        if dfrom or dto:
            raise ValueError("Use either --year or -f/-t, not both.")
        return dt.date(year, 1, 1), dt.date(year, 12, 31)
    d_from = parse_date(dfrom) if dfrom else dt.date(today.year, 1, 1)
    d_to = parse_date(dto) if dto else dt.date(today.year, 12, 31)
    if d_from > d_to:
        raise ValueError(f"'from' ({d_from}) is after 'to' ({d_to}).")
    return d_from, d_to


def fetch_all(base_url, token, query, insecure=False, limit=50):
    ctx = ssl.create_default_context()
    if insecure:
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE

    endpoint = base_url.rstrip("/") + "/api/v1/search/transactions"
    page = 1
    rows = []
    while True:
        params = urllib.parse.urlencode({"query": query, "limit": limit, "page": page})
        req = urllib.request.Request(
            f"{endpoint}?{params}",
            headers={"Authorization": f"Bearer {token}", "Accept": "application/json"},
        )
        with urllib.request.urlopen(req, context=ctx) as resp:
            payload = json.load(resp)

        for group in payload.get("data", []):
            for tx in group["attributes"]["transactions"]:
                rows.append(tx)

        pag = payload.get("meta", {}).get("pagination", {})
        if page >= pag.get("total_pages", 1):
            break
        page += 1
    return rows


def row_fields(tx):
    return {
        "id": tx.get("transaction_journal_id") or tx.get("journal_id") or "",
        "date": (tx.get("date") or "")[:10],
        "type": tx.get("type") or "",
        "description": tx.get("description") or "",
        "category": tx.get("category_name") or "",
        "source": tx.get("source_name") or "",
        "destination": tx.get("destination_name") or "",
        "amount": float(tx.get("amount") or 0),
        "currency": tx.get("currency_code") or "",
    }


def dup_key(r, match, account="both"):
    amt = f'{r["amount"]:.2f}'
    cur = r["currency"]
    desc = r["description"].strip().lower()
    if match == "amount":
        key = [cur, amt]
    elif match == "amount-desc":
        key = [cur, amt, desc]
    elif match == "amount-date-desc":
        key = [cur, amt, r["date"], desc]
    else:  # amount-date (default)
        key = [cur, amt, r["date"]]
    if account in ("source", "both"):
        key.append(r["source"])
    if account in ("destination", "both"):
        key.append(r["destination"])
    return tuple(key)


def find_duplicates(rows, match, account="both"):
    """Return groups (lists of row_fields dicts) that share a key, count >= 2."""
    buckets = defaultdict(list)
    for tx in rows:
        r = row_fields(tx)
        buckets[dup_key(r, match, account)].append(r)
    groups = [g for g in buckets.values() if len(g) >= 2]
    # Sort groups by first date then amount, transactions within a group by date.
    for g in groups:
        g.sort(key=lambda r: (r["date"], r["id"]))
    groups.sort(key=lambda g: (g[0]["date"], abs(g[0]["amount"])))
    return groups


def truncate(s, n):
    s = s or ""
    return s if len(s) <= n else s[: n - 1] + "\u2026"


def fmt_amount(v, cur):
    return f"{v:,.2f} {cur}".strip()


def print_groups(groups, match):
    if not groups:
        print("No duplicate transactions found for this period/criteria.")
        return

    cols = [
        ("Date", "date", "l"),
        ("Description", "description", "l"),
        ("Category", "category", "l"),
        ("From \u2192 To", "route", "l"),
        ("Amount", "amount_str", "r"),
    ]

    def disp(r):
        return {
            "date": r["date"],
            "description": truncate(r["description"], 32),
            "category": truncate(r["category"], 16),
            "route": truncate(f'{r["source"]} \u2192 {r["destination"]}', 32),
            "amount_str": fmt_amount(r["amount"], r["currency"]),
        }

    widths = {k: len(h) for h, k, _ in cols}
    for g in groups:
        for r in g:
            d = disp(r)
            for _, k, _ in cols:
                widths[k] = max(widths[k], len(d[k]))

    def render(d):
        return "  ".join(
            d[k].rjust(widths[k]) if a == "r" else d[k].ljust(widths[k])
            for _, k, a in cols
        )

    total_tx = 0
    for gi, g in enumerate(groups, 1):
        head = f"\u2500\u2500 group {gi}: {g[0]['amount']:.2f} {g[0]['currency']} \u00d7{len(g)}"
        if "date" in match:
            head += f"  on {g[0]['date']}"
        print(head)
        for r in g:
            print("   " + render(disp(r)))
            total_tx += 1
        print()

    print(f"{len(groups)} duplicate group(s), {total_tx} transactions involved.")


DUP_HEADERS = ["group", "date", "type", "description", "category",
               "source", "destination", "amount", "currency"]


def dup_cells(gi, r):
    return [
        str(gi), r["date"], r["type"], r["description"], r["category"],
        r["source"], r["destination"], f'{r["amount"]:.2f}', r["currency"],
    ]


def write_csv(groups, fh):
    w = csv.writer(fh)
    w.writerow(DUP_HEADERS)
    for gi, g in enumerate(groups, 1):
        for r in g:
            w.writerow(dup_cells(gi, r))


def _clean_cell(v):
    return str(v).replace("\t", " ").replace("\r", " ").replace("\n", " ")


def tsv_string(groups):
    lines = ["\t".join(DUP_HEADERS)]
    for gi, g in enumerate(groups, 1):
        for r in g:
            lines.append("\t".join(_clean_cell(c) for c in dup_cells(gi, r)))
    return "\n".join(lines) + "\n"


def write_tsv(groups, fh):
    fh.write(tsv_string(groups))


def clipboard_cmd():
    if os.environ.get("WAYLAND_DISPLAY") and shutil.which("wl-copy"):
        return ["wl-copy"]
    if shutil.which("xclip"):
        return ["xclip", "-selection", "clipboard"]
    if shutil.which("xsel"):
        return ["xsel", "--clipboard", "--input"]
    if shutil.which("pbcopy"):
        return ["pbcopy"]
    return None


def copy_to_clipboard(groups):
    cmd = clipboard_cmd()
    if not cmd:
        sys.exit("No clipboard tool found. Install wl-clipboard (Wayland), "
                 "xclip/xsel (X11), or use --format tsv | wl-copy.")
    n = sum(len(g) for g in groups)
    subprocess.run(cmd, input=tsv_string(groups), text=True, check=True)
    print(f"Copied {n} row(s) in {len(groups)} group(s) to clipboard as TSV.",
          file=sys.stderr)


def main():
    ap = argparse.ArgumentParser(description="Find duplicate Firefly III transactions.")
    ap.add_argument("-q", "--query", help="narrow by description first (optional)")
    ap.add_argument("-f", "--from", dest="dfrom", help="date from YYYY-MM-DD")
    ap.add_argument("-t", "--to", dest="dto", help="date to YYYY-MM-DD")
    ap.add_argument("--year", type=int, metavar="YYYY",
                    help="shortcut for the whole year (overrides -f/-t)")
    ap.add_argument("--match",
                    choices=["amount", "amount-date", "amount-desc", "amount-date-desc"],
                    default="amount-date",
                    help="what defines a duplicate (default: amount-date)")
    ap.add_argument("--account",
                    choices=["both", "source", "destination", "off"],
                    default="both",
                    help="scope comparison per account: require same source and/or "
                         "destination (default: both; 'off' = ignore account)")
    ap.add_argument("--format", choices=["table", "csv", "tsv"], default="table",
                    help="stdout format (default: table)")
    ap.add_argument("-o", "--out", help="also write CSV to this file")
    ap.add_argument("--clip", action="store_true",
                    help="copy flagged duplicates to clipboard as TSV")
    ap.add_argument("--url", default=os.environ.get("FIREFLY_URL"))
    ap.add_argument("--token", default=os.environ.get("FIREFLY_TOKEN"))
    ap.add_argument("--insecure", action="store_true", help="skip TLS verification")
    ap.add_argument("--limit", type=int, default=50, help="page size (default 50)")
    args = ap.parse_args()

    if not args.url or not args.token:
        sys.exit("Set FIREFLY_URL and FIREFLY_TOKEN (env) or pass --url/--token.")

    try:
        dfrom, dto = resolve_dates(args.year, args.dfrom, args.dto)
    except ValueError as e:
        sys.exit(str(e))

    q = build_query(args.query, dfrom, dto)
    try:
        rows = fetch_all(args.url, args.token, q, insecure=args.insecure, limit=args.limit)
    except urllib.error.HTTPError as e:
        sys.exit(f"API error {e.code}: {e.read().decode(errors='replace')}")
    except urllib.error.URLError as e:
        sys.exit(f"Connection error: {e.reason}")

    groups = find_duplicates(rows, args.match, args.account)

    if args.format == "csv" and not args.out:
        write_csv(groups, sys.stdout)
    elif args.format == "tsv":
        write_tsv(groups, sys.stdout)
    else:
        print(f"Scanned {len(rows)} transaction(s) "
              f"{iso(dfrom)}..{iso(dto)}, match={args.match}, account={args.account}\n")
        print_groups(groups, args.match)

    if args.out:
        with open(args.out, "w", newline="") as fh:
            write_csv(groups, fh)
        print(f"\nCSV written to {args.out}", file=sys.stderr)

    if args.clip:
        copy_to_clipboard(groups)


if __name__ == "__main__":
    main()
