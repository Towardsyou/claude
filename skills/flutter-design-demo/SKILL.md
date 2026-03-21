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

**务必使用 `flutter create` 命令**，这是最可靠的方式。

**⚠️ CRITICAL: 项目应该直接在用户指定的目录创建，不要嵌套在子目录中**

**正确的创建方式**（假设用户指定目录为 `flutter_demo`）：

```bash
# 进入用户指定的目录
cd /path/to/user/specified/directory  # e.g., flutter_demo

# 直接在此目录创建 Flutter 项目（注意最后的 . 表示当前目录）
flutter create --platforms=android,ios,macos,web .
```

**❌ 错误的创建方式（会导致嵌套目录）**：
```bash
# 不要这样做！这会在 flutter_demo/flutter_project 创建项目
cd flutter_demo
flutter create flutter_project
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
# 在用户指定的项目根目录执行
python3 /Users/zhaoyu.ming/.claude/skills/flutter-design-demo/scripts/create_lib_files.py .
```

此脚本会创建：

- `lib/demo_shell.dart` - 悬浮按钮界面选择器
- `lib/error_page.dart` - 红屏错误检测页面
- `lib/pages/sample_demo_page.dart` - 示例展示页面
- `lib/main.dart` - 应用入口（带错误处理配置）

### 步骤 3: 清理 test 目录

```bash
rm -rf test
```

### 步骤 4: 验证项目可以编译

**必须执行验证步骤**（编译通过即可，不需要运行）：

```bash
# 首先尝试构建项目
flutter build apk --debug

# 如果出现错误，先修复错误
# 常见错误和修复：
# - Java 版本问题：检查 JAVA_HOME 设置
# - Gradle 问题：运行 ./gradlew clean
# - 依赖问题：运行 flutter pub get

# 验证成功标准：
# flutter build apk --debug 成功完成（生成 APK 文件）
# 不需要 flutter run，运行验证通过 Maestro 测试完成
```

### 步骤 5: 运行应用（开发调试用）

```bash
flutter run -d emulator-5554
```

## 项目结构

**正确的项目结构**（项目直接在指定目录）：

```
flutter_demo/               # 用户指定的目录 = 项目根目录
├── android/                # Android 平台配置
├── ios/                    # iOS 平台配置
├── macos/                  # macOS 平台配置
├── web/                    # Web 平台配置
├── lib/                    # Dart 代码
│   ├── main.dart          # 应用入口
│   ├── demo_shell.dart    # Demo 外壳（悬浮按钮切换）
│   ├── error_page.dart    # 错误页面（红屏检测）
│   └── pages/
│       └── sample_demo_page.dart
└── pubspec.yaml
```

**❌ 错误的项目结构**（不要嵌套）：
```
flutter_demo/
└── flutter_project/       # 错误！不应该有这层嵌套
    ├── android/
    ├── ios/
    └── ...
```

**注意**：使用 `flutter create .`（带点的命令）在当前目录直接创建项目，不要创建子目录。

## Flutter 开发规范

### 1. Demo Shell 架构

**File Structure:**
```
lib/
├── main.dart              # Entry point with client injection
├── demo_shell.dart        # Floating button navigation shell
├── error_page.dart        # Red screen error detection
├── components/            # SHARED components across pages
│   ├── app_header.dart
│   ├── app_tab_bar.dart
│   ├── app_button.dart
│   └── ...
└── pages/
    └── *.dart             # Individual page implementations
```

**CRITICAL: Main.dart Integration Checklist**

After implementing ALL pages, you MUST verify:

```dart
// main.dart - COMPLETE VERIFICATION
void main() {
  final pages = [
    // EVERY page from the design MUST be listed here
    DemoPageConfig(title: 'Page 1', builder: (_) => Page1(client: client)),
    DemoPageConfig(title: 'Page 2', builder: (_) => Page2(client: client)),
    // ... ALL pages
  ];

  runApp(MyApp(pages: pages));
}
```

**Verification Steps:**
1. Count pages in `pages` list - must match total frames from .pen file
2. Run app and open selector - every page must appear in the list
3. Tap through each page - confirm all render correctly
4. **DO NOT mark task complete until all pages are accessible via selector**

### 2. Mock Data Implementation (REQUIRED)

**Every page MUST implement realistic mock data that supports ALL interactions defined in the feature document.**

#### Mock Data Requirements

