---
name: flutter-design-demo
description: Create Flutter design demo apps with floating button page selector, client injection, and red screen error detection. Use when user asks to create Flutter demo apps, design showcases, UI component previews, or mobile prototyping with Flutter.
compatibility: Requires `flutter` CLI command available in PATH
---

# Flutter Design Demo Creator

Create Flutter design demo apps for showcasing UI components with page switching, client dependency injection, and automated error detection.

## When to Use

Use this skill when:
- User asks to create a "Flutter demo app" or "design showcase"
- User wants to preview UI components or designs in Flutter
- User mentions "floating button" or "page selector" for Flutter
- User needs a mobile app prototype in Flutter
- User wants to create "demo screens" or "UI showcases"

## What It Creates

A complete Flutter project structure with:
- `DemoShell` widget with floating button page selector
- `ErrorPage` for red screen detection (Maestro testing support)
- Sample demo page showing the client injection pattern
- Full project structure (Android, iOS, macOS, Web platforms)

## Deterministic Project Creation

**IMPORTANT**: Always use `flutter create` command first, then modify the lib/ directory. Never manually create Android/iOS platform files.

### Step 1: Create Project Base

Run this exact command:

```bash
flutter create --platforms=android,ios,macos,web flutter_design_demo
```

Verify exit code is 0 before proceeding.

### Step 2: Create lib/ Files

Create these files in `lib/` directory using the `scripts/create_lib_files.py` script:

```bash
python3 <skill-path>/scripts/create_lib_files.py flutter_design_demo
```

This script creates:
- `lib/demo_shell.dart` - The floating button page selector
- `lib/error_page.dart` - Red screen error detection
- `lib/pages/sample_demo_page.dart` - Sample demo page
- `lib/main.dart` - App entry point with error handling

### Step 3: Clean Test Directory

```bash
rm -rf flutter_design_demo/test
```

### Step 4: Run the App

```bash
cd flutter_design_demo
flutter run -d emulator-5554  # or use -d macos, -d chrome, etc.
```

## File Contents Reference

The script uses templates from `references/` directory. To customize:

- **DemoShell styles**: Edit `references/demo_shell.dart`
- **Error page appearance**: Edit `references/error_page.dart`
- **Sample page**: Edit `references/sample_demo_page.dart`
- **Main template**: Edit `references/main.dart`

## Creating Custom Demo Pages

After project creation, add your demo pages in `lib/pages/`:

```dart
class MyCustomPage extends StatelessWidget {
  final Map<String, Function> client;

  const MyCustomPage({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => client['my_action']?.call(),
          child: const Text('Action'),
        ),
      ),
    );
  }
}
```

Then add to `main.dart` pages list:

```dart
final pages = [
  DemoPageConfig(
    title: 'My Custom Page',
    builder: (context) => MyCustomPage(client: client),
  ),
];
```

## Multiple Page States Pattern

Show different states of the same component:

```dart
final pages = [
  DemoPageConfig(
    title: 'List (With Data)',
    builder: (context) => MyListPage(client: client, items: sampleData),
  ),
  DemoPageConfig(
    title: 'List (Empty)',
    builder: (context) => MyListPage(client: client, items: []),
  ),
  DemoPageConfig(
    title: 'List (Loading)',
    builder: (context) => MyListPage(client: client, isLoading: true),
  ),
];
```

## Client Injection Pattern

Define client functions in `main.dart`:

```dart
final client = <String, Function>{
  'fetch_data': () async {
    await Future.delayed(const Duration(seconds: 1));
    return ['item1', 'item2', 'item3'];
  },
  'show_message': (message) {
    debugPrint('Message: $message');
  },
};
```

Call from pages:

```dart
client['show_message']?.call('Hello');
final data = await client['fetch_data']?.call();
```

## Platform-Specific Running

| Platform | Command |
|----------|---------|
| Android | `flutter run -d emulator-5554` |
| iOS | `flutter run -d ios` |
| macOS | `flutter run -d macos` |
| Web | `flutter run -d chrome` |

## Error Detection for Testing

The `ErrorPage` widget uses `Semantics(label: 'ERROR_SCREEN_DETECTED')` for Maestro testing.

In your `visual_validation.yaml`:

```yaml
# Assert no red screen errors
- assertNotVisible:
    label: "ERROR_SCREEN_DETECTED"
```

## Troubleshooting

**Project creation fails**: Ensure Flutter SDK is installed and in PATH. Run `flutter doctor` to check.

**Platform files missing**: Always use `flutter create` - never manually copy Android/iOS files.

**Maestro tests fail**: Check that `ErrorPage` is properly configured in `main.dart` builder.

## Skill End Condition

This skill completes after:
1. Running `flutter create` successfully
2. Creating all lib/ files via script
3. Cleaning test directory
4. Verifying project structure

No code execution or app running is required unless user explicitly requests it.
