# 完整代码示例

## 1. demo_shell.dart

```dart
import 'package:flutter/material.dart';

/// 页面配置类
class DemoPageConfig {
  final String title;
  final WidgetBuilder builder;

  const DemoPageConfig({
    required this.title,
    required this.builder,
  });
}

/// Demo 外壳组件
/// 提供悬浮按钮切换界面功能
class DemoShell extends StatefulWidget {
  final List<DemoPageConfig> pages;
  final Color? fabColor;
  final Color? selectorBackgroundColor;
  final Widget? placeholderWidget;

  const DemoShell({
    super.key,
    required this.pages,
    this.fabColor,
    this.selectorBackgroundColor,
    this.placeholderWidget,
  });

  @override
  State<DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<DemoShell>
    with SingleTickerProviderStateMixin {
  int? _selectedIndex;
  bool _isSelectorOpen = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSelector() {
    setState(() {
      _isSelectorOpen = !_isSelectorOpen;
      if (_isSelectorOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _closeSelector() {
    if (_isSelectorOpen) {
      setState(() {
        _isSelectorOpen = false;
        _animationController.reverse();
      });
    }
  }

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
      _isSelectorOpen = false;
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 主内容区域
          GestureDetector(
            onTap: _closeSelector,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: _selectedIndex != null
                  ? widget.pages[_selectedIndex!].builder(context)
                  : Center(
                      child: widget.placeholderWidget ??
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.touch_app,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '点击悬浮按钮选择界面',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                    ),
            ),
          ),

          // 选择器覆盖层
          if (_isSelectorOpen)
            GestureDetector(
              onTap: _closeSelector,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: widget.selectorBackgroundColor ?? Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '选择界面',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          ...List.generate(
                            widget.pages.length,
                            (index) => RadioListTile<int>(
                              title: Text(widget.pages[index].title),
                              value: index,
                              groupValue: _selectedIndex,
                              onChanged: (value) {
                                if (value != null) {
                                  _selectPage(value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),

      // 悬浮按钮
      floatingActionButton: GestureDetector(
        onTap: _toggleSelector,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _isSelectorOpen ? 0 : 56,
          height: _isSelectorOpen ? 0 : 56,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isSelectorOpen ? 0.0 : 1.0,
            child: FloatingActionButton(
              onPressed: _toggleSelector,
              backgroundColor:
                  widget.fabColor ?? Colors.grey.withOpacity(0.7),
              elevation: 4,
              child: const Icon(Icons.layers, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
```

## 2. main.dart 完整示例

```dart
import 'package:flutter/material.dart';
import 'demo_shell.dart';
import 'pages/product_list_page.dart';

void main() {
  // 创建 Client 对象，注入业务功能
  final client = <String, Function>{
    'fetch_products': () async {
      // 模拟获取商品列表
      await Future.delayed(const Duration(seconds: 1));
      return [
        {'id': 1, 'name': '商品 A', 'price': 99.0},
        {'id': 2, 'name': '商品 B', 'price': 149.0},
        {'id': 3, 'name': '商品 C', 'price': 199.0},
      ];
    },
    'add_to_cart': (productId) {
      // 添加到购物车
      debugPrint('添加商品 $productId 到购物车');
    },
    'search_products': (query) {
      // 搜索商品
      debugPrint('搜索: $query');
    },
  };

  // 定义展示页面列表
  final pages = [
    DemoPageConfig(
      title: '商品列表（有数据）',
      builder: (context) => ProductListPage(
        client: client,
        products: const [
          {'id': 1, 'name': 'iPhone 15', 'price': 5999.0},
          {'id': 2, 'name': 'MacBook Pro', 'price': 12999.0},
          {'id': 3, 'name': 'AirPods Pro', 'price': 1999.0},
          {'id': 4, 'name': 'iPad Air', 'price': 4799.0},
        ],
      ),
    ),
    DemoPageConfig(
      title: '商品列表（空状态）',
      builder: (context) => ProductListPage(
        client: client,
        products: const [],
      ),
    ),
    DemoPageConfig(
      title: '商品列表（加载中）',
      builder: (context) => ProductListPage(
        client: client,
        isLoading: true,
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
      title: '商品列表 Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: DemoShell(
        pages: pages,
        fabColor: Colors.blue.withOpacity(0.8),
      ),
    );
  }
}
```