1. **Complete Data Structures**: Mock data should match real-world data shapes
2. **Support All Interactions**: Every button, input, list item should have functional mock behavior
3. **Multiple States**: Provide data for empty, loading, error, and populated states
4. **Navigation Support**: Mock navigation actions between pages
5. **Form Handling**: Mock form submission, validation, and feedback

#### Client Injection with Mock Data Pattern

```dart
// main.dart - Define comprehensive mock client
final client = <String, Function>{
  // Data fetching with realistic mock data
  'fetch_products': () async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      {
        'id': 'p1',
        'name': 'iPhone 15 Pro',
        'price': 999.00,
        'image': 'assets/iphone.png',
        'rating': 4.8,
        'reviews': 1250,
      },
      {
        'id': 'p2',
        'name': 'MacBook Air M3',
        'price': 1299.00,
        'image': 'assets/macbook.png',
        'rating': 4.9,
        'reviews': 890,
      },
      // ... more realistic products
    ];
  },
  
  // User actions with mock responses
  'add_to_cart': (productId) {
    debugPrint('Added $productId to cart');
    return {'success': true, 'cartCount': 3};
  },
  
  'login': (email, password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'user@example.com' && password == 'password') {
      return {
        'success': true,
        'user': {
          'id': 'u1',
          'name': 'John Doe',
          'email': email,
          'avatar': 'assets/avatar.png',
        },
        'token': 'mock_jwt_token_12345',
      };
    }
    return {'success': false, 'error': 'Invalid credentials'};
  },
  
  'navigate_to': (routeName) {
    debugPrint('Navigate to: $routeName');
    // Mock navigation - could trigger DemoShell page switch
  },
  
  'show_snackbar': (message) {
    debugPrint('Snackbar: $message');
  },
};
```

#### Page Implementation with Full Interaction Support

```dart
class ProductListPage extends StatelessWidget {
  final Map<String, Function> client;
  final List<Map<String, dynamic>>? products;
  final bool isLoading;

  const ProductListPage({
    required this.client,
    this.products,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading products...'),
          ],
        ),
      );
    }

    // Empty state - with action to load data
    if (products == null || products!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No products yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => client['fetch_products']?.call(),
              child: const Text('Load Products'),
            ),
          ],
        ),
      );
    }

    // Data state - full interaction support
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => client['show_search']?.call(),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => client['navigate_to']?.call('cart'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products!.length,
        itemBuilder: (context, index) {
          final product = products![index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  product['image'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(product['name']),
              subtitle: Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber[600]),
                  Text('${product['rating']} (${product['reviews']})'),
                  const SizedBox(width: 8),
                  Text('\$${product['price']}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add_shopping_cart),
                onPressed: () {
                  client['add_to_cart']?.call(product['id']);
                  client['show_snackbar']?.call('Added ${product['name']} to cart');
                },
              ),
              onTap: () => client['navigate_to_product_detail']?.call(product['id']),
            ),
          );
        },
      ),
    );
  }
}
```

#### Multi-State Component Pages with Mock Data

For components with multiple states, create separate demo pages with different mock data:

```dart
final pages = [
  // Loading state
  DemoPageConfig(
    title: '商品列表（加载中）',
    builder: (_) => ProductListPage(
      client: client,
      isLoading: true,
    ),
  ),
  // Empty state
  DemoPageConfig(
    title: '商品列表（空状态）',
    builder: (_) => ProductListPage(
      client: client,
      products: [],
    ),
  ),
  // With data - multiple products
  DemoPageConfig(
    title: '商品列表（有数据）',
    builder: (_) => ProductListPage(
      client: client,
      products: [
        {'id': 'p1', 'name': 'iPhone 15', 'price': 999, 'rating': 4.8, 'reviews': 1200},
        {'id': 'p2', 'name': 'MacBook Pro', 'price': 1999, 'rating': 4.9, 'reviews': 800},
        {'id': 'p3', 'name': 'AirPods Pro', 'price': 249, 'rating': 4.7, 'reviews': 2500},
      ],
    ),
  ),
  // Single item
  DemoPageConfig(
    title: '商品列表（单商品）',
    builder: (_) => ProductListPage(
      client: client,
      products: [
        {'id': 'p1', 'name': 'iPhone 15', 'price': 999, 'rating': 4.8, 'reviews': 1200},
      ],
    ),
  ),
];
```

### 3. TDD Development Process

**Strict TDD Workflow:**

