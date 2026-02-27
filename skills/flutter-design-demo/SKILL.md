---
name: flutter-design-demo
description: 创建用于展示设计的 Flutter Demo App，包含半透明悬浮按钮切换界面、Client 注入机制和参数化页面创建功能。当用户需要创建 Flutter 设计展示 Demo 时使用。
compatibility: 需要 `flutter` CLI 命令在 PATH 中可用
---

# Flutter 设计展示 Demo

创建用于展示 UI 组件设计的 Flutter Demo App，支持多界面切换、Client 依赖注入和参数化展示。

## 核心功能

- 半透明悬浮按钮（FAB）切换界面
- 点击展开为居中的界面选择器
- 点击外部区域恢复为圆形按钮
- 无选中界面时显示 Placeholder
- Client 对象注入，页面通过 `client['feature'](params)` 调用
- 支持同一组件创建多个不同参数的展示页
- 错误红屏检测（支持 Maestro 测试）

## 确定性项目创建流程

### 步骤 1: 使用 flutter create 创建项目

**务必使用 `flutter create` 命令**，这是最可靠的方式：

```bash
flutter create --platforms=android,ios,macos,web flutter_design_demo
```

**为什么不要手动创建 Android 配置？**

手动创建容易出错，常见问题包括：

- Gradle 版本与 Java 版本不兼容（如 Java 21 需 Gradle 8.5+）
- AndroidManifest.xml 拼写错误（如 `LAUNCHER` 错写为 `LAINGER`）
- styles.xml 缺少 `LaunchTheme` 定义
- Gradle 插件版本不匹配
- 文件路径或依赖关系问题

`flutter create` 会自动生成与当前 Flutter 版本兼容的所有平台配置。

### 步骤 2: 创建 lib/ 目录文件

使用 Python 脚本自动创建所有 Dart 文件：

```bash
python3 /Users/zhaoyu.ming/.claude/skills/flutter-design-demo/scripts/create_lib_files.py flutter_design_demo
```

此脚本会创建：

- `lib/demo_shell.dart` - 悬浮按钮界面选择器
- `lib/error_page.dart` - 红屏错误检测页面
- `lib/pages/sample_demo_page.dart` - 示例展示页面
- `lib/main.dart` - 应用入口（带错误处理配置）

### 步骤 3: 清理 test 目录

```bash
rm -rf flutter_design_demo/test
```

### 步骤 4: 运行应用

```bash
cd flutter_design_demo
flutter run -d emulator-5554  # 或使用 -d macos, -d chrome 等
```

## 项目结构

```
flutter_design_demo/          # 项目根目录
├── android/                 # Android 平台配置（flutter create 自动生成）
├── ios/                     # iOS 平台配置
├── macos/                   # macOS 平台配置
├── web/                     # Web 平台配置
├── lib/                     # Dart 代码
│   ├── main.dart           # 应用入口
│   ├── demo_shell.dart     # Demo 外壳（悬浮按钮切换）
│   ├── error_page.dart     # 错误页面（红屏检测）
│   └── pages/
│       └── sample_demo_page.dart
└── pubspec.yaml
```

**注意**：所有项目文件应放在单独的 `flutter_design_demo/` 文件夹内，而非项目根目录。

## 核心组件说明

### DemoShell

`DemoShell` 是根组件，提供悬浮按钮切换界面功能：

```dart
DemoShell(
  pages: [
    DemoPageConfig(title: '界面1', builder: (_) => Page1()),
    DemoPageConfig(title: '界面2', builder: (_) => Page2()),
  ],
  fabColor: Colors.blue.withOpacity(0.7),  // 自定义悬浮按钮颜色
  selectorBackgroundColor: Colors.white,     // 自定义选择器背景
)
```

**交互逻辑**：

- 点击悬浮按钮 → 展开界面选择器（居中弹窗）
- 点击某个界面 → 切换到该界面，选择器收起
- 点击外部区域 → 仅收起选择器，不切换界面

### Client 注入模式

在 `main.dart` 中定义 Client 对象，注入业务功能：

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

在页面中通过 Client 调用：

```dart
class FeatureDemoPage extends StatelessWidget {
  final Map<String, Function> client;

  const FeatureDemoPage({super.key, required this.client});

  void _handleAction() {
    client['show_message']?.call('Hello');
    final data = await client['fetch_data']?.call();
  }
}
```

