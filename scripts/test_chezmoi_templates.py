"""Unit tests for chezmoi template rendering invariants."""

from __future__ import annotations

import hashlib
import importlib.util
import subprocess
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
CHEZMOI = "chezmoi"


def _render_template(relative_path: str) -> str:
    result = subprocess.run(
        [
            CHEZMOI,
            "--source",
            str(REPO_ROOT),
            "execute-template",
            "--init",
            "-f",
            relative_path,
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    return result.stdout


class ChezmoiTemplateTests(unittest.TestCase):
    def test_onchange_script_embeds_pre_commit_config_hash(self) -> None:
        config_path = REPO_ROOT / ".pre-commit-config.yaml"
        expected = hashlib.sha256(config_path.read_bytes()).hexdigest()
        rendered = _render_template("scripts/run_onchange_after_precommit.tmpl")
        self.assertIn(expected, rendered)

    def test_agent_tools_template_resolves_source_dir(self) -> None:
        rendered = _render_template("scripts/run_after_20_agent_tools.tmpl")
        self.assertIn(f"source_dir='{REPO_ROOT}'", rendered)
        self.assertNotIn("{{", rendered)
        self.assertNotIn("}}", rendered)

    def test_brew_templates_have_no_unresolved_markers(self) -> None:
        for brewfile in (REPO_ROOT / "brew").rglob("*.tmpl"):
            relative = brewfile.relative_to(REPO_ROOT).as_posix()
            rendered = _render_template(relative)
            self.assertNotIn("{{", rendered)
            self.assertNotIn("}}", rendered)


if __name__ == "__main__":
    unittest.main()