1. **Write Test First**: Before implementing any widget, write the widget test
2. **Run Test (Red)**: Verify the test fails as expected
3. **Implement Widget**: Write the minimal code to pass the test
4. **Run Test (Green)**: Ensure the test passes
5. **Refactor**: Improve code quality while keeping tests green
6. **Repeat**: Maximum 5 tests per iteration

**Widget Test Example:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('LoginPage', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(client: {}),
        ),
      );

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('calls client login on submit', (tester) async {
      bool loginCalled = false;
      final mockClient = <String, Function>{
        'login': (email, password) {
          loginCalled = true;
          return {'success': true};
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(client: mockClient),
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'user@example.com');
      await tester.enterText(find.byType(TextField).last, 'password');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(loginCalled, true);
    });
  });
}
```

### 4. Visual Fidelity Standards

**Color Matching:**
- Extract exact hex colors from Pencil designs
- Use `Color(0xFFRRGGBB)` notation
- Support opacity with `withOpacity()` or `Color(0xAARRGGBB)`

**Typography:**
- Match font families exactly (use Google Fonts if needed)
- Precise font sizes, weights, and letter spacing
- Text styles via `TextStyle()` with exact parameters

**Spacing & Layout:**
- Exact padding and margin values from design
- Proper use of `SizedBox`, `Padding`, `Container`
- Constraint-based layouts matching design specs

**Shadows & Effects:**
- `BoxShadow` with exact color, blur radius, offset, spread
- Match elevation and depth effects
- Support blur effects where specified

**Example:**
```dart
// Design spec: 16px padding, 8px radius, #3B82F6 color
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: const Color(0xFF3B82F6),
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Text(
    'Button',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
)
```

### 5. Stateless Architecture

**Principles:**
- All pages are `StatelessWidget`
- No `setState` calls in page components
- All data flows through `client` parameter
- Side effects handled via client method calls

**Pattern:**
```dart
class ProductListPage extends StatelessWidget {
  final Map<String, Function> client;
  final List<Map<String, dynamic>>? products;
  final bool isLoading;

  const ProductListPage({
    required this.client,
    this.products,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return LoadingView();
    if (products == null || products!.isEmpty) {
      return EmptyView(onRefresh: () => client['fetch_products']?.call());
    }
    return ProductListView(products: products!);
  }
}
```

### 6. Multi-State Component Pages

For components with multiple states (loading, empty, error, data), create separate demo pages:

```dart
final pages = [
  DemoPageConfig(
    title: '商品列表（有数据）',
    builder: (_) => ProductListPage(client: client, products: sampleData),
  ),
  DemoPageConfig(
    title: '商品列表（空状态）',
    builder: (_) => ProductListPage(client: client, products: []),
  ),
  DemoPageConfig(
    title: '商品列表（加载中）',
    builder: (_) => ProductListPage(client: client, isLoading: true),
  ),
];
```

### 7. Inter-Page Navigation (MUST IMPLEMENT)

**ALL buttons that navigate to other pages MUST have functional navigation via client injection.**

#### Navigation Requirements

1. **Every navigation action defined in feature document MUST be implemented**
2. **Use client injection pattern** - Navigation is handled via `client['navigate_*']` methods
3. **Support all navigation types**:
   - Push to new page (e.g., "Login" → "Register")
   - Pop back (e.g., "Back" button)
   - Replace current page (e.g., "Login" → "Home" after successful auth)
   - Navigate with parameters (e.g., "Album List" → "Album Detail" with albumId)

#### Complete Navigation Implementation Pattern

**Step 1: Define Navigation Methods in Client (main.dart)**

```dart
// main.dart - Define navigation methods for ALL page transitions

void main() {
  // Store pages reference for navigation
  final List<DemoPageConfig> allPages = [
    DemoPageConfig(title: 'Landing Page', builder: (_) => LandingPage(client: {})),
    DemoPageConfig(title: 'Login Page', builder: (_) => LoginPage(client: {})),
    DemoPageConfig(title: 'Register Page', builder: (_) => RegisterPage(client: {})),
    DemoPageConfig(title: 'Timeline Home', builder: (_) => TimelineHomePage(client: {})),
    DemoPageConfig(title: 'Albums List', builder: (_) => AlbumsListPage(client: {})),
    DemoPageConfig(title: 'Album Detail', builder: (_) => AlbumDetailPage(client: {})),
    DemoPageConfig(title: 'Profile Tab', builder: (_) => ProfileTabPage(client: {})),
    // ... all pages
  ];

  // Create client with navigation methods
  final client = <String, Function>{
    // Data methods...
    'fetch_products': () async => [...],
    
    // NAVIGATION METHODS - MUST implement ALL from feature document
    
    // 1. Navigate by page title (for DemoShell page switching)
    'navigate_to_page': (String pageTitle) {
      debugPrint('Navigate to page: $pageTitle');
      // In real implementation, this would trigger DemoShell to switch pages
      // For now, log the navigation action
    },
    
    // 2. Navigate to specific page with parameters
    'navigate_to_album_detail': (String albumId) {
      debugPrint('Navigate to Album Detail, albumId: $albumId');
    },
    
    'navigate_to_photo_detail': (String photoId) {
      debugPrint('Navigate to Photo Detail, photoId: $photoId');
    },
    
    // 3. Navigate back (pop)
    'navigate_back': () {
      debugPrint('Navigate back');
    },
    
    // 4. Navigation from specific pages
    'navigate_from_landing_to_login': () {
      debugPrint('Landing Page: Navigate to Login');
    },
    
    'navigate_from_login_to_register': () {
      debugPrint('Login Page: Navigate to Register');
    },
    
    'navigate_from_login_to_home': () {
      debugPrint('Login Page: Navigate to Timeline Home (after successful login)');
    },
    
    'navigate_from_albums_to_create': () {
      debugPrint('Albums List: Navigate to Create Album');
    },
    
    'navigate_from_albums_to_detail': (String albumId) {
      debugPrint('Albums List: Navigate to Album Detail, id: $albumId');
    },
    
    'navigate_from_home_to_notifications': () {
      debugPrint('Timeline Home: Navigate to Notifications');
    },
    
    'navigate_from_home_to_profile': () {
      debugPrint('Timeline Home: Navigate to Profile');
    },
    
    // 5. Tab switching (for bottom navigation)
    'switch_to_tab': (String tabName) {
      debugPrint('Switch to tab: $tabName');
    },
  };
  
  // Update client reference in all pages
  final pagesWithClient = allPages.map((page) {
    // Rebuild pages with actual client
    return DemoPageConfig(
      title: page.title,
      builder: (context) {
        final widget = page.builder(context);
        // Inject client into pages that need it
        if (widget is LandingPage) return LandingPage(client: client);
        if (widget is LoginPage) return LoginPage(client: client);
        // ... etc
        return widget;
      },
    );
  }).toList();

  runApp(MyApp(pages: pagesWithClient));
}
```

**Step 2: Implement Navigation in Pages**

```dart
// landing_page.dart - "Get Started" button navigates to Login
class LandingPage extends StatelessWidget {
  final Map<String, Function> client;

