#!/usr/bin/env python3
"""Agent skill metadata stays valid YAML with required interface keys."""

from __future__ import annotations

import unittest
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[2]
OPENAI_YAML = (
    ROOT
    / "dot_agents"
    / "skills"
    / "agent-work-coordination"
    / "agents"
    / "openai.yaml"
)


class AgentSkillYamlTests(unittest.TestCase):
    def test_openai_agent_interface(self) -> None:
        data = yaml.safe_load(OPENAI_YAML.read_text(encoding="utf-8"))
        interface = data["interface"]
        for key in ("display_name", "short_description", "default_prompt"):
            self.assertIn(key, interface)
            self.assertTrue(str(interface[key]).strip())


if __name__ == "__main__":
    unittest.main(verbosity=2)
