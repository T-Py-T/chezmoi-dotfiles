"""Regression tests for ERROR/WARNING counting in check-nvim-health.sh."""

from __future__ import annotations

import subprocess
from pathlib import Path

FIXTURE = Path(__file__).parent / "fixtures" / "nvim-health-mixed.txt"


def _count(pattern: str, path: Path) -> int:
    script = (
        f"LC_ALL=C strings '{path}' | awk '/{pattern}/{{c++}} END{{print c+0}}'"
    )
    result = subprocess.run(
        ["bash", "-c", script],
        capture_output=True,
        text=True,
        check=True,
    )
    return int(result.stdout.strip())


def test_fixture_error_warning_ok_counts():
    assert _count("ERROR", FIXTURE) == 1
    assert _count("WARNING", FIXTURE) == 1
    assert _count(" OK ", FIXTURE) == 2


def test_check_nvim_health_script_matches_fixture_logic(tmp_path: Path):
    """Exercise the same awk pipeline the shell script uses on synthetic output."""
    health = tmp_path / "health.txt"
    health.write_text(FIXTURE.read_text(encoding="utf-8"), encoding="utf-8")

    error_count = _count("ERROR", health)
    assert error_count > 0
