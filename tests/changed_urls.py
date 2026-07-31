#!/usr/bin/env python3
import importlib.util
import pathlib
import tempfile
import unittest
from unittest import mock

ROOT = pathlib.Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("find_changed_urls", ROOT / "scripts/find_changed_urls.py")
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(MODULE)


class ChangedUrlsTest(unittest.TestCase):
    def test_maps_clean_urls_to_index_files(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            self.assertEqual(
                MODULE.local_path(root, "https://agentspulse.github.io/", "agentspulse.github.io"),
                (root / "index.html").resolve(),
            )
            self.assertEqual(
                MODULE.local_path(
                    root,
                    "https://agentspulse.github.io/tutorials/example/",
                    "agentspulse.github.io",
                ),
                (root / "tutorials/example/index.html").resolve(),
            )

    def test_reports_only_content_that_differs(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            same = "https://agentspulse.github.io/"
            changed = "https://agentspulse.github.io/tutorials/changed/"
            (root / "index.html").write_bytes(b"same")
            (root / "tutorials/changed").mkdir(parents=True)
            (root / "tutorials/changed/index.html").write_bytes(b"new")

            with mock.patch.object(MODULE, "fetch", side_effect=[b"same", b"old"]):
                self.assertEqual(
                    MODULE.changed_urls([same, changed], [], root, "agentspulse.github.io"),
                    [changed],
                )

    def test_reports_removed_urls(self):
        with tempfile.TemporaryDirectory() as directory:
            removed = "https://agentspulse.github.io/tutorials/removed/"
            self.assertEqual(
                MODULE.changed_urls([], [removed], pathlib.Path(directory), "agentspulse.github.io"),
                [removed],
            )


if __name__ == "__main__":
    unittest.main()
