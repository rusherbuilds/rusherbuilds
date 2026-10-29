"""Behavioral smoke tests for the no-write Bash preflight."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
PUBLISHER = ROOT / "scripts/APPLY_LINUX_MAC.sh"


class LinuxPublisherSmokeTests(unittest.TestCase):
    def run_preflight(self, scenario):
        with tempfile.TemporaryDirectory() as temp:
            temp_dir = Path(temp)
            action_log = temp_dir / "mutations.log"
            fake_gh = temp_dir / "gh"
            fake_gh.write_text(
                """#!/usr/bin/env bash
set -eu
if [[ "$1" == api && "$2" == user && "$4" == .login ]]; then
    [[ "$SCENARIO" == wrong_account ]] && echo someone_else || echo rusherbuilds
elif [[ "$1" == api && "$2" == repos/* ]]; then
    case "$SCENARIO" in
       absent) echo 'gh: Not Found (HTTP 404)' >&2; exit 1 ;;
       network) echo 'gh: connection refused' >&2; exit 1 ;;
       private) echo private ;;
       *) echo public ;;
    esac
else
    echo "$*" >> "$ACTION_LOG"
    exit 9
fi
""",
                encoding="utf-8",
            )
            fake_gh.chmod(0o755)
            env = os.environ.copy()
            env.update(
                {
                    "PATH": str(temp_dir) + os.pathsep + env.get("PATH", ""),
                    "SCENARIO": scenario,
                    "ACTION_LOG": str(action_log),
                }
            )
            result = subprocess.run(
                ["bash", str(PUBLISHER), "--dry-run"],
                text=True,
                capture_output=True,
                cwd=ROOT,
                env=env,
                timeout=10,
                check=False,
            )
            return result, action_log.exists()

    def test_new_repository_dry_run_does_not_create_or_push(self):
        result, mutated = self.run_preflight("absent")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("DRY RUN COMPLETE", result.stdout)
        self.assertFalse(mutated)

    def test_wrong_account_stops_without_mutation(self):
        result, mutated = self.run_preflight("wrong_account")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Wrong GitHub account", result.stderr)
        self.assertFalse(mutated)

    def test_network_error_is_not_treated_as_missing_repository(self):
        result, mutated = self.run_preflight("network")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Could not inspect", result.stderr)
        self.assertFalse(mutated)

    def test_private_repository_does_not_become_public(self):
        result, mutated = self.run_preflight("private")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("refusing to change its visibility", result.stderr)
        self.assertFalse(mutated)


if __name__ == "__main__":
    unittest.main()