  const LandingPage({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ... hero section, branding ...
          
          // Primary CTA button - navigates to Login
          PrimaryButton(
            text: 'Get Started',
            onPressed: () {
              // MUST call navigation method
              client['navigate_from_landing_to_login']?.call();
            },
          ),
          
          // Secondary button - also navigates
          SecondaryButton(
            text: 'Sign In',
            onPressed: () {
              client['navigate_from_landing_to_login']?.call();
            },
          ),
        ],
      ),
    );
  }
}
```

```dart
// login_page.dart - Multiple navigation actions
class LoginPage extends StatelessWidget {
  final Map<String, Function> client;

  const LoginPage({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Back navigation
            client['navigate_back']?.call();
          },
        ),
      ),
      body: Column(
        children: [
          // ... email/password fields ...
          
          // Login button - navigates to Home on success
          PrimaryButton(
            text: 'Login',
            onPressed: () {
              // Perform login logic...
              // Then navigate
              client['navigate_from_login_to_home']?.call();
            },
          ),
          
          // Register link - navigates to Register page
          TextButton(
            onPressed: () {
              client['navigate_from_login_to_register']?.call();
            },
            child: const Text('Don\'t have an account? Register'),
          ),
        ],
      ),
    );
  }
}
```

```dart
// albums_list_page.dart - Navigate to detail with parameters
class AlbumsListPage extends StatelessWidget {
  final Map<String, Function> client;
  final List<Map<String, dynamic>> albums;

  const AlbumsListPage({
    super.key,
    required this.client,
    required this.albums,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Albums'),
        actions: [
          // Add button - navigates to Create Album
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              client['navigate_from_albums_to_create']?.call();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
          return ListTile(
            leading: Image.asset(album['coverImage']),
            title: Text(album['name']),
            subtitle: Text('${album['photoCount']} photos'),
            // Navigate to detail with album ID
            onTap: () {
              client['navigate_from_albums_to_detail']?.call(album['id']);
            },
          );
        },
      ),
    );
  }
}
```

```dart
// timeline_home_page.dart - Bottom tab navigation
class TimelineHomePage extends StatelessWidget {
  final Map<String, Function> client;