### 参数化页面创建

展示同一组件的不同状态：

```dart
final pages = [
  // 有数据状态
  DemoPageConfig(
    title: '列表（有数据）',
    builder: (context) => ListDemo(
      client: client,
      items: sampleData,
    ),
  ),
  // 空状态
  DemoPageConfig(
    title: '列表（空状态）',
    builder: (context) => ListDemo(
      client: client,
      items: [],
    ),
  ),
  // 加载中
  DemoPageConfig(
    title: '列表（加载中）',
    builder: (context) => ListDemo(
      client: client,
      isLoading: true,
    ),
  ),
];
```

## 错误处理与红屏检测

### ErrorPage 说明

脚本创建的 `error_page.dart` 包含红屏错误检测功能，使用 `Semantics(label: 'ERROR_SCREEN_DETECTED')` 标记。

**Maestro 测试中的错误检测**：

```yaml
# 检测红屏错误 - 使用 ERROR_SCREEN_DETECTED 标记
# 注意：Maestro 使用 'text' 匹配 Flutter Semantics label
- assertNotVisible:
    text: "ERROR_SCREEN_DETECTED"
```

### main.dart 错误处理配置

脚本创建的 `main.dart` 已配置错误处理：

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ...
      builder: (context, widget) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return ErrorPage(errorDetails: errorDetails);
        };
        return widget!;
      },
      home: DemoShell(pages: pages),
    );
  }
}
```

## 自定义演示页面

创建新的演示页面：

```dart
class MyCustomPage extends StatelessWidget {
  final Map<String, Function> client;

  const MyCustomPage({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的页面')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => client['my_action']?.call(),
          child: const Text('执行操作'),
        ),
      ),
    );
  }
}
```

然后在 `main.dart` 中添加：

```dart
final pages = [
  DemoPageConfig(
    title: '我的自定义页面',
    builder: (context) => MyCustomPage(client: client),
  ),
];
```

## 多平台运行

| 平台 | 命令 |
|------|------|
| Android | `flutter run -d emulator-5554` |
| iOS | `flutter run -d ios` |
| macOS | `flutter run -d macos` |
| Web | `flutter run -d chrome` |

## Maestro 测试配置规范

在使用 Maestro 进行视觉验证测试时，生成的 `visual_validation.yaml` 文件需遵循以下要点：

### 1. 点击操作后添加等待时间

每个 `tapOn` 操作后必须添加 `waitForAnimationToEnd` 或 `sleep` 指令：

```yaml
- tapOn:
    text: "界面1"
- waitForAnimationToEnd:  # 或 sleep: 1000
- assertVisible:
    text: ".*页面内容.*"
```

### 2. 支持界面列表滚动

当界面选择器中的项目过多时，需要添加滚动操作：

```yaml
- scrollUntilVisible:
    element:
      text: ".*目标界面.*"
    direction: DOWN
    timeout: 5000
```

### 3. 错误检测断言

通过 ErrorPage 的 Semantics label 检测 Flutter 红屏错误：

```yaml
# 检测红屏错误 - 使用 ERROR_SCREEN_DETECTED 标记
# 注意：Maestro 使用 'text' 匹配 Flutter Semantics label
- assertNotVisible:
    text: "ERROR_SCREEN_DETECTED"
```

这种方法比文本匹配更可靠，因为：

- 不受 URL 换行影响
- 统一使用 Semantics label 标记
- 覆盖所有 Flutter 构建错误

### 4. accessibilityText 匹配规范

使用 `tapOn` 时，文本匹配应遵循以下规则：

- **使用部分匹配**：避免由于空格、换行或重复字符导致的匹配失败
- **去掉开头的 `.*`**：避免类似 "Settings.*" 和 ".*Album Settings.*" 的匹配冲突
- **保留结尾的 `.*`**：用于匹配后续可能的变化（如换行、空格）
- **避免完全匹配**：不要使用精确字符串匹配

```yaml
# ✅ 推荐：去掉开头的 .*，保留结尾的 .*
- tapOn:
    text: "用户卡片.*"
- tapOn:
    text: "Settings.*"

# ❌ 避免：开头的 .* 会导致冲突
- tapOn:
    text: ".*Settings.*"  # 会同时匹配 "Settings" 和 "Album Settings"