## 3. 示例页面 product_list_page.dart

```dart
import 'package:flutter/material.dart';

class ProductListPage extends StatelessWidget {
  final Map<String, Function> client;
  final List<Map<String, dynamic>>? products;
  final bool isLoading;

  const ProductListPage({
    super.key,
    required this.client,
    this.products,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // 加载状态
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载中...'),
          ],
        ),
      );
    }

    // 空状态
    if (products == null || products!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_basket_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无商品',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // 调用 Client 方法
                client['fetch_products']?.call();
              },
              child: const Text('刷新'),
            ),
          ],
        ),
      );
    }

    // 有数据状态
    return Column(
      children: [
        // 搜索栏
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: '搜索商品...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (value) {
              // 调用 Client 搜索方法
              client['search_products']?.call(value);
            },
          ),
        ),

        // 商品列表
        Expanded(
          child: ListView.builder(
            itemCount: products!.length,
            itemBuilder: (context, index) {
              final product = products![index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      product['name'][0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(product['name']),
                  subtitle: Text('¥${product['price']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () {
                      // 调用 Client 添加到购物车
                      client['add_to_cart']?.call(product['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('已添加 ${product['name']} 到购物车'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

## AndroidManifest.xml 示例

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="flutter_design_demo"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

## 5. styles.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoActionBar">
        <item name="android:windowBackground">@android:color/black</item>
    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoActionBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
```

## 6. pubspec.yaml 依赖

```yaml
name: flutter_design_demo
description: A Flutter design demo app

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

## 项目结构

创建完整的 Flutter 项目结构（支持 Android/iOS/macOS/Web）：

```
flutter_design_demo/
├── android/                 # Android 平台配置
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/com/example/flutter_design_demo/MainActivity.kt
│   │       └── res/values/styles.xml
│   ├── build.gradle
│   └── settings.gradle
├── ios/                   # iOS 平台配置（可选）
├── macos/                 # macOS 平台配置（可选）
├── web/                   # Web 平台配置（可选）
├── lib/                   # Dart 代码
│   ├── main.dart
│   ├── demo_shell.dart
│   └── pages/
│       └── login_page.dart
├── pubspec.yaml
└── test/
```

## 使用流程（推荐）

**务必使用 `flutter create` 创建项目**，不要手动创建 Android/iOS 配置：

```bash
# 1. 创建项目
flutter create --platforms=android,ios,macos,web flutter_design_demo
cd flutter_design_demo

# 2. 替换 lib/ 下的代码
# - 复制 demo_shell.dart 到 lib/
# - 创建 lib/pages/ 目录
# - 复制示例页面到 lib/pages/
# - 替换 lib/main.dart

# 3. 运行
flutter run -d emulator-5554
```

### 经验教训

**手动创建项目配置的陷阱**：
1. Gradle 版本与 Java 版本不兼容（Java 21 需 Gradle 8.5+）
2. AndroidManifest.xml 配置错误（如 `LAUNCHER` 拼写错误）
3. styles.xml 缺少 `LaunchTheme`
4. 各种版本依赖问题

**`flutter create` 自动处理所有平台配置**，无需担心兼容性问题。

## 多平台支持

### Android 运行
```bash
cd flutter_design_demo
flutter run -d emulator-5554
```

### iOS 模拟器
```bash
cd flutter_design_demo
flutter run -d ios
```

### macOS Desktop
```bash
cd flutter_design_demo
flutter run -d macos
```

### Web
```bash
cd flutter_design_demo
flutter run -d chrome
```
