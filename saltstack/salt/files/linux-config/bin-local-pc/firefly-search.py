#!/usr/bin/env python3
"""
ff-search.py — search Firefly III transactions, print a table + total, or CSV.

Config (env vars or flags):
  FIREFLY_URL    e.g. https://firefly.example.com     (or --url)
  FIREFLY_TOKEN  Personal Access Token                (or --token)
                 -> Firefly: Profile > OAuth > Personal Access Tokens

Usage:
  ./ff-search.py                                       # prompts for query; dates = current year
  ./ff-search.py -q freenet                            # freenet, current year
  ./ff-search.py -q freenet --year 2025                # whole of 2025
  ./ff-search.py -q freenet -f 2025-01-01 -t 2025-06-30
  ./ff-search.py -q freenet --year 2025 --format csv > freenet.csv
  ./ff-search.py -q freenet --year 2025 -o freenet.csv # table + CSV file
  ./ff-search.py -q freenet --year 2025 --clip         # table + copy to clipboard (TSV)
  ./ff-search.py -q freenet --year 2025 --format tsv | wl-copy   # pipe it yourself

Notes:
  * Dates: --year YYYY covers the whole year. Otherwise any bound you omit
    defaults to the start/end of the CURRENT year (no interactive date prompt).
  * The from/to dates are treated as INCLUSIVE (bounds are widened by one day
    so Firefly's date_after/date_before don't clip the edges).
  * Totals are summed as ABSOLUTE values per currency (expense-report style).
    To sum signed amounts instead, drop the abs() in print_table().
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


def iso(d):
    return d.strftime("%Y-%m-%d")


def parse_date(s):
    return dt.datetime.strptime(s.strip(), "%Y-%m-%d").date()


def build_query(text, dfrom, dto):
    # Widen bounds by one day so date_after/date_before behave inclusively.
    after = iso(dfrom - dt.timedelta(days=1))
    before = iso(dto + dt.timedelta(days=1))
    parts = []
    if text:
        parts.append(text)
    parts.append(f"date_after:{after}")
    parts.append(f"date_before:{before}")
    return " ".join(parts)


def resolve_dates(year, dfrom, dto, today=None):
    """Decide the inclusive [from, to] range.

    --year wins (and forbids -f/-t); otherwise any unset bound defaults to the
    start/end of the current year.
    """
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
        params = urllib.parse.urlencode(
            {"query": query, "limit": limit, "page": page}
        )
        req = urllib.request.Request(
            f"{endpoint}?{params}",
            headers={
                "Authorization": f"Bearer {token}",
                "Accept": "application/json",
            },
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
        "date": (tx.get("date") or "")[:10],
        "type": tx.get("type") or "",
        "description": tx.get("description") or "",
        "category": tx.get("category_name") or "",
        "source": tx.get("source_name") or "",
        "destination": tx.get("destination_name") or "",
        "amount": float(tx.get("amount") or 0),
        "currency": tx.get("currency_code") or "",
    }


def truncate(s, n):
    s = s or ""
    return s if len(s) <= n else s[: n - 1] + "\u2026"


def fmt_amount(v, cur):
    return f"{v:,.2f} {cur}".strip()


def print_table(rows):
    data = [row_fields(t) for t in rows]

    table = [
        {
            "date": r["date"],
            "description": truncate(r["description"], 32),
            "category": truncate(r["category"], 16),
            "route": truncate(f'{r["source"]} \u2192 {r["destination"]}', 32),
            "amount_str": fmt_amount(r["amount"], r["currency"]),
        }
        for r in data
    ]

    cols = [
        ("Date", "date", "l"),
        ("Description", "description", "l"),
        ("Category", "category", "l"),
        ("From \u2192 To", "route", "l"),
        ("Amount", "amount_str", "r"),
    ]

    widths = {}
    for header, key, _ in cols:
        widths[key] = max([len(header)] + [len(r[key]) for r in table] or [0])

    def render(row):
        cells = []
        for _, key, align in cols:
            val = row[key]
            cells.append(val.rjust(widths[key]) if align == "r" else val.ljust(widths[key]))
        return "  ".join(cells)

    if table:
        print(render({key: header for header, key, _ in cols}))
        print("  ".join("-" * widths[key] for _, key, _ in cols))
        for row in table:
            print(render(row))
    else:
        print("(no matching transactions)")

    # Totals per currency (absolute values).
    totals = compute_totals(rows)

    print()
    print(f"{len(data)} transaction(s)")
    for cur, tot in sorted(totals.items()):
        print(f"Total ({cur or '?'}): {tot:,.2f}")


EXPORT_HEADERS = ["date", "type", "description", "category",
                  "source", "destination", "amount", "currency"]


def row_cells(r):
    return [
        r["date"], r["type"], r["description"], r["category"],
        r["source"], r["destination"], f'{r["amount"]:.2f}', r["currency"],
    ]


def write_csv(rows, fh):
    w = csv.writer(fh)
    w.writerow(EXPORT_HEADERS)
    for r in (row_fields(t) for t in rows):
        w.writerow(row_cells(r))


def _clean_cell(v):
    # Strip tabs/newlines so each value stays in one spreadsheet cell.
    return str(v).replace("\t", " ").replace("\r", " ").replace("\n", " ")


def compute_totals(rows):
    """Sum absolute amounts per currency (matches the on-screen table)."""
    totals = {}
    for r in (row_fields(t) for t in rows):
        totals[r["currency"]] = totals.get(r["currency"], 0.0) + abs(r["amount"])
    return totals


def total_rows(rows):
    """One spreadsheet row per currency, with the sum under the amount column."""
    out = []
    for cur, tot in sorted(compute_totals(rows).items()):
        cells = [""] * len(EXPORT_HEADERS)
        cells[5] = "TOTAL"        # destination column, just left of amount
        cells[6] = f"{tot:.2f}"   # amount column
        cells[7] = cur            # currency column
        out.append(cells)
    return out


def tsv_string(rows, include_total=True):
    lines = ["\t".join(EXPORT_HEADERS)]
    for r in (row_fields(t) for t in rows):
        lines.append("\t".join(_clean_cell(c) for c in row_cells(r)))
    if include_total and rows:
        lines.append("")  # blank separator row
        for cells in total_rows(rows):
            lines.append("\t".join(cells))
    return "\n".join(lines) + "\n"


def write_tsv(rows, fh, include_total=True):
    fh.write(tsv_string(rows, include_total=include_total))


def clipboard_cmd():
    """Pick a clipboard tool: Wayland > X11 > macOS."""
    if os.environ.get("WAYLAND_DISPLAY") and shutil.which("wl-copy"):
        return ["wl-copy"]
    if shutil.which("xclip"):
        return ["xclip", "-selection", "clipboard"]
    if shutil.which("xsel"):
        return ["xsel", "--clipboard", "--input"]
    if shutil.which("pbcopy"):
        return ["pbcopy"]
    return None


def copy_to_clipboard(rows, include_total=True):
    cmd = clipboard_cmd()
    if not cmd:
        sys.exit("No clipboard tool found. Install wl-clipboard (Wayland), "
                 "xclip/xsel (X11), or use --format tsv | wl-copy.")
    subprocess.run(cmd, input=tsv_string(rows, include_total=include_total),
                   text=True, check=True)
    print(f"Copied {len(rows)} row(s) to clipboard as TSV — "
          f"paste into Google Sheets with Ctrl+V.", file=sys.stderr)


def main():
    ap = argparse.ArgumentParser(description="Search Firefly III transactions.")
    ap.add_argument("-q", "--query", help="search text, e.g. freenet (empty = all in range)")
    ap.add_argument("-f", "--from", dest="dfrom", help="date from YYYY-MM-DD")
    ap.add_argument("-t", "--to", dest="dto", help="date to YYYY-MM-DD")
    ap.add_argument("--year", type=int, metavar="YYYY",
                    help="shortcut for the whole year (overrides -f/-t)")
    ap.add_argument("--format", choices=["table", "csv", "tsv"], default="table",
                    help="stdout format (default: table; tsv is paste-ready)")
    ap.add_argument("-o", "--out", help="also write CSV to this file")
    ap.add_argument("--clip", action="store_true",
                    help="copy result to clipboard as TSV (paste into Sheets)")
    ap.add_argument("--no-total-row", action="store_true",
                    help="omit the TOTAL row from tsv/clipboard output")
    ap.add_argument("--url", default=os.environ.get("FIREFLY_URL"))
    ap.add_argument("--token", default=os.environ.get("FIREFLY_TOKEN"))
    ap.add_argument("--insecure", action="store_true", help="skip TLS verification")
    ap.add_argument("--limit", type=int, default=50, help="page size (default 50)")
    args = ap.parse_args()

    if not args.url or not args.token:
        sys.exit("Set FIREFLY_URL and FIREFLY_TOKEN (env) or pass --url/--token.")

    query = args.query if args.query is not None else input("Search query: ").strip()

    try:
        dfrom, dto = resolve_dates(args.year, args.dfrom, args.dto)
    except ValueError as e:
        sys.exit(str(e))

    q = build_query(query, dfrom, dto)
    try:
        rows = fetch_all(args.url, args.token, q, insecure=args.insecure, limit=args.limit)
    except urllib.error.HTTPError as e:
        sys.exit(f"API error {e.code}: {e.read().decode(errors='replace')}")
    except urllib.error.URLError as e:
        sys.exit(f"Connection error: {e.reason}")

    include_total = not args.no_total_row
    if args.format == "csv" and not args.out:
        write_csv(rows, sys.stdout)
    elif args.format == "tsv":
        write_tsv(rows, sys.stdout, include_total=include_total)
    else:
        print_table(rows)

    if args.out:
        with open(args.out, "w", newline="") as fh:
            write_csv(rows, fh)
        print(f"\nCSV written to {args.out} ({len(rows)} rows)", file=sys.stderr)

    if args.clip:
        copy_to_clipboard(rows, include_total=include_total)


if __name__ == "__main__":
    main()
