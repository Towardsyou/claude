---
name: flutter-design-demo
description: 创建用于展示设计的 Flutter Demo App，包含半透明悬浮按钮切换界面、Client 注入机制和参数化页面创建功能。当用户需要创建 Flutter 设计展示 Demo 时使用。
---

# Flutter 设计展示 Demo

创建用于展示 UI 组件设计的 Flutter Demo App，支持多界面切换、Client 依赖注入和参数化展示。
本 Skill 在完成创建文件树，并且增加一个 demo 实现后即结束。

## 核心功能

- 半透明悬浮按钮（FAB）切换界面
- 点击展开为居中的界面选择器
- 点击外部区域恢复为圆形按钮
- 无选中界面时显示 Placeholder
- Client 对象注入，页面通过 `client['feature'](params)` 调用
- 支持同一组件创建多个不同参数的展示页

## 快速开始

### 1. 文件结构

```
flutter_design_demo/          # 项目根目录
├── android/                 # Android 平台配置
│   └── app/src/main/
│       ├── AndroidManifest.xml
│       ├── kotlin/.../MainActivity.kt
│       └── res/
├── ios/                     # iOS 平台配置
├── macos/                   # macOS 平台配置
├── web/                     # Web 平台配置
├── lib/                     # Dart 代码
│   ├── main.dart           # 应用入口
│   ├── demo_shell.dart     # Demo 外壳
│   └── pages/
│       └── feature_demo_page.dart
└── pubspec.yaml
```

**注意**：所有项目文件应放在单独的 `flutter_design_demo/` 文件夹内，而非项目根目录。

### 错误处理与红屏检测

为了支持 Maestro 测试时检测 Flutter 红屏错误，需要创建 `lib/error_page.dart` 并在 `main.dart` 中配置错误处理：

#### error_page.dart

```dart
import 'package:flutter/material.dart';

/// 错误页面 - 用于捕获和显示 Flutter 构建错误
class ErrorPage extends StatelessWidget {
  final FlutterErrorDetails? errorDetails;

  const ErrorPage({this.errorDetails, super.key});

  @override
  Widget build(BuildContext context) {
    final errorMessage = errorDetails?.exception.toString() ?? 'Unknown error';

    return Semantics(
      // Maestro 检测的关键标记
      label: 'ERROR_SCREEN_DETECTED',
      child: Container(
        color: const Color(0xFFD32F2F),
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.yellow, size: 48),
              const SizedBox(height: 16),
              const Text('ERROR',
                  style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(errorMessage,
                      style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 14,
                          fontFamily: 'monospace')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### 在 main.dart 中配置错误处理

```dart
import 'package:flutter/material.dart';
import 'demo_shell.dart';
import 'error_page.dart';

void main() {
  // 创建 Client 对象...
  final client = <String, Function>{};
  
  // 定义页面列表...
  final pages = [];

  runApp(MyApp(pages: pages));
}

class MyApp extends StatelessWidget {
  final List<DemoPageConfig> pages;