  const TimelineHomePage({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
        actions: [
          // Notification icon - navigates to Notifications
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              client['navigate_from_home_to_notifications']?.call();
            },
          ),
        ],
      ),
      body: /* timeline content */,
      
      // Bottom navigation bar - switches tabs
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_album), label: 'Albums'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              client['switch_to_tab']?.call('home');
              break;
            case 1:
              client['switch_to_tab']?.call('albums');
              break;
            case 2:
              client['navigate_from_home_to_notifications']?.call();
              break;
            case 3:
              client['navigate_from_home_to_profile']?.call();
              break;
          }
        },
      ),
    );
  }
}
```

#### Navigation Implementation Checklist

For each page, verify:
- [ ] **ALL buttons with navigation actions** call a `client['navigate_*']` method
- [ ] **Back buttons** use `client['navigate_back']?.call()`
- [ ] **CTA buttons** (Get Started, Login, Register) have navigation implemented
- [ ] **List items** that navigate to detail pages pass the correct ID parameter
- [ ] **Bottom tab items** switch to the correct tab/page
- [ ] **AppBar actions** (notifications, settings) navigate to correct pages
- [ ] **Text links** ("Already have an account? Login") have navigation

#### Common Navigation Patterns

| Action | Implementation |
|--------|---------------|
| Primary CTA (Get Started) | `client['navigate_from_X_to_Y']?.call()` |
| Secondary button (Sign In) | `client['navigate_from_X_to_Y']?.call()` |
| Back button | `client['navigate_back']?.call()` |
| List item to detail | `client['navigate_to_detail']?.call(itemId)` |
| Create/Add button | `client['navigate_to_create']?.call()` |
| Tab switch | `client['switch_to_tab']?.call('tabName')` |
| Link text | `client['navigate_to_X']?.call()` |

#### Example: Complete Navigation Setup for 17 Pages

```dart
// Complete navigation methods for all 17 pages
final client = <String, Function>{
  // ========== Landing Page Navigation ==========
  'navigate_from_landing_to_login': () {},
  
  // ========== Login Page Navigation ==========
  'navigate_from_login_to_register': () {},
  'navigate_from_login_to_home': () {},
  'navigate_from_login_to_forgot_password': () {},
  
  // ========== Register Page Navigation ==========
  'navigate_from_register_to_login': () {},
  'navigate_from_register_to_profile_setup': () {},
  
  // ========== Profile Setup Navigation ==========
  'navigate_from_profile_setup_to_home': () {},
  
  // ========== Timeline Home Navigation ==========
  'navigate_from_home_to_notifications': () {},
  'navigate_from_home_to_profile': () {},
  'navigate_from_home_to_create_post': () {},
  'switch_to_tab': (String tab) {},
  
  // ========== Albums List Navigation ==========
  'navigate_from_albums_to_create': () {},
  'navigate_from_albums_to_detail': (String albumId) {},
  
  // ========== Album Detail Navigation ==========
  'navigate_from_album_detail_to_settings': () {},
  'navigate_from_album_detail_to_member_management': () {},
  'navigate_from_album_detail_to_photo_detail': (String photoId) {},
  'navigate_from_album_detail_to_select_photos': () {},
  
  // ========== Photo Detail Navigation ==========
  'navigate_from_photo_detail_to_edit': () {},
  'navigate_from_photo_detail_back': () {},
  
  // ... etc for all pages
};
```

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

## 代码组织最佳实践

### 目录结构

```
lib/
├── main.dart              # Entry point
├── demo_shell.dart        # Demo shell component
├── error_page.dart        # Error handling
├── components/            # Shared components
│   ├── app_header.dart
│   ├── app_tab_bar.dart
│   ├── app_button.dart
│   ├── app_text_field.dart
│   ├── app_card.dart
│   └── photo_grid.dart
└── pages/                 # Individual pages
    ├── landing_page.dart
    ├── login_page.dart
    └── ...
