"""Smoke tests for dot_local/bin/agent-stack-doctor with mocked tooling."""

from __future__ import annotations

import os
import subprocess
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
DOCTOR = REPO_ROOT / "dot_local" / "bin" / "executable_agent-stack-doctor"


def _write_fake_tool(bin_dir: Path, name: str, version_line: str) -> None:
    script = bin_dir / name
    script.write_text(
        f'#!/usr/bin/env bash\necho "{version_line}"\n',
        encoding="utf-8",
    )
    script.chmod(0o755)


def run_doctor(
    tmp_path: Path,
    *,
    install_skill: bool = True,
    hermes_skip_marker: str | None = None,
) -> subprocess.CompletedProcess[str]:
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    home = tmp_path / "home"
    home.mkdir()
    tools_root = home / ".local" / "share" / "agent-tools"
    tools_root.mkdir(parents=True)

    _write_fake_tool(bin_dir, "bd", "bd version 1.1.2")
    _write_fake_tool(bin_dir, "omp", "omp 17.2.10")
    _write_fake_tool(bin_dir, "pi", "pi 0.84.1")

    if hermes_skip_marker is None:
        hermes = bin_dir / "hermes"
        hermes.write_text(
            '#!/usr/bin/env bash\n'
            'case "$1" in\n'
            '  --version) echo "hermes v0.20.0 (2026.8.3)" ; exit 0 ;;\n'
            '  config)\n'
            '    if [ "$2" = "get" ] && [ "$3" = "worktree" ]; then echo true; exit 0; fi\n'
            '    if [ "$2" = "get" ] && [ "$3" = "skills.external_dirs" ]; then '
            'echo \'["~/.agents/skills"]\'; exit 0; fi\n'
            '    ;;\n'
            'esac\n'
            'exit 1\n',
            encoding="utf-8",
        )
        hermes.chmod(0o755)
    else:
        marker = tools_root / "hermes" / ".skip-profile"
        marker.parent.mkdir(parents=True, exist_ok=True)
        marker.write_text(f"{hermes_skip_marker}\n", encoding="utf-8")

    skill_dir = home / ".agents" / "skills" / "agent-work-coordination"
    if install_skill:
        skill_dir.mkdir(parents=True)
        (skill_dir / "SKILL.md").write_text("# skill\n", encoding="utf-8")

    env = os.environ.copy()
    env.update(
        {
            "HOME": str(home),
            "PATH": f"{bin_dir}:{env.get('PATH', '')}",
            "AGENT_TOOLS_ROOT": str(tools_root),
            "BD_DISABLE_METRICS": "1",
        }
    )

    return subprocess.run(
        ["bash", str(DOCTOR)],
        capture_output=True,
        text=True,
        env=env,
        check=False,
    )


def test_doctor_passes_with_expected_tooling(tmp_path: Path):
    result = run_doctor(tmp_path)
    assert result.returncode == 0
    assert "ok    bd" in result.stdout
    assert "ok    shared coordination skill" in result.stdout
    assert "0 failure(s)" in result.stdout


def test_doctor_fails_when_skill_missing(tmp_path: Path):
    result = run_doctor(tmp_path, install_skill=False)
    assert result.returncode != 0
    assert "fail  shared coordination skill is missing" in result.stdout


def test_doctor_warns_when_hermes_outside_profile(tmp_path: Path):
    result = run_doctor(tmp_path, hermes_skip_marker="unsupported-intel-macos")
    assert result.returncode == 0
    assert "warn  Hermes is outside this host profile" in result.stdout
