"""Unit tests for merge-hermes-config helper logic (no live Hermes install)."""

from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path

import pytest
import yaml

REPO_ROOT = Path(__file__).resolve().parents[2]
MODULE_PATH = REPO_ROOT / "scripts" / "merge-hermes-config.py"


def _load_module():
    spec = importlib.util.spec_from_file_location("merge_hermes_config", MODULE_PATH)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


merge = _load_module()


@pytest.mark.parametrize(
    ("value", "expected"),
    [
        (None, []),
        (["~/.agents/skills"], ["~/.agents/skills"]),
        ('["a", "b"]', ["a", "b"]),
        ("plain-path", ["plain-path"]),
    ],
)
def test_external_dirs_normalization(value, expected) -> None:
    assert merge._external_dirs(value) == expected


def test_external_dirs_rejects_invalid_type() -> None:
    with pytest.raises(TypeError):
        merge._external_dirs(42)


def test_merge_config_refuses_symlink(tmp_path: Path) -> None:
    target = tmp_path / "config.yaml"
    target.write_text("worktree: false\n", encoding="utf-8")
    link = tmp_path / "link.yaml"
    link.symlink_to(target)
    with pytest.raises(RuntimeError, match="symlinked"):
        merge.merge_config(link)


def test_merge_config_merges_skills_and_worktree_flags(tmp_path: Path) -> None:
    config = tmp_path / "config.yaml"
    config.write_text(
        yaml.safe_dump({"skills": {"external_dirs": ["/custom"]}}),
        encoding="utf-8",
    )
    merge.merge_config(config)
    loaded = yaml.safe_load(config.read_text(encoding="utf-8"))
    assert loaded["worktree"] is True
    assert loaded["worktree_sync"] is True
    assert loaded["skills"]["write_approval"] is True
    dirs = loaded["skills"]["external_dirs"]
    assert "/custom" in dirs
    assert merge.SHARED_SKILLS_DIR in dirs
    assert dirs.index("/custom") < dirs.index(merge.SHARED_SKILLS_DIR)


def test_merge_config_accepts_json_string_external_dirs(tmp_path: Path) -> None:
    config = tmp_path / "config.yaml"
    config.write_text("skills:\n  external_dirs: '[\"/only\"]'\n", encoding="utf-8")
    merge.merge_config(config)
    loaded = yaml.safe_load(config.read_text(encoding="utf-8"))
    assert json.loads('["/only"]')[0] in loaded["skills"]["external_dirs"]
