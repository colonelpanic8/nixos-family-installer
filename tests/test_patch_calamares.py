import ast
from pathlib import Path
import tempfile
import unittest

from patch_calamares import patch


class PatchTests(unittest.TestCase):
    def test_preserves_partition_mount_users_and_unmount_jobs(self):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory)
            (source / "config").mkdir()
            (source / "modules/nixos").mkdir(parents=True)
            settings = source / "config/settings.conf"
            settings.write_text(
                "instances:\n- module: nixos\nsequence:\n- show:\n"
                "  - keyboard\n  - users\n- exec:\n"
                "  - partition\n  - mount\n  - nixos\n  - users\n  - umount\n"
            )
            job = source / "modules/nixos/main.py"
            job.write_text(
                "def run():\n    # build nixos-install command\n"
                '    nixosInstallCmd = [\n            "--no-root-passwd",\n    ]\n'
                "    libcalamares.job.setprogress(INSTALL_PROGRESS_END)\n"
            )
            patch(source, "/nix/store/helper/bin/family-prepare-target")
            self.assertIn("  - packagechooser@owner\n  - users", settings.read_text())
            self.assertIn(
                "  - partition\n  - mount\n  - nixos\n  - users\n  - umount\n",
                settings.read_text(),
            )
            text = job.read_text()
            ast.parse(text)
            self.assertIn('"--flake"', text)
            self.assertIn('gs.value("username")', text)
            self.assertIn('gs.value("packagechooser_owner")', text)
            self.assertIn('"--finish"', text)

    def test_upstream_layout_change_fails_loudly(self):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory)
            (source / "config").mkdir()
            (source / "config/settings.conf").write_text("new upstream format")
            with self.assertRaisesRegex(ValueError, "integration point"):
                patch(source, "/helper")


if __name__ == "__main__":
    unittest.main()
