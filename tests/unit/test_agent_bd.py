"""CLI regression tests for dot_local/bin/agent-bd."""

from __future__ import annotations

import os
import subprocess
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[2]
AGENT_BD = REPO_ROOT / "dot_local" / "bin" / "executable_agent-bd"


def run_agent_bd(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    *args: str,
    env: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[str]:
    fake_bd = tmp_path / "bd"
    fake_bd.write_text(
        "#!/usr/bin/env bash\n"
        'echo "actor=$BD_ACTOR"\n'
        'echo "beads=$BEADS_ACTOR"\n'
        'printf "%s\\n" "$@"\n',
        encoding="utf-8",
    )
    fake_bd.chmod(0o755)

    run_env = os.environ.copy()
    run_env["PATH"] = f"{tmp_path}:{run_env.get('PATH', '')}"
    if env:
        run_env.update(env)
    monkeypatch.delenv("BD_ACTOR", raising=False)
    monkeypatch.delenv("BEADS_ACTOR", raising=False)

    return subprocess.run(
        ["bash", str(AGENT_BD), *args],
        capture_output=True,
        text=True,
        env=run_env,
        check=False,
    )


def test_usage_when_args_missing():
    result = subprocess.run(
        ["bash", str(AGENT_BD)],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 2
    assert "Usage: agent-bd" in result.stderr


def test_sanitizes_harness_and_sets_actor(tmp_path: Path, monkeypatch: pytest.MonkeyPatch):
    result = run_agent_bd(
        tmp_path,
        monkeypatch,
        "omp/worker",
        "id#1",
        "--",
        "ready",
        "--json",
        env={"USER": "tester"},
    )
    assert result.returncode == 0
    assert "actor=tester@" in result.stdout
    assert "omp-worker:id-1" in result.stdout
    assert "ready" in result.stdout
    assert "BD_DISABLE_METRICS=1" not in result.stdout  # exported, not printed


def test_missing_bd_exits_127(tmp_path: Path, monkeypatch: pytest.MonkeyPatch):
    env = os.environ.copy()
    env["PATH"] = f"{tmp_path}:/usr/bin:/bin"
    result = subprocess.run(
        ["/bin/bash", str(AGENT_BD), "h", "w", "--", "status"],
        capture_output=True,
        text=True,
        env=env,
        check=False,
    )
    assert result.returncode == 127
    assert "bd is not installed" in result.stderr
