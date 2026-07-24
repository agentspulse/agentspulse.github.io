#!/usr/bin/env python3
import importlib.util
import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("submit_indexnow", ROOT / "scripts/submit_indexnow.py")
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(MODULE)


class SitemapUrlsTest(unittest.TestCase):
    def test_extracts_and_deduplicates_same_host_urls(self):
        xml = b'''<?xml version="1.0"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
          <url><loc>https://agentspulse.github.io/</loc></url>
          <url><loc>https://agentspulse.github.io/tutorials/example/</loc></url>
          <url><loc>https://agentspulse.github.io/</loc></url>
        </urlset>'''
        self.assertEqual(
            MODULE.sitemap_urls(xml, "agentspulse.github.io"),
            [
                "https://agentspulse.github.io/",
                "https://agentspulse.github.io/tutorials/example/",
            ],
        )

    def test_rejects_cross_host_urls(self):
        xml = b'''<urlset><url><loc>https://example.com/page</loc></url></urlset>'''
        with self.assertRaises(ValueError):
            MODULE.sitemap_urls(xml, "agentspulse.github.io")

    def test_rejects_empty_sitemap(self):
        with self.assertRaises(ValueError):
            MODULE.sitemap_urls(b"<urlset />", "agentspulse.github.io")


if __name__ == "__main__":
    unittest.main()
