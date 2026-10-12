"""Static regression checks on chezmoi script templates."""

from __future__ import annotations

from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[2]
SCRIPT_TEMPLATES = sorted((REPO_ROOT / "scripts").glob("*.tmpl"))


@pytest.mark.parametrize("template", SCRIPT_TEMPLATES, ids=lambda p: p.name)
def test_template_starts_with_bash_shebang(template: Path):
    first = template.read_text(encoding="utf-8").splitlines()[0]
    assert first.startswith("#!/usr/bin/env bash")


@pytest.mark.parametrize("template", SCRIPT_TEMPLATES, ids=lambda p: p.name)
def test_template_uses_strict_mode(template: Path):
    body = template.read_text(encoding="utf-8")
    assert "set -e" in body


def test_run_after_agent_tools_declares_skip_env():
    text = (REPO_ROOT / "scripts" / "run_after_20_agent_tools.tmpl").read_text(
        encoding="utf-8"
    )
    assert "SKIP_AGENT_TOOLS" in text
    assert "SKIP_HERMES_AGENT" in text
    assert "merge-hermes-config.py" in text


def test_run_onchange_skips_in_container():
    text = (REPO_ROOT / "scripts" / "run_onchange_after_precommit.tmpl").read_text(
        encoding="utf-8"
    )
    assert "DEVCONTAINER" in text
    assert ".dockerenv" in text
    assert "pre-commit install" in text
