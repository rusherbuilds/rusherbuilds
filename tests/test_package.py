"""Offline checks for the deployable GitHub profile package."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


class ProfilePackageTests(unittest.TestCase):
    def test_identity_and_profile_readme(self):
        readme = (ROOT / "README.md").read_text(encoding="utf-8")
        self.assertIn("https://github.com/rusherbuilds", readme)
        self.assertIn("./assets/avatar.png", readme)
        self.assertIn("./assets/neon-banner.gif", readme)
        self.assertIn("PROJECTS_ROW_START", readme)
        self.assertIn("TOOLS_ROW_START", readme)

    def test_supplied_artwork_is_valid_png_in_both_destinations(self):
        avatar = (ROOT / "assets/avatar.png").read_bytes()
        page_avatar = (ROOT / "docs/avatar.png").read_bytes()
        self.assertTrue(avatar.startswith(b"\x89PNG\r\n\x1a\n"))
        self.assertEqual(avatar, page_avatar)

    def test_all_local_page_assets_are_in_pages_folder(self):
        page = (ROOT / "docs/index.html").read_text(encoding="utf-8")
        for name in ["avatar.png", "style.css", "config.js", "app.js", "favicon.svg"]:
            self.assertTrue((ROOT / "docs" / name).is_file(), name)
            self.assertIn(f'\"{name}\"', page)

    def test_publisher_guards_and_preview_mode(self):
        sh = (ROOT / "scripts/APPLY_LINUX_MAC.sh").read_text(encoding="utf-8")
        ps = (ROOT / "scripts/APPLY_WINDOWS.ps1").read_text(encoding="utf-8")
        self.assertIn("gh api user", sh)
        self.assertIn("gh api user", ps)
        self.assertIn("--dry-run", sh)
        self.assertIn("-DryRun", ps)
        for source in (sh, ps):
            self.assertIn("APPLY", source)
            self.assertIn("rusherbuilds", source)
            self.assertNotIn("push --force", source)
            self.assertNotIn("reset --hard", source)

    def test_workflow_and_docs_present(self):
        self.assertTrue((ROOT / ".github/workflows/contribution-arcade.yml").is_file())
        self.assertTrue((ROOT / ".github/workflows/validate-profile.yml").is_file())
        self.assertIn("gh auth login", (ROOT / "DEPLOY_COMMANDS_AR.md").read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
