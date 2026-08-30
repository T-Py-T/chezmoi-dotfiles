"""Merge portable, non-secret coordination defaults into Hermes config."""

from __future__ import annotations

import argparse
import json
import os
import tempfile
from pathlib import Path
from typing import Any

import yaml

SHARED_SKILLS_DIR = "~/.agents/skills"


def _external_dirs(value: Any) -> list[str]:
    if value is None:
        return []
    if isinstance(value, list):
        return [str(item) for item in value]
    if isinstance(value, str):
        try:
            decoded = json.loads(value)
        except json.JSONDecodeError:
            return [value]
        if isinstance(decoded, list):
            return [str(item) for item in decoded]
        return [value]
    raise TypeError("skills.external_dirs must be a list or string")


def merge_config(config_path: Path) -> None:
    if config_path.is_symlink():
        raise RuntimeError(
            "Refusing to replace a symlinked Hermes config. Add the portable "
            "settings to its existing source of truth, then apply with "
            "SKIP_HERMES_CONFIG_MERGE=1."
        )

    if config_path.exists():
        loaded = yaml.safe_load(config_path.read_text(encoding="utf-8"))
        config: dict[str, Any] = {} if loaded is None else loaded
    else:
        config = {}

    if not isinstance(config, dict):
        raise TypeError("Hermes config root must be a mapping")

    config["worktree"] = True
    config["worktree_sync"] = True

    skills = config.setdefault("skills", {})
    if not isinstance(skills, dict):
        raise TypeError("Hermes skills config must be a mapping")

    dirs = _external_dirs(skills.get("external_dirs"))
    skills["external_dirs"] = list(dict.fromkeys([*dirs, SHARED_SKILLS_DIR]))
    skills["write_approval"] = True

    config_path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary_name = tempfile.mkstemp(
        dir=config_path.parent, prefix=f".{config_path.name}.", text=True
    )
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as temporary_file:
            yaml.safe_dump(
                config,
                temporary_file,
                allow_unicode=True,
                default_flow_style=False,
                sort_keys=False,
            )
        os.chmod(temporary_name, 0o600)
        os.replace(temporary_name, config_path)
    except BaseException:
        if os.path.exists(temporary_name):
            os.unlink(temporary_name)
        raise


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("config_path", type=Path)
    args = parser.parse_args()
    merge_config(args.config_path.expanduser())


if __name__ == "__main__":
    main()
