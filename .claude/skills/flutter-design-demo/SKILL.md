---
name: flutter-design-demo
description: 创建用于展示设计的 Flutter Demo App，包含半透明悬浮按钮切换界面、Client 注入机制和参数化页面创建功能。当用户需要创建 Flutter 设计展示 Demo 时使用。
---

# Flutter 设计展示 Demo

创建用于展示 UI 组件设计的 Flutter Demo App，支持多界面切换、Client 依赖注入和参数化展示。本 Skill 在完成创建 demo 文件夹后即结束。

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
并删除 `test` 目录以及其中的文件

### 为什么不手动创建 Android 配置？

手动创建容易出错，常见问题包括：

- Gradle 版本与 Java 版本不兼容（如 Java 21 需 Gradle 8.5+）
- AndroidManifest.xml 拼写错误（如 `LAUNCHER` 错写为 `LAINGER`）
- styles.xml 缺少 `LaunchTheme` 定义
- Gradle 插件版本不匹配
- 文件路径或依赖关系问题

**`flutter create` 会自动生成与当前 Flutter 版本兼容的所有平台配置。**
