#!/usr/bin/env python3
"""Hermes merge helper edge cases not covered by happy-path merges."""

from __future__ import annotations

import importlib.util
import os
import stat
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MODULE = ROOT / "scripts" / "merge-hermes-config.py"


def load_module():
    spec = importlib.util.spec_from_file_location("merge_hermes_config", MODULE)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


merge = load_module()


class ExternalDirsTests(unittest.TestCase):
    def test_none_returns_empty_list(self) -> None:
        self.assertEqual(merge._external_dirs(None), [])

    def test_json_string_list(self) -> None:
        self.assertEqual(merge._external_dirs('["/a", "/b"]'), ["/a", "/b"])

    def test_invalid_json_string_is_single_entry(self) -> None:
        self.assertEqual(merge._external_dirs("not-json"), ["not-json"])

    def test_non_list_json_string_is_single_entry(self) -> None:
        self.assertEqual(merge._external_dirs('{"x": 1}'), ['{"x": 1}'])

    def test_invalid_type_raises(self) -> None:
        with self.assertRaises(TypeError):
            merge._external_dirs(42)


class MergeConfigTests(unittest.TestCase):
    def test_refuses_symlink_target(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            real = Path(tmp) / "config.yaml"
            real.write_text("skills: {}\n", encoding="utf-8")
            link = Path(tmp) / "linked.yaml"
            link.symlink_to(real)
            with self.assertRaises(RuntimeError):
                merge.merge_config(link)

    def test_non_mapping_root_raises(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "config.yaml"
            path.write_text("- not-a-mapping\n", encoding="utf-8")
            with self.assertRaises(TypeError):
                merge.merge_config(path)

    def test_non_mapping_skills_raises(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "config.yaml"
            path.write_text("skills: []\n", encoding="utf-8")
            with self.assertRaises(TypeError):
                merge.merge_config(path)

    def test_writes_mode_600_and_portable_defaults(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "config.yaml"
            merge.merge_config(path)
            mode = stat.S_IMODE(os.stat(path).st_mode)
            self.assertEqual(mode, 0o600)
            import yaml

            data = yaml.safe_load(path.read_text(encoding="utf-8"))
            self.assertTrue(data["worktree"])
            self.assertIn("~/.agents/skills", data["skills"]["external_dirs"])
            self.assertTrue(data["skills"]["write_approval"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
