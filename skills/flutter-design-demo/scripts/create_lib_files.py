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
        print("Usage: python3 create_lib_files.py <project_path>")
        print("Examples:")
        print("  python3 create_lib_files.py .          # Create in current directory")
        print("  python3 create_lib_files.py flutter_demo # Create in flutter_demo subdirectory")
        sys.exit(1)

    project_path_arg = sys.argv[1]
    
    # Handle '.' for current directory or specific path
    if project_path_arg == '.':
        project_path = Path.cwd()
    else:
        project_path = Path.cwd() / project_path_arg

    if not project_path.exists():
        print(f"Error: Project directory '{project_path_arg}' not found.")
        print(f"Expected path: {project_path}")
        print(f"Make sure to run 'flutter create --platforms=android,ios,macos,web .' first.")
        sys.exit(1)

    # Verify it's a Flutter project
    pubspec = project_path / "pubspec.yaml"
    if not pubspec.exists():
        print(f"Error: No pubspec.yaml found in {project_path}")
        print("This doesn't appear to be a Flutter project directory.")
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
    if project_path_arg == '.':
        print("  1. flutter run -d emulator-5554  # or -d macos, -d chrome")
    else:
        print(f"  1. cd {project_path_arg}")
        print("  2. flutter run -d emulator-5554  # or -d macos, -d chrome")
    print("  3. Click the floating button to switch between demo pages")


if __name__ == "__main__":
    main()
