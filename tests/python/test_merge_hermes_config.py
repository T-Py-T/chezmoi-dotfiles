"""Behavior tests for scripts/merge-hermes-config.py (complements lint-only CI)."""

from __future__ import annotations

import importlib.util
import tempfile
import unittest
from pathlib import Path

import yaml

REPO_ROOT = Path(__file__).resolve().parents[2]
_MERGE_HELPER = REPO_ROOT / "scripts" / "merge-hermes-config.py"
_spec = importlib.util.spec_from_file_location("merge_hermes_config", _MERGE_HELPER)
assert _spec and _spec.loader
_merge_module = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_merge_module)
merge_config = _merge_module.merge_config
_external_dirs = _merge_module._external_dirs


class ExternalDirsHelperTests(unittest.TestCase):
    def test_none_returns_empty_list(self) -> None:
        self.assertEqual(_external_dirs(None), [])

    def test_plain_string_becomes_single_entry(self) -> None:
        self.assertEqual(_external_dirs("~/solo"), ["~/solo"])

    def test_invalid_type_raises(self) -> None:
        with self.assertRaises(TypeError):
            _external_dirs(42)


class MergeHermesConfigTests(unittest.TestCase):
    def test_merge_appends_shared_dir_to_scalar_external_dirs(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            config_path = Path(tmp) / "config.yaml"
            config_path.write_text(
                yaml.safe_dump(
                    {"skills": {"external_dirs": "~/only-one"}},
                    sort_keys=False,
                ),
                encoding="utf-8",
            )

            merge_config(config_path)
            loaded = yaml.safe_load(config_path.read_text(encoding="utf-8"))
            self.assertEqual(
                loaded["skills"]["external_dirs"],
                ["~/only-one", "~/.agents/skills"],
            )

    def test_non_mapping_root_raises(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            config_path = Path(tmp) / "config.yaml"
            config_path.write_text("[]\n", encoding="utf-8")

            with self.assertRaises(TypeError):
                merge_config(config_path)

    def test_skills_not_mapping_raises(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            config_path = Path(tmp) / "config.yaml"
            config_path.write_text(
                yaml.safe_dump({"skills": "broken"}, sort_keys=False),
                encoding="utf-8",
            )

            with self.assertRaises(TypeError):
                merge_config(config_path)


if __name__ == "__main__":
    unittest.main()
