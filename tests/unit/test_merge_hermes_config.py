"""Unit tests for scripts/merge-hermes-config.py."""

from __future__ import annotations

import os
from pathlib import Path

import pytest
import yaml

from conftest import load_merge_hermes_module, REPO_ROOT

merge = load_merge_hermes_module()
SHARED_SKILLS_DIR = merge.SHARED_SKILLS_DIR


def test_external_dirs_normalizes_inputs():
    assert merge._external_dirs(None) == []
    assert merge._external_dirs(["/a", "/b"]) == ["/a", "/b"]
    assert merge._external_dirs('["/x"]') == ["/x"]
    assert merge._external_dirs("/solo") == ["/solo"]
    with pytest.raises(TypeError):
        merge._external_dirs(42)


def test_merge_config_creates_defaults(tmp_path: Path):
    config_path = tmp_path / "config.yaml"
    merge.merge_config(config_path)

    data = yaml.safe_load(config_path.read_text(encoding="utf-8"))
    assert data["worktree"] is True
    assert data["worktree_sync"] is True
    assert SHARED_SKILLS_DIR in data["skills"]["external_dirs"]
    assert data["skills"]["write_approval"] is True
    assert oct(config_path.stat().st_mode & 0o777) == "0o600"


def test_merge_config_preserves_existing_dirs_and_dedupes(tmp_path: Path):
    config_path = tmp_path / "config.yaml"
    config_path.write_text(
        yaml.safe_dump(
            {
                "skills": {
                    "external_dirs": ["/custom", SHARED_SKILLS_DIR, "/custom"],
                }
            },
            sort_keys=False,
        ),
        encoding="utf-8",
    )

    merge.merge_config(config_path)
    data = yaml.safe_load(config_path.read_text(encoding="utf-8"))
    dirs = data["skills"]["external_dirs"]
    assert dirs[0] == "/custom"
    assert dirs.count("/custom") == 1
    assert SHARED_SKILLS_DIR in dirs


def test_merge_config_refuses_symlink(tmp_path: Path):
    real = tmp_path / "real.yaml"
    real.write_text("skills: {}\n", encoding="utf-8")
    link = tmp_path / "config.yaml"
    link.symlink_to(real)

    with pytest.raises(RuntimeError, match="symlink"):
        merge.merge_config(link)


def test_merge_config_rejects_non_mapping_root(tmp_path: Path):
    config_path = tmp_path / "config.yaml"
    config_path.write_text("- not a mapping\n", encoding="utf-8")

    with pytest.raises(TypeError, match="mapping"):
        merge.merge_config(config_path)


def test_main_expands_user_path(tmp_path: Path, monkeypatch):
    home = tmp_path / "home"
    home.mkdir()
    config_path = home / ".hermes" / "config.yaml"
    monkeypatch.setenv("HOME", str(home))

    argv = ["merge-hermes-config.py", f"~/.hermes/config.yaml"]
    monkeypatch.setattr("sys.argv", argv)
    merge.main()

    assert config_path.is_file()
