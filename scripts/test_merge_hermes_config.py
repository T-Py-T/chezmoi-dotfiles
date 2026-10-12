"""Unit tests for scripts/merge-hermes-config.py (stdlib only; PyYAML required)."""

from __future__ import annotations

import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

import yaml

REPO_ROOT = Path(__file__).resolve().parents[1]
_MERGE_HELPER = REPO_ROOT / "scripts" / "merge-hermes-config.py"
_spec = importlib.util.spec_from_file_location("merge_hermes_config", _MERGE_HELPER)
assert _spec and _spec.loader
_merge_module = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_merge_module)
merge_config = _merge_module.merge_config


class MergeHermesConfigTests(unittest.TestCase):
    def test_merge_into_empty_file_sets_defaults(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            config_path = Path(tmp) / "config.yaml"
            merge_config(config_path)

            loaded = yaml.safe_load(config_path.read_text(encoding="utf-8"))
            self.assertTrue(loaded["worktree"])
            self.assertTrue(loaded["worktree_sync"])
            self.assertEqual(
                loaded["skills"]["external_dirs"],
                ["~/.agents/skills"],
            )
            self.assertTrue(loaded["skills"]["write_approval"])
            self.assertEqual(oct(config_path.stat().st_mode & 0o777), "0o600")

    def test_merge_preserves_existing_keys_and_dedupes_external_dirs(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            config_path = Path(tmp) / "config.yaml"
            config_path.write_text(
                yaml.safe_dump(
                    {
                        "model": "test-model",
                        "skills": {
                            "external_dirs": [
                                "~/custom-skills",
                                "~/.agents/skills",
                            ],
                        },
                    },
                    sort_keys=False,
                ),
                encoding="utf-8",
            )

            merge_config(config_path)
            loaded = yaml.safe_load(config_path.read_text(encoding="utf-8"))

            self.assertEqual(loaded["model"], "test-model")
            self.assertEqual(
                loaded["skills"]["external_dirs"],
                ["~/custom-skills", "~/.agents/skills"],
            )

    def test_external_dirs_accepts_json_string(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            config_path = Path(tmp) / "config.yaml"
            config_path.write_text(
                yaml.safe_dump(
                    {
                        "skills": {
                            "external_dirs": json.dumps(["~/from-json"]),
                        },
                    },
                    sort_keys=False,
                ),
                encoding="utf-8",
            )

            merge_config(config_path)
            loaded = yaml.safe_load(config_path.read_text(encoding="utf-8"))
            self.assertEqual(
                loaded["skills"]["external_dirs"],
                ["~/from-json", "~/.agents/skills"],
            )

    def test_refuses_symlinked_config(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            real = Path(tmp) / "real.yaml"
            real.write_text("{}", encoding="utf-8")
            link = Path(tmp) / "config.yaml"
            link.symlink_to(real)

            with self.assertRaises(RuntimeError):
                merge_config(link)


if __name__ == "__main__":
    unittest.main()