```

### Widget Design Principles

1. **Small and Focused**: Each widget has a single responsibility
2. **Configurable**: Use constructor parameters for customization
3. **Documented**: Dartdoc comments for public APIs
4. **Tested**: Every widget has corresponding tests
5. **Theme-Aware**: Respect Material 3 theme when applicable

### Performance Considerations

1. Use `const` constructors where possible
2. Minimize rebuilds with proper widget boundaries
3. Use `ListView.builder` for long lists
4. Cache expensive operations
5. Profile with Flutter DevTools

## 多平台运行

| 平台 | 命令 |
|------|------|
| Android | `flutter run -d emulator-5554` |
| iOS | `flutter run -d ios` |
| macOS | `flutter run -d macos` |
| Web | `flutter run -d chrome` |

## Maestro 测试配置规范

在使用 Maestro 进行视觉验证测试时，为每个页面生成独立的测试文件，遵循以下要点：

### 1. 分页面测试文件结构

每个页面生成独立的 Maestro 测试文件，位于 `.maestro/pages/` 目录：

```
.maestro/
├── pages/
│   ├── 01_landing_page.yaml
│   ├── 02_login_page.yaml
│   ├── 03_home_page.yaml
│   └── ...
└── visual_validation.yaml  # 主测试文件，引用所有页面测试
```

### 2. 单个页面测试文件模板

每个页面测试文件遵循统一框架：

```yaml
# .maestro/pages/XX_page_name.yaml
appId: com.example.flutter_project
---
# 步骤 1: 打开界面选择器（点击悬浮按钮）
- tapOn:
    id: "fab_button"
- waitForAnimationToEnd:
    timeout: 1000

# 步骤 2: 检查选项是否可见，如不可见则滚动查找
- runFlow:
    when:
      notVisible: "页面标题.*"
    commands:
      - scrollUntilVisible:
          element:
            text: "页面标题.*"
          direction: DOWN
          timeout: 3000

# 步骤 3: 点击目标界面
- tapOn:
    text: "页面标题.*"
- waitForAnimationToEnd:
    timeout: 1000

# 步骤 4: 检测红屏错误
- assertNotVisible:
    text: "ERROR_SCREEN_DETECTED"

# 步骤 5: 验证页面关键元素
- assertVisible:
    text: ".*关键元素文本.*"

# 步骤 6: 截图保存（相对项目根目录）
- takeScreenshot: screenshots/XX_page_name
```

**截图保存说明：**
- 截图保存在 **Flutter 项目根目录的 `screenshots/` 文件夹**
- 路径示例: `flutter_demo/screenshots/01_landing_page.png`
- 每个页面一个截图文件，命名格式: `XX_page_name.png`
- Maestro 自动创建 `screenshots/` 目录（如果不存在）

### 3. 主测试文件 (visual_validation.yaml)

主测试文件用于批量执行所有页面测试：

```yaml
# .maestro/visual_validation.yaml
appId: com.example.flutter_project
---
# 启动应用
- launchApp
- waitForAnimationToEnd:
    timeout: 5000

# 执行所有页面测试
- runFlow: pages/01_landing_page.yaml
- runFlow: pages/02_login_page.yaml
- runFlow: pages/03_home_page.yaml
# ... 继续添加所有页面
```

### 4. 点击操作后添加等待时间

每个 `tapOn` 操作后必须添加 `waitForAnimationToEnd` 或 `sleep` 指令：

```yaml
- tapOn:
    text: "界面1"
- waitForAnimationToEnd:  # 或 sleep: 1000
- assertVisible:
    text: ".*页面内容.*"
```

### 5. 界面列表滚动处理

**关键逻辑**：每个页面测试都必须处理选项可能需要滚动才能看到的情况。

使用 `runFlow` + `when` + `notVisible` 条件实现智能滚动：

```yaml
# 尝试查找并点击选项，如果不可见则滚动
- runFlow:
    when:
      notVisible: "目标页面.*"
    commands:
      - scrollUntilVisible:
          element:
            text: "目标页面.*"
          direction: DOWN
          timeout: 3000

# 点击选项
- tapOn:
    text: "目标页面.*"
```

这种模式的优点：
- **统一的测试框架**：所有页面使用相同的测试结构
- **自适应滚动**：无论列表多长，都能自动找到目标
- **无需硬编码滚动次数**：避免脆弱的多次 `scroll` 命令

### 6. 错误检测断言

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

### 7. accessibilityText 匹配规范

使用 `tapOn` 时，文本匹配应遵循以下规则：

- **使用部分匹配**：避免由于空格、换行或重复字符导致的匹配失败
- **去掉开头的 `.*`**：避免类似 "Settings.*" 和 ".*Album Settings.*" 的匹配冲突
- **保留结尾的 `.*`**：用于匹配后续可能的变化（如换行、空格）
- **避免完全匹配**：不要使用精确字符串匹配

```yaml
# 推荐：去掉开头的 .*，保留结尾的 .*
- tapOn:
    text: "用户卡片.*"
