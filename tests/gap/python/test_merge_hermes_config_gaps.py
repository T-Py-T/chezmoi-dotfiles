"""Gap coverage for merge-hermes-config behaviors not exercised in draft PR #25."""

from __future__ import annotations

import importlib.util
import json
import os
import stat
import tempfile
import unittest
from pathlib import Path

import yaml

REPO_ROOT = Path(__file__).resolve().parents[3]
_MERGE_HELPER = REPO_ROOT / "scripts" / "merge-hermes-config.py"
_spec = importlib.util.spec_from_file_location("merge_hermes_config_gaps", _MERGE_HELPER)
assert _spec and _spec.loader
_merge_module = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_merge_module)
merge_config = _merge_module.merge_config
_external_dirs = _merge_module._external_dirs


class ExternalDirsJsonTests(unittest.TestCase):
    def test_json_array_string_is_decoded(self) -> None:
        payload = json.dumps(["~/first", "~/second"])
        self.assertEqual(_external_dirs(payload), ["~/first", "~/second"])

    def test_list_passthrough(self) -> None:
        self.assertEqual(_external_dirs(["a", "b"]), ["a", "b"])


class MergeHermesConfigGapTests(unittest.TestCase):
    def test_symlink_refused(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            config_path = Path(tmp) / "config.yaml"
            target = Path(tmp) / "real.yaml"
            target.write_text("worktree: false\n", encoding="utf-8")
            config_path.symlink_to(target)

            with self.assertRaises(RuntimeError):
                merge_config(config_path)

    def test_merge_sets_worktree_defaults_and_dedupes_dirs(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            config_path = Path(tmp) / "config.yaml"
            config_path.write_text(
                yaml.safe_dump(
                    {
                        "skills": {
                            "external_dirs": [
                                "~/.agents/skills",
                                "~/extra",
                            ]
                        }
                    },
                    sort_keys=False,
                ),
                encoding="utf-8",
            )

            merge_config(config_path)
            loaded = yaml.safe_load(config_path.read_text(encoding="utf-8"))
            self.assertTrue(loaded["worktree"])
            self.assertTrue(loaded["worktree_sync"])
            self.assertEqual(
                loaded["skills"]["external_dirs"],
                ["~/.agents/skills", "~/extra"],
            )
            self.assertTrue(loaded["skills"]["write_approval"])
            mode = stat.S_IMODE(os.stat(config_path).st_mode)
            self.assertEqual(mode, stat.S_IRUSR | stat.S_IWUSR)

    def test_missing_file_creates_config_with_defaults(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            config_path = Path(tmp) / "nested" / "config.yaml"
            merge_config(config_path)
            loaded = yaml.safe_load(config_path.read_text(encoding="utf-8"))
            self.assertEqual(
                loaded["skills"]["external_dirs"],
                ["~/.agents/skills"],
            )


if __name__ == "__main__":
    unittest.main()
