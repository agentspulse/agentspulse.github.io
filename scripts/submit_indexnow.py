#!/usr/bin/env python3
"""Submit URLs from the deployed sitemap to the IndexNow API."""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET

DEFAULT_ENDPOINT = "https://www.bing.com/indexnow"
KEY_PATTERN = re.compile(r"^[A-Za-z0-9-]{8,128}$")
USER_AGENT = "AgentsPulse-IndexNow/1.0"


def request(url: str, *, data: bytes | None = None, content_type: str | None = None):
    headers = {"User-Agent": USER_AGENT}
    if content_type:
        headers["Content-Type"] = content_type
    return urllib.request.urlopen(
        urllib.request.Request(url, data=data, headers=headers), timeout=30
    )


def fetch_bytes(url: str, attempts: int = 6, delay: int = 10) -> bytes:
    last_error: Exception | None = None
    for attempt in range(1, attempts + 1):
        try:
            with request(url) as response:
                return response.read()
        except (urllib.error.URLError, TimeoutError) as error:
            last_error = error
            if attempt < attempts:
                print(f"Resource not ready; retrying ({attempt}/{attempts})…")
                time.sleep(delay)
    raise RuntimeError(f"Unable to fetch deployed resource after {attempts} attempts") from last_error


def sitemap_urls(xml_data: bytes, expected_host: str) -> list[str]:
    root = ET.fromstring(xml_data)
    urls: list[str] = []
    seen: set[str] = set()
    for element in root.iter():
        if element.tag.rsplit("}", 1)[-1] != "loc" or not element.text:
            continue
        url = element.text.strip()
        parsed = urllib.parse.urlparse(url)
        if parsed.scheme not in {"http", "https"} or parsed.netloc != expected_host:
            raise ValueError(f"Sitemap URL does not belong to {expected_host}: {url}")
        if url not in seen:
            seen.add(url)
            urls.append(url)
    if not urls:
        raise ValueError("Sitemap contains no URLs")
    if len(urls) > 10_000:
        raise ValueError("IndexNow accepts at most 10,000 URLs per request")
    return urls


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--sitemap", required=True, help="Public sitemap URL")
    parser.add_argument("--endpoint", default=DEFAULT_ENDPOINT)
    parser.add_argument("--key-file", help="Local UTF-8 file containing the IndexNow key")
    parser.add_argument("--key-location", help="Public HTTPS URL of the key file")
    args = parser.parse_args()

    key = os.environ.get("INDEXNOW_KEY", "")
    if args.key_file:
        key = open(args.key_file, encoding="utf-8").read().strip()
    if not KEY_PATTERN.fullmatch(key):
        print("INDEXNOW_KEY must be 8–128 letters, numbers, or dashes", file=sys.stderr)
        return 2

    parsed_sitemap = urllib.parse.urlparse(args.sitemap)
    if parsed_sitemap.scheme != "https" or not parsed_sitemap.netloc:
        print("The sitemap must use an absolute HTTPS URL", file=sys.stderr)
        return 2

    host = parsed_sitemap.netloc
    origin = f"{parsed_sitemap.scheme}://{host}"
    key_location = args.key_location or f"{origin}/{key}.txt"
    parsed_key_location = urllib.parse.urlparse(key_location)
    if (
        parsed_key_location.scheme != "https"
        or parsed_key_location.netloc != host
    ):
        print("The key location must be an HTTPS URL on the sitemap host", file=sys.stderr)
        return 2

    # Wait until the new deployment and its verification file are publicly readable.
    deployed_key = fetch_bytes(key_location).decode("utf-8").strip()
    if deployed_key != key:
        print("The deployed IndexNow verification file does not match", file=sys.stderr)
        return 1

    urls = sitemap_urls(fetch_bytes(args.sitemap), host)
    payload = json.dumps(
        {
            "host": host,
            "key": key,
            "keyLocation": key_location,
            "urlList": urls,
        }
    ).encode("utf-8")

    try:
        with request(
            args.endpoint,
            data=payload,
            content_type="application/json; charset=utf-8",
        ) as response:
            status = response.status
    except urllib.error.HTTPError as error:
        print(f"IndexNow submission failed with HTTP {error.code}", file=sys.stderr)
        return 1
    except (urllib.error.URLError, TimeoutError) as error:
        reason = getattr(error, "reason", str(error))
        print(f"IndexNow submission failed: {reason}", file=sys.stderr)
        return 1

    if status not in {200, 202}:
        print(f"IndexNow submission returned unexpected HTTP {status}", file=sys.stderr)
        return 1

    print(f"IndexNow accepted {len(urls)} URLs (HTTP {status})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
