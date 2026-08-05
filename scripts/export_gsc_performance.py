#!/usr/bin/env python3
"""Export Google Search Console Performance data to CSV files.

The export mirrors the main tabs in Search Console's Performance report:
daily totals, queries, pages, countries, and devices.

Required environment variables:
  GSC_SERVICE_ACCOUNT_JSON  Service-account key JSON. Falls back to
                            GA4_SERVICE_ACCOUNT_JSON for this repository.

Optional environment variables:
  GSC_SITE_URL              Search Console property, for example
                            https://agentspulse.github.io/ or sc-domain:example.com
"""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import json
import os
import pathlib
import sys
from typing import Any, Iterable
from urllib.parse import quote

API_ROOT = "https://www.googleapis.com/webmasters/v3/sites"
SCOPE = "https://www.googleapis.com/auth/webmasters.readonly"
DEFAULT_SITE_URL = "https://agentspulse.github.io/"
MAX_PAGE_SIZE = 25_000

REPORTS: dict[str, list[str]] = {
    "daily": ["date"],
    "queries": ["query"],
    "pages": ["page"],
    "countries": ["country"],
    "devices": ["device"],
}


def default_export_date() -> dt.date:
    """Use three days ago because finalized GSC data normally lags 2–3 days."""
    return dt.datetime.now(dt.timezone.utc).date() - dt.timedelta(days=3)


def build_session(service_account_json: str):
    try:
        from google.auth.transport.requests import AuthorizedSession
        from google.oauth2 import service_account
    except ImportError as exc:
        raise RuntimeError("google-auth and requests are required") from exc

    try:
        info = json.loads(service_account_json)
    except json.JSONDecodeError as exc:
        raise RuntimeError("GSC_SERVICE_ACCOUNT_JSON is not valid JSON") from exc

    credentials = service_account.Credentials.from_service_account_info(info, scopes=[SCOPE])
    return AuthorizedSession(credentials)


def query_rows(
    session: Any,
    site_url: str,
    start_date: str,
    end_date: str,
    dimensions: list[str],
    search_type: str,
) -> list[dict[str, Any]]:
    """Fetch all API pages available for one report."""
    endpoint = f"{API_ROOT}/{quote(site_url, safe='')}/searchAnalytics/query"
    rows: list[dict[str, Any]] = []
    start_row = 0

    while True:
        response = session.post(
            endpoint,
            json={
                "startDate": start_date,
                "endDate": end_date,
                "dimensions": dimensions,
                "type": search_type,
                "dataState": "final",
                "rowLimit": MAX_PAGE_SIZE,
                "startRow": start_row,
            },
            timeout=60,
        )
        if not response.ok:
            detail = response.text[:500].replace("\n", " ")
            raise RuntimeError(f"Search Console API returned HTTP {response.status_code}: {detail}")

        page = response.json().get("rows", [])
        rows.extend(page)
        if len(page) < MAX_PAGE_SIZE:
            break
        start_row += MAX_PAGE_SIZE

    return rows


def serialize_rows(rows: Iterable[dict[str, Any]], dimensions: list[str]) -> Iterable[list[Any]]:
    for row in rows:
        keys = row.get("keys", [])
        yield [
            *(keys[index] if index < len(keys) else "" for index in range(len(dimensions))),
            row.get("clicks", 0),
            row.get("impressions", 0),
            row.get("ctr", 0),
            row.get("position", 0),
        ]


def write_csv(path: pathlib.Path, dimensions: list[str], rows: list[dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.writer(handle)
        writer.writerow([*dimensions, "clicks", "impressions", "ctr", "position"])
        writer.writerows(serialize_rows(rows, dimensions))


def parse_reports(value: str) -> list[str]:
    names = [name.strip() for name in value.split(",") if name.strip()]
    unknown = sorted(set(names) - REPORTS.keys())
    if unknown:
        raise argparse.ArgumentTypeError(f"unknown reports: {', '.join(unknown)}")
    return names


def main() -> int:
    parser = argparse.ArgumentParser(description="Export GSC Performance report data")
    parser.add_argument("--date", default=default_export_date().isoformat(), help="single date (YYYY-MM-DD)")
    parser.add_argument("--end-date", help="optional end date; defaults to --date")
    parser.add_argument("--site-url", default=os.getenv("GSC_SITE_URL", DEFAULT_SITE_URL))
    parser.add_argument("--type", default="web", choices=["web", "image", "video", "news", "discover", "googleNews"])
    parser.add_argument("--reports", type=parse_reports, default=list(REPORTS), help="comma-separated report names")
    parser.add_argument("--output-dir", type=pathlib.Path, default=pathlib.Path("tmp/gsc"))
    args = parser.parse_args()

    try:
        start = dt.date.fromisoformat(args.date)
        end = dt.date.fromisoformat(args.end_date or args.date)
    except ValueError:
        parser.error("--date and --end-date must use YYYY-MM-DD")
    if end < start:
        parser.error("--end-date cannot be earlier than --date")

    service_json = (
        os.getenv("GSC_SERVICE_ACCOUNT_JSON", "").strip()
        or os.getenv("GA4_SERVICE_ACCOUNT_JSON", "").strip()
    )
    if not service_json:
        print("GSC_SERVICE_ACCOUNT_JSON (or GA4_SERVICE_ACCOUNT_JSON) is required", file=sys.stderr)
        return 1

    try:
        session = build_session(service_json)
        output_dir = args.output_dir.resolve()
        counts: dict[str, int] = {}
        for name in args.reports:
            dimensions = REPORTS[name]
            rows = query_rows(session, args.site_url, start.isoformat(), end.isoformat(), dimensions, args.type)
            write_csv(output_dir / f"{name}.csv", dimensions, rows)
            counts[name] = len(rows)
            print(f"wrote {output_dir / f'{name}.csv'} ({len(rows)} rows)")

        manifest = {
            "site_url": args.site_url,
            "start_date": start.isoformat(),
            "end_date": end.isoformat(),
            "search_type": args.type,
            "data_state": "final",
            "generated_at": dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds"),
            "row_counts": counts,
            "notes": "Query-level data can omit anonymized queries; GSC API limits also apply.",
        }
        (output_dir / "manifest.json").write_text(
            json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        return 0
    except Exception as exc:
        print(f"GSC export failed: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