- tapOn:
    text: "Settings.*"

# 避免：开头的 .* 会导致冲突
- tapOn:
    text: ".*Settings.*"  # 会同时匹配 "Settings" 和 "Album Settings"

# 避免：完全匹配，容易因空格或格式变化失败
- tapOn:
    text: "用户卡片"

# 推荐：部分匹配
- assertVisible:
    text: "这是.*页面.*内容.*"
```

### 8. 悬浮按钮选择器规范

DemoShell 的悬浮按钮使用 `Semantics(identifier: 'fab_button')` 包裹，因此在 Maestro 中应使用 `id` 选择器：

```yaml
# 推荐：使用 id 匹配悬浮按钮
- tapOn:
    id: "fab_button"

# 避免：使用文本匹配可能失败
- tapOn: "悬浮按钮"
```

### 9. 完整示例 - 单个页面测试

```yaml
# .maestro/pages/04_product_list.yaml
appId: com.example.flutter_project
---
# 1. 打开界面选择器
- tapOn:
    id: "fab_button"
- waitForAnimationToEnd:
    timeout: 1000

# 2. 如果选项不可见，滚动查找
- runFlow:
    when:
      notVisible: "商品列表.*"
    commands:
      - scrollUntilVisible:
          element:
            text: "商品列表.*"
          direction: DOWN
          timeout: 3000

# 3. 点击目标界面
- tapOn:
    text: "商品列表.*"
- waitForAnimationToEnd:
    timeout: 1000

# 4. 检测红屏错误
- assertNotVisible:
    text: "ERROR_SCREEN_DETECTED"

# 5. 验证页面内容
- assertVisible:
    text: ".*iPhone.*"
- assertVisible:
    text: ".*价格.*"

