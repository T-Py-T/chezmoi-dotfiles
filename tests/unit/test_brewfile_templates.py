"""Regression checks for Brewfile templates under brew/."""

from __future__ import annotations

import re
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[2]
BREW_ROOT = REPO_ROOT / "brew"

BREWFILES = sorted(BREW_ROOT.glob("**/dot_Brewfile*.tmpl"))


@pytest.mark.parametrize("brewfile", BREWFILES, ids=lambda p: p.relative_to(REPO_ROOT).as_posix())
def test_brewfile_has_core_entries(brewfile: Path):
    text = brewfile.read_text(encoding="utf-8")
    assert 'brew "git"' in text or "brew 'git'" in text
    assert re.search(r'^brew\s+["\']', text, re.MULTILINE), (
        f"{brewfile} should declare at least one brew formula"
    )


@pytest.mark.parametrize("brewfile", BREWFILES, ids=lambda p: p.relative_to(REPO_ROOT).as_posix())
def test_brewfile_documents_purpose(brewfile: Path):
    text = brewfile.read_text(encoding="utf-8")
    assert "#" in text.splitlines()[0] or any(
        line.startswith("#") for line in text.splitlines()[:8]
    ), f"{brewfile} should include a descriptive comment near the top"


def test_devcontainer_brewfile_avoids_laptop_only_patterns():
    dev = (BREW_ROOT / "devcontainer" / "dot_Brewfile.tmpl").read_text(encoding="utf-8")
    assert "devcontainer" in dev.lower()
    assert "cask " not in dev
    assert 'brew "neovim"' in dev
