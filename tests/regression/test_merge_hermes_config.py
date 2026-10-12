"""Regression tests for scripts/merge-hermes-config.py."""

from __future__ import annotations

import importlib.util
import tempfile
import unittest
from pathlib import Path

_REPO_ROOT = Path(__file__).resolve().parents[2]
_MERGE_HELPER = _REPO_ROOT / "scripts" / "merge-hermes-config.py"


def _load_merge_config() -> object:
    spec = importlib.util.spec_from_file_location(
        "merge_hermes_config", _MERGE_HELPER
    )
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {_MERGE_HELPER}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.merge_config


merge_config = _load_merge_config()


class MergeHermesConfigRegressionTest(unittest.TestCase):
    def test_skills_null_is_treated_as_empty_mapping(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            config_path = Path(tmp) / "config.yaml"
            config_path.write_text("skills: null\n", encoding="utf-8")

            merge_config(config_path)

            text = config_path.read_text(encoding="utf-8")
            self.assertIn("external_dirs", text)
            self.assertIn("~/.agents/skills", text)
            self.assertIn("write_approval: true", text)


if __name__ == "__main__":
    unittest.main()