# ❌ 避免：完全匹配，容易因空格或格式变化失败
- tapOn:
    text: "用户卡片"

# ✅ 推荐：部分匹配
- assertVisible:
    text: "这是.*页面.*内容.*"
```

### 5. 悬浮按钮选择器规范

DemoShell 的悬浮按钮使用 `Semantics(identifier: 'fab_button')` 包裹，因此在 Maestro 中应使用 `id` 选择器：

```yaml
# ✅ 推荐：使用 id 匹配悬浮按钮
- tapOn:
    id: "fab_button"

# ❌ 避免：使用文本匹配可能失败
- tapOn: "悬浮按钮"
```

### 6. 界面列表滚动处理

当界面数量超过 15 个时，选择器中的列表需要滚动才能看到后面的选项。从第 15 个界面开始，需要在 `tapOn` 之前添加 `scrollUntilVisible`：

```yaml
# 前 14 个界面可以直接点击
- tapOn:
    id: "fab_button"
- waitForAnimationToEnd:
    timeout: 1000
- tapOn: "Page 14.*"

# 第 15 个及以后的界面需要滚动
- tapOn:
    id: "fab_button"
- waitForAnimationToEnd:
    timeout: 1000
- scrollUntilVisible:
    element: "Page 15.*"
    timeout: 3000
- tapOn: "Page 15.*"
```

### 完整示例

```yaml
appId: com.example.flutter_design_demo
---
# 1. 启动应用并等待
- launchApp
- waitForAnimationToEnd:
    timeout: 5000

# 2. 验证应用启动时没有红屏错误
# 注意：Maestro 使用 'text' 匹配 Flutter Semantics label
- assertNotVisible:
    text: "ERROR_SCREEN_DETECTED"

# 3. 打开界面选择器（点击悬浮按钮，使用 id 选择器）
- tapOn:
    id: "fab_button"
- waitForAnimationToEnd:
    timeout: 1000

# 4. 滚动查找并点击目标界面
- scrollUntilVisible:
    element:
      text: "列表（空状态）.*"
    direction: DOWN
- tapOn: "列表（空状态）.*"
- waitForAnimationToEnd:
    timeout: 1000

# 5. 检测红屏错误
- assertNotVisible:
    text: "ERROR_SCREEN_DETECTED"

# 6. 验证预期内容渲染正确
- assertVisible:
    text: "暂无数据.*"
- assertVisible:
    text: "空状态提示.*"

# 7. 截图
- takeScreenshot: screenshots/empty_state_page
```

### 注意事项

- 悬浮按钮使用 `id: "fab_button"` 选择器，而不是文本匹配
- 文本匹配去掉开头的 `.*`，保留结尾的 `.*`，避免类似 "Settings.*" 和 "Album Settings.*" 的冲突
- 错误检测推荐使用 `text: "ERROR_SCREEN_DETECTED"` 匹配 Semantics label，而非文本匹配
- 界面切换后必须等待动画完成再进行断言
- 对于超过 15 个界面的情况，从第 15 个开始需要使用 `scrollUntilVisible`
- 对于长列表界面，优先使用 `scrollUntilVisible` 而非多次 `scroll`
- maestro 运行成功时没有任何输出

## 故障排除

**项目创建失败**：确保 Flutter SDK 已安装并在 PATH 中。运行 `flutter doctor` 检查。

**平台文件缺失**：始终使用 `flutter create` - 永远不要手动复制 Android/iOS 文件。

**Maestro 测试失败**：检查 `ErrorPage` 是否在 `main.dart` 中正确配置。

## 参考文件

如需自定义模板内容，编辑以下文件：

| 文件 | 用途 |
|------|------|
| `references/demo_shell.dart` | DemoShell 组件模板 |
| `references/error_page.dart` | 错误页面模板 |
| `references/sample_demo_page.dart` | 示例页面模板 |
| `references/main.dart` | 主入口模板 |

修改后重新运行 Python 脚本即可应用更改。

## Skill 结束条件

本 Skill 在完成以下步骤后结束：

1. 成功运行 `flutter create`
2. 通过脚本创建所有 lib/ 文件
3. 清理 test 目录
4. 验证项目结构

除非用户明确要求，否则不需要执行代码或运行应用。
