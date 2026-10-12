"""Regression tests for helper scripts not covered by open draft PRs #23–#28."""

from __future__ import annotations

import importlib.util
import os
import subprocess
import tempfile
import textwrap
import unittest
from pathlib import Path

import yaml

_REPO_ROOT = Path(__file__).resolve().parents[1]
_MERGE_HELPER = _REPO_ROOT / "scripts" / "merge-hermes-config.py"
_HEALTH_SCRIPT = _REPO_ROOT / "scripts" / "check-nvim-health.sh"


def _load_merge_module() -> object:
    spec = importlib.util.spec_from_file_location("merge_hermes_config", _MERGE_HELPER)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {_MERGE_HELPER}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


_merge = _load_merge_module()
_external_dirs = _merge._external_dirs
merge_config = _merge.merge_config


class MergeHermesExternalDirsRegressionTests(unittest.TestCase):
    def test_null_list_entries_are_ignored_not_stringified(self) -> None:
        self.assertEqual(_external_dirs([None, "/valid"]), ["/valid"])
        self.assertEqual(_external_dirs(["/a", None, "/b"]), ["/a", "/b"])

    def test_merge_skips_null_external_dir_yaml_entries(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            config_path = Path(tmp) / "config.yaml"
            config_path.write_text(
                yaml.safe_dump(
                    {"skills": {"external_dirs": [None, "~/custom"]}},
                    sort_keys=False,
                ),
                encoding="utf-8",
            )
            merge_config(config_path)
            loaded = yaml.safe_load(config_path.read_text(encoding="utf-8"))
            self.assertEqual(
                loaded["skills"]["external_dirs"],
                ["~/custom", "~/.agents/skills"],
            )
            self.assertNotIn("None", loaded["skills"]["external_dirs"])


class CheckNvimHealthRegressionTests(unittest.TestCase):
    def _run_health_script(self, health_body: str) -> subprocess.CompletedProcess[str]:
        with tempfile.TemporaryDirectory() as tmp:
            stub_bin = Path(tmp) / "bin"
            stub_bin.mkdir()
            nvim_stub = stub_bin / "nvim"
            nvim_stub.write_text(
                textwrap.dedent(
                    """\
                    #!/usr/bin/env bash
                    set -euo pipefail
                    out=""
                    prev=""
                    for arg in "$@"; do
                      if [ "$prev" = "-c" ]; then
                        case "$arg" in
                          *w!*)
                            out="${arg##*w! }"
                            ;;
                        esac
                      fi
                      prev="$arg"
                    done
                    printf '%s' "$NVIM_HEALTH_FIXTURE" >"$out"
                    exit 0
                    """
                ),
                encoding="utf-8",
            )
            nvim_stub.chmod(0o755)
            env = os.environ.copy()
            env["PATH"] = f"{stub_bin}:{env.get('PATH', '')}"
            env["NVIM_HEALTH_FIXTURE"] = health_body
            return subprocess.run(
                ["bash", str(_HEALTH_SCRIPT)],
                capture_output=True,
                text=True,
                env=env,
                check=False,
            )

    def test_path_segment_error_does_not_fail_check(self) -> None:
        body = textwrap.dedent(
            """\
            nvim: health#check
            ripgrep: /opt/ERROR/tool/bin/rg
            vim.lsp:                                                                    OK
            """
        )
        result = self._run_health_script(body)
        self.assertEqual(result.returncode, 0, msg=result.stdout + result.stderr)
        self.assertIn("PASS", result.stdout)

    def test_real_error_column_still_fails(self) -> None:
        body = "plugin.foo:                                                                ERROR missing binary\n"
        result = self._run_health_script(body)
        self.assertEqual(result.returncode, 1, msg=result.stdout + result.stderr)
        self.assertIn("FAIL", result.stdout)
        self.assertIn("missing binary", result.stdout)


if __name__ == "__main__":
    unittest.main()