# 6. 截图
- takeScreenshot: screenshots/04_product_list
```

### 10. 注意事项

- 悬浮按钮使用 `id: "fab_button"` 选择器，而不是文本匹配
- 文本匹配去掉开头的 `.*`，保留结尾的 `.*`，避免类似 "Settings.*" 和 "Album Settings.*" 的冲突
- 错误检测推荐使用 `text: "ERROR_SCREEN_DETECTED"` 匹配 Semantics label，而非文本匹配
- 界面切换后必须等待动画完成再进行断言
- **每个页面测试都使用统一的框架**：点击悬浮按钮 → 检查/滚动查找 → 点击选项 → 错误检测 → 截图
- maestro 运行成功时没有任何输出

### 11. Maestro 测试执行步骤 (MUST EXECUTE)

**⚠️ CRITICAL: 必须真正运行 Maestro 测试，不只是生成配置**

#### 步骤 1: 构建 APK

在运行 Maestro 前，必须先构建 APK：

```bash
flutter build apk --debug
```

**验证 APK 生成成功**:
```bash
ls -lh build/app/outputs/flutter-apk/app-debug.apk
```

#### 步骤 2: 执行 Maestro 测试

**逐个页面执行测试：**

```bash
# 执行每个页面的 Maestro 测试
maestro test .maestro/pages/01_landing_page.yaml
maestro test .maestro/pages/02_login_page.yaml
maestro test .maestro/pages/03_register_page.yaml
# ... 继续执行所有页面
```

**或批量执行所有测试：**

```bash
# 使用循环执行所有测试
for page in .maestro/pages/*.yaml; do
  echo "Testing: $page"
  maestro test "$page"
  if [ $? -ne 0 ]; then
    echo "❌ Test failed: $page"
    exit 1
  fi
done
echo "✅ All Maestro tests passed"
```

**或执行主测试文件（如果配置了）：**

```bash
maestro test .maestro/visual_validation.yaml
```

#### 步骤 3: 验证测试结果

**检查测试是否成功：**

```bash
# 方法 1: 检查截图是否生成（Maestro 截图保存在项目根目录 screenshots/）
ls -la screenshots/*.png

# 方法 2: 统计截图数量，应等于页面数
echo "Screenshots count: $(ls screenshots/*.png 2>/dev/null | wc -l)"

# 方法 3: 验证截图文件大小（非空文件）
ls -lh screenshots/*.png | head -5

# 方法 4: 查看截图预览（macOS）
open screenshots/01_landing_page.png
```

**成功标准：**
- [ ] 每个页面都有对应的截图文件（保存在 `screenshots/` 目录）
- [ ] 截图文件大小 > 0（非空）
- [ ] 截图数量 = 页面数量
- [ ] Maestro 命令返回退出码 0
- [ ] 截图显示页面正确渲染（无崩溃、无红屏）

#### 步骤 4: 处理测试失败

**如果 Maestro 测试失败：**

1. **查看错误信息**：
   ```bash
   maestro test .maestro/pages/01_landing_page.yaml --debug
   ```

2. **常见失败原因**：
   - APK 未构建：运行 `flutter build apk --debug`
   - 应用崩溃：检查 `lib/main.dart` 是否有语法错误
   - 元素未找到：检查 YAML 中的选择器是否正确
   - 超时：增加 `waitForAnimationToEnd` 的 timeout

3. **修复问题后重新运行**：
   ```bash
   # 修复 Flutter 代码...
   flutter build apk --debug
   maestro test .maestro/pages/XX_page.yaml
   ```

#### 步骤 5: 验证截图质量

**截图必须清晰显示页面内容：**

```bash
# 检查所有截图都存在且有效
for screenshot in screenshots/*.png; do
  if [ -s "$screenshot" ]; then
    echo "✅ $screenshot exists and non-empty"
  else
    echo "❌ $screenshot is missing or empty"
  fi
done
```

#### Maestro 执行检查清单

- [ ] **APK 已构建**: `flutter build apk --debug` 成功
- [ ] **所有测试已执行**: 每个 `.maestro/pages/*.yaml` 都运行过
- [ ] **测试全部通过**: 无错误返回码
- [ ] **截图已生成**: `screenshots/` 目录包含所有页面的 PNG 文件
- [ ] **截图数量正确**: 截图数 = 页面数
- [ ] **截图有效**: 所有截图文件非空且可查看

## 集成与验证检查清单

在集成到 DemoShell 和最终交付前，必须完成以下检查：

### 页面集成检查

- [ ] **所有页面文件存在**: `ls lib/pages/*.dart | wc -l` 等于预期页面数
- [ ] **所有页面在 main.dart**: `grep -c "DemoPageConfig(" lib/main.dart` 等于预期页面数
- [ ] **无重复页面名称**: 所有 `DemoPageConfig` 的 `title` 唯一
- [ ] **Client 注入正确**: 所有页面都接收 `client` 参数

### 构建验证

- [ ] **项目构建成功**: `flutter build apk --debug` 或 `flutter build macos` 通过
- [ ] **无编译错误**: `flutter analyze` 无严重问题
- [ ] **测试通过**: `flutter test` 所有 widget 测试通过

### 运行验证 (通过 Maestro)

**NO `flutter run` required - 运行验证通过 Maestro 完成：**

- [ ] **APK 已构建**: `flutter build apk --debug` 成功
- [ ] **Maestro 测试已执行**: `maestro test .maestro/pages/*.yaml` 全部运行
- [ ] **所有测试通过**: Maestro 返回退出码 0
- [ ] **截图已生成**: `screenshots/` 包含所有页面的 PNG 文件
- [ ] **截图证明页面可访问**: 每个截图显示对应页面正确渲染

### Maestro 执行验证 (MUST EXECUTE - 不只是配置)

**必须真正运行测试，不只是生成配置：**

- [ ] **步骤 1 - 构建 APK**: `flutter build apk --debug` 成功生成 APK
- [ ] **步骤 2 - 执行测试**: 运行 `maestro test .maestro/pages/XX_*.yaml` 每个页面
- [ ] **步骤 3 - 验证结果**: 
  - [ ] 检查截图存在: `ls screenshots/*.png | wc -l` 等于页面数
  - [ ] 检查截图非空: `ls -lh screenshots/*.png` 所有文件大小 > 0
- [ ] **步骤 4 - 修复重试**: 如有失败，修复代码后重新运行直到全部通过

## 故障排除

**项目创建失败**：确保 Flutter SDK 已安装并在 PATH 中。运行 `flutter doctor` 检查。

**平台文件缺失**：始终使用 `flutter create` - 永远不要手动复制 Android/iOS 文件。

**Maestro 测试失败**：检查 `ErrorPage` 是否在 `main.dart` 中正确配置。

**构建失败**：
- Java 版本问题：检查 `flutter doctor` 输出的 Java 版本
- Gradle 问题：运行 `cd android && ./gradlew clean`
- 依赖冲突：删除 `pubspec.lock` 并运行 `flutter pub get`

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
