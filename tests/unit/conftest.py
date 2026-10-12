"""Shared fixtures for local unit tests."""

from __future__ import annotations

import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
SCRIPTS_DIR = REPO_ROOT / "scripts"


def load_merge_hermes_module():
    """Import scripts/merge-hermes-config.py despite the hyphenated filename."""
    import importlib.util

    path = SCRIPTS_DIR / "merge-hermes-config.py"
    spec = importlib.util.spec_from_file_location("merge_hermes_config", path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    sys.modules["merge_hermes_config"] = module
    spec.loader.exec_module(module)
    return module
