"""Structural invariants for Brewfile templates across environments."""

from __future__ import annotations

import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
BREWFILES = sorted((REPO_ROOT / "brew").rglob("dot_Brewfile*.tmpl"))

BREW_RE = re.compile(r'^brew\s+"([^"]+)"', re.MULTILINE)
TAP_RE = re.compile(r'^tap\s+"([^"]+)"', re.MULTILINE)


def _load(name: str) -> str:
    path = REPO_ROOT / name
    assert path.is_file(), f"missing brewfile: {name}"
    return path.read_text(encoding="utf-8")


def test_all_platform_brewfiles_exist() -> None:
    expected = [
        "brew/devcontainer/dot_Brewfile.tmpl",
        "brew/linux/dot_Brewfile-wsl.tmpl",
        "brew/linux/dot_Brewfile.tmpl",
        "brew/macos/dot_Brewfile-Work.tmpl",
        "brew/macos/dot_Brewfile.tmpl",
    ]
    assert [str(p.relative_to(REPO_ROOT)) for p in BREWFILES] == expected


def test_each_brewfile_lists_neovim_and_git() -> None:
    for path in BREWFILES:
        text = path.read_text(encoding="utf-8")
        formulas = set(BREW_RE.findall(text))
        assert "neovim" in formulas, f"{path.name} missing neovim"
        assert "git" in formulas, f"{path.name} missing git"


def test_no_duplicate_formulas_within_a_brewfile() -> None:
    for path in BREWFILES:
        formulas = BREW_RE.findall(path.read_text(encoding="utf-8"))
        assert len(formulas) == len(set(formulas)), f"duplicate brew entries in {path}"


def test_linux_and_wsl_share_core_search_tools() -> None:
    linux = set(BREW_RE.findall(_load("brew/linux/dot_Brewfile.tmpl")))
    wsl = set(BREW_RE.findall(_load("brew/linux/dot_Brewfile-wsl.tmpl")))
    for tool in ("ripgrep", "fd", "fzf", "mise"):
        assert tool in linux
        assert tool in wsl


def test_macos_work_and_personal_share_coordination_tools() -> None:
    personal = set(BREW_RE.findall(_load("brew/macos/dot_Brewfile.tmpl")))
    work = set(BREW_RE.findall(_load("brew/macos/dot_Brewfile-Work.tmpl")))
    for tool in ("neovim", "git", "pre-commit", "fzf"):
        assert tool in personal
        assert tool in work


def test_devcontainer_is_minimal_vs_linux() -> None:
    dev = set(BREW_RE.findall(_load("brew/devcontainer/dot_Brewfile.tmpl")))
    linux = set(BREW_RE.findall(_load("brew/linux/dot_Brewfile.tmpl")))
    assert len(dev) < len(linux)
    assert "k9s" in dev
    assert "gh" not in dev