  const MyApp({super.key, required this.pages});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // 使用 builder 捕获所有 Flutter 错误
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

### 2. main.dart 模板

```dart
import 'package:flutter/material.dart';
import 'demo_shell.dart';

void main() {
  // 创建 Client 对象，注入功能实现
  final client = <String, Function>{
    'feature_name': (params) {
      // 实现逻辑
    },
  };

  // 定义展示页面列表
  final pages = [
    DemoPageConfig(
      title: '页面标题',
      builder: (context) => YourDemoPage(client: client),
    ),
    // 同一组件，不同参数
    DemoPageConfig(
      title: '页面标题（空状态）',
      builder: (context) => YourDemoPage(
        client: client,
        hasData: false,
      ),
    ),
  ];

  runApp(MyApp(pages: pages));
}

class MyApp extends StatelessWidget {
  final List<DemoPageConfig> pages;

  const MyApp({super.key, required this.pages});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: DemoShell(pages: pages),
    );
  }
}
```

### 3. DemoShell 组件

使用 `DemoShell` 作为根组件，传入页面配置列表：

```dart
DemoShell(
  pages: [
    DemoPageConfig(title: '界面1', builder: (_) => Page1()),
    DemoPageConfig(title: '界面2', builder: (_) => Page2()),
  ],
)
```

### 4. 页面中使用 Client

```dart
class FeatureDemoPage extends StatelessWidget {
  final Map<String, Function> client;
  final bool hasData;

  const FeatureDemoPage({
    super.key,
    required this.client,
    this.hasData = true,
  });

  void _handleAction() {
    // 通过 Client 调用功能
    client['feature_name']?({'key': 'value'});
  }

  @override
  Widget build(BuildContext context) {
    // 页面实现
  }
}
```

## 详细实现

### DemoShell 完整代码

[详细代码参考 examples.md](examples.md)

## 使用示例

### 场景 1：展示单个组件

```dart
final pages = [
  DemoPageConfig(
    title: '用户卡片',
    builder: (context) => UserCardDemo(client: client),
  ),
];
```

### 场景 2：展示组件多种状态

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

## 自定义样式

通过 `DemoShell` 参数自定义外观：

```dart
DemoShell(
  pages: pages,
  fabColor: Colors.blue.withOpacity(0.7),  // 悬浮按钮颜色
  selectorBackgroundColor: Colors.white,     // 选择器背景
  placeholderWidget: const CustomPlaceholder(), // 自定义占位符
)
```

## 重要提示

### 项目创建方式

**务必使用 `flutter create` 命令创建项目**，这是最可靠的方式：

```bash
flutter create --platforms=android,ios,macos,web flutter_design_demo
cd flutter_design_demo
```

然后只需替换 `lib/` 下的 Dart 代码即可。
并删除 `test` 目录中的文件

### 为什么不手动创建 Android 配置？

手动创建容易出错，常见问题包括：

- Gradle 版本与 Java 版本不兼容（如 Java 21 需 Gradle 8.5+）
- AndroidManifest.xml 拼写错误（如 `LAUNCHER` 错写为 `LAINGER`）
- styles.xml 缺少 `LaunchTheme` 定义
- Gradle 插件版本不匹配
- 文件路径或依赖关系问题

**`flutter create` 会自动生成与当前 Flutter 版本兼容的所有平台配置。**

## visual_validation.yaml 配置规范

在使用 Maestro 进行视觉验证测试时，生成的 `visual_validation.yaml` 文件需遵循以下要点：

### 1. 点击操作后添加等待时间

每个 `tapOn` 操作后必须添加 `waitForAnimationToEnd` 或 `sleep` 指令，建议等待 0.5 秒：

```yaml
- tapOn:
    text: "界面1"
- waitForAnimationToEnd: # 或 sleep: 1000
- assertVisible:
    text: ".*页面内容.*"
```

### 2. 支持界面列表滚动

当界面选择器中的项目过多时，需要添加滚动操作确保可以访问所有界面：

```yaml
- scrollUntilVisible:
    element:
      text: ".*目标界面.*"
    direction: DOWN
    timeout: 5000
```

### 3. 错误检测断言

通过 ErrorPage 的 Semantics label 检测 Flutter 红屏错误（推荐方式）：

```yaml
# 检测红屏错误 - 使用 ERROR_SCREEN_DETECTED 标记
- assertNotVisible:
    label: "ERROR_SCREEN_DETECTED"
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
- **考虑大小写不敏感**：使用 `(?i)` 前缀或确保大小写匹配

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

### 完整示例

```yaml
appId: com.example.flutter_design_demo
---
# 1. 启动应用并等待
- launchApp
- waitForAnimationToEnd:
    timeout: 5000

# 2. 验证应用启动时没有红屏错误
- assertNotVisible:
    label: "ERROR_SCREEN_DETECTED"

# 3. 打开界面选择器（点击悬浮按钮）
- tapOn: "悬浮按钮"
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
    label: "ERROR_SCREEN_DETECTED"

# 6. 验证预期内容渲染正确
- assertVisible:
    text: "暂无数据.*"
- assertVisible:
    text: "空状态提示.*"

# 7. 截图
- takeScreenshot: screenshots/empty_state_page
```

### 注意事项

- 文本匹配去掉开头的 `.*`，保留结尾的 `.*`，避免类似 "Settings.*" 和 "Album Settings.*" 的冲突
- 错误检测推荐使用 `label: "ERROR_SCREEN_DETECTED"` 而非文本匹配
- 界面切换后必须等待动画完成再进行断言
- 对于长列表界面，优先使用 `scrollUntilVisible` 而非多次 `scroll`
- maestro 运行成功时没有任何输出
