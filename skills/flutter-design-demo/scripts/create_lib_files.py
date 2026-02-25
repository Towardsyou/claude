#!/usr/bin/env python3
"""
Create Flutter lib/ files for design demo app.

Usage: python3 create_lib_files.py <project_name>

Creates all necessary Dart files in lib/ directory for a Flutter design demo.
"""

import sys
from pathlib import Path


def get_skill_path():
    """Get the path to the skill directory."""
    return Path(__file__).parent.parent


def create_pages_directory(project_path: Path) -> Path:
    """Create lib/pages/ directory."""
    pages_dir = project_path / "lib" / "pages"
    pages_dir.mkdir(parents=True, exist_ok=True)
    return pages_dir


def read_template(template_name: str) -> str:
    """Read template file from references/ directory."""
    skill_path = get_skill_path()
    template_path = skill_path / "references" / template_name
    return template_path.read_text()


def write_file(project_path: Path, file_path: str, content: str) -> None:
    """Write content to a file in the project."""
    full_path = project_path / file_path
    full_path.parent.mkdir(parents=True, exist_ok=True)
    full_path.write_text(content)
    print(f"  Created: {file_path}")


def create_demo_shell(project_path: Path) -> None:
    """Create lib/demo_shell.dart."""
    content = read_template("demo_shell.dart")
    write_file(project_path, "lib/demo_shell.dart", content)


def create_error_page(project_path: Path) -> None:
    """Create lib/error_page.dart."""
    content = read_template("error_page.dart")
    write_file(project_path, "lib/error_page.dart", content)


def create_sample_demo_page(project_path: Path) -> None:
    """Create lib/pages/sample_demo_page.dart."""
    content = read_template("sample_demo_page.dart")
    write_file(project_path, "lib/pages/sample_demo_page.dart", content)


def create_main_dart(project_path: Path) -> None:
    """Create lib/main.dart."""
    content = read_template("main.dart")
    write_file(project_path, "lib/main.dart", content)


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 create_lib_files.py <project_name>")
        print("Example: python3 create_lib_files.py flutter_design_demo")
        sys.exit(1)

    project_name = sys.argv[1]
    project_path = Path.cwd() / project_name

    if not project_path.exists():
        print(f"Error: Project directory '{project_name}' not found in current directory.")
        print(f"Expected path: {project_path}")
        print(f"Make sure to run 'flutter create --platforms=android,ios,macos,web {project_name}' first.")
        sys.exit(1)

    print(f"Creating Flutter demo files in: {project_path}")
    print()

    # Create pages directory
    create_pages_directory(project_path)

    # Create all files
    create_demo_shell(project_path)
    create_error_page(project_path)
    create_sample_demo_page(project_path)
    create_main_dart(project_path)

    print()
    print("Done! Created the following files:")
    print("  - lib/demo_shell.dart")
    print("  - lib/error_page.dart")
    print("  - lib/pages/sample_demo_page.dart")
    print("  - lib/main.dart")
    print()
    print("Next steps:")
    print(f"  1. cd {project_name}")
    print("  2. flutter run -d emulator-5554  # or -d macos, -d chrome")
    print("  3. Click the floating button to switch between demo pages")


if __name__ == "__main__":
    main()
