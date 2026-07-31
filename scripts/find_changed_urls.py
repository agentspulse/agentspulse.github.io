#!/usr/bin/env python3
"""Compare a built site with the live deployment and list changed public URLs."""

from __future__ import annotations

import argparse
import pathlib
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET

USER_AGENT = "AgentsPulse-IndexNow-Diff/1.0"


def sitemap_urls(xml_data: bytes, expected_host: str | None = None) -> list[str]:
    root = ET.fromstring(xml_data)
    urls: list[str] = []
    seen: set[str] = set()
    for element in root.iter():
        if element.tag.rsplit("}", 1)[-1] != "loc" or not element.text:
            continue
        url = element.text.strip()
        parsed = urllib.parse.urlparse(url)
        if parsed.scheme != "https" or not parsed.netloc:
            raise ValueError(f"Sitemap URL must be absolute HTTPS: {url}")
        if expected_host and parsed.netloc != expected_host:
            raise ValueError(f"Sitemap URL does not belong to {expected_host}: {url}")
        if url not in seen:
            seen.add(url)
            urls.append(url)
    return urls


def local_path(site_dir: pathlib.Path, url: str, expected_host: str) -> pathlib.Path:
    parsed = urllib.parse.urlparse(url)
    if parsed.scheme != "https" or parsed.netloc != expected_host:
        raise ValueError(f"URL does not belong to {expected_host}: {url}")
    relative = urllib.parse.unquote(parsed.path).lstrip("/")
    if not relative or relative.endswith("/"):
        relative += "index.html"
    path = (site_dir / relative).resolve()
    root = site_dir.resolve()
    if path != root and root not in path.parents:
        raise ValueError(f"URL resolves outside the built site: {url}")
    return path


def fetch(url: str, timeout: int = 20) -> bytes | None:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            return response.read()
    except urllib.error.HTTPError as error:
        if error.code == 404:
            return None
        raise


def changed_urls(
    new_urls: list[str],
    old_urls: list[str],
    site_dir: pathlib.Path,
    expected_host: str,
) -> list[str]:
    ordered_urls = new_urls + [url for url in old_urls if url not in set(new_urls)]
    changed: list[str] = []
    for url in ordered_urls:
        path = local_path(site_dir, url, expected_host)
        if not path.is_file():
            changed.append(url)  # Removed from the new deployment.
            continue
        local_content = path.read_bytes()
        try:
            live_content = fetch(url)
        except (urllib.error.URLError, TimeoutError):
            changed.append(url)  # Submit conservatively if the comparison fails.
            continue
        if live_content != local_content:
            changed.append(url)
    return changed


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--sitemap", required=True, type=pathlib.Path)
    parser.add_argument("--site-dir", required=True, type=pathlib.Path)
    parser.add_argument("--output", required=True, type=pathlib.Path)
    args = parser.parse_args()

    new_xml = args.sitemap.read_bytes()
    new_urls = sitemap_urls(new_xml)
    if not new_urls:
        raise ValueError("Built sitemap contains no URLs")
    host = urllib.parse.urlparse(new_urls[0]).netloc
    if any(urllib.parse.urlparse(url).netloc != host for url in new_urls):
        raise ValueError("Built sitemap contains multiple hosts")

    sitemap_url = f"https://{host}/sitemap.xml"
    try:
        live_sitemap = fetch(sitemap_url)
        old_urls = sitemap_urls(live_sitemap or b"<urlset />", host)
    except (urllib.error.URLError, TimeoutError, ET.ParseError):
        old_urls = []

    urls = changed_urls(new_urls, old_urls, args.site_dir, host)
    args.output.write_text("".join(f"{url}\n" for url in urls), encoding="utf-8")
    print(f"Detected {len(urls)} changed public URL(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
