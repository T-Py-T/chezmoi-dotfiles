#!/usr/bin/env python3
"""Parse committed TOML configs the same way CI tooling does."""

from __future__ import annotations

import tomllib
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


class TomlContractTests(unittest.TestCase):
    def test_mise_pins_language_runtimes(self) -> None:
        data = tomllib.loads((ROOT / "mise.toml").read_text(encoding="utf-8"))
        tools = data["tools"]
        for key in ("python", "go", "rust", "node"):
            self.assertIn(key, tools)
            self.assertTrue(tools[key])

    def test_starship_has_character_section(self) -> None:
        data = tomllib.loads(
            (ROOT / "dot_config" / "starship.toml").read_text(encoding="utf-8")
        )
        self.assertIn("character", data)
        self.assertIn("format", data)

    def test_neru_config_loads(self) -> None:
        data = tomllib.loads(
            (ROOT / "dot_config" / "neru" / "config.toml").read_text(encoding="utf-8")
        )
        self.assertTrue(data["general"]["passthrough_unbounded_keys"])
        self.assertIn("hotkeys", data)


if __name__ == "__main__":
    unittest.main(verbosity=2)
