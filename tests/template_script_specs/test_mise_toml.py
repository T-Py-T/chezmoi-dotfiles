"""Parse and pin checks for mise.toml runtime versions."""

from __future__ import annotations

import re
from pathlib import Path

import tomllib

MISE_TOML = Path(__file__).resolve().parents[2] / "mise.toml"


def test_mise_toml_parses() -> None:
    data = tomllib.loads(MISE_TOML.read_text(encoding="utf-8"))
    tools = data["tools"]
    assert set(tools) == {"python", "go", "rust", "node"}


def test_runtime_versions_are_pinned_semver() -> None:
    data = tomllib.loads(MISE_TOML.read_text(encoding="utf-8"))
    semver = re.compile(r"^\d+\.\d+\.\d+$")
    for name, version in data["tools"].items():
        assert semver.match(version), f"{name} version not pinned: {version}"
