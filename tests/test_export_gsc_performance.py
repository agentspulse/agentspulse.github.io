import csv
import importlib.util
import pathlib
import tempfile
import unittest

MODULE_PATH = pathlib.Path(__file__).parents[1] / "scripts" / "export_gsc_performance.py"
SPEC = importlib.util.spec_from_file_location("gsc_export", MODULE_PATH)
gsc = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(gsc)


class FakeResponse:
    def __init__(self, rows):
        self.ok = True
        self.status_code = 200
        self.text = ""
        self._rows = rows

    def json(self):
        return {"rows": self._rows}


class FakeSession:
    def __init__(self, pages):
        self.pages = iter(pages)
        self.requests = []

    def post(self, url, json, timeout):
        self.requests.append((url, json, timeout))
        return FakeResponse(next(self.pages))


class GscExportTests(unittest.TestCase):
    def test_query_rows_paginates(self):
        original = gsc.MAX_PAGE_SIZE
        gsc.MAX_PAGE_SIZE = 2
        try:
            session = FakeSession([
                [{"keys": ["a"]}, {"keys": ["b"]}],
                [{"keys": ["c"]}],
            ])
            rows = gsc.query_rows(session, "https://example.com/", "2026-07-01", "2026-07-01", ["query"], "web")
        finally:
            gsc.MAX_PAGE_SIZE = original

        self.assertEqual(3, len(rows))
        self.assertEqual([0, 2], [request[1]["startRow"] for request in session.requests])
        self.assertIn("https%3A%2F%2Fexample.com%2F", session.requests[0][0])

    def test_write_csv_has_excel_friendly_utf8_and_metrics(self):
        rows = [{"keys": ["智能体"], "clicks": 3, "impressions": 10, "ctr": 0.3, "position": 2.5}]
        with tempfile.TemporaryDirectory() as folder:
            path = pathlib.Path(folder) / "queries.csv"
            gsc.write_csv(path, ["query"], rows)
            self.assertTrue(path.read_bytes().startswith(b"\xef\xbb\xbf"))
            with path.open(encoding="utf-8-sig", newline="") as handle:
                content = list(csv.reader(handle))
        self.assertEqual(["query", "clicks", "impressions", "ctr", "position"], content[0])
        self.assertEqual("智能体", content[1][0])

    def test_parse_reports_rejects_unknown_name(self):
        with self.assertRaises(Exception):
            gsc.parse_reports("daily,nope")


if __name__ == "__main__":
    unittest.main()
