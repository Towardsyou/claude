import 'package:flutter/material.dart';
import 'demo_shell.dart';
import 'error_page.dart';
import 'pages/sample_demo_page.dart';

void main() {
  // Create Client object, inject business functionality
  final client = <String, Function>{
    'fetch_items': () async {
      // Simulate fetching items
      await Future.delayed(const Duration(seconds: 1));
      return [
        {'id': 1, 'name': 'Item A', 'price': 99.0},
        {'id': 2, 'name': 'Item B', 'price': 149.0},
        {'id': 3, 'name': 'Item C', 'price': 199.0},
      ];
    },
    'add_item': (itemId) {
      // Add item to cart
      debugPrint('Added item $itemId to cart');
    },
    'search_items': (query) {
      // Search items
      debugPrint('Search: $query');
    },
  };

  // Define demo page list
  final pages = [
    DemoPageConfig(
      title: 'Sample List (With Data)',
      builder: (context) => SampleDemoPage(
        client: client,
        items: const [
          {'id': 1, 'name': 'Product 1', 'price': 99.0},
          {'id': 2, 'name': 'Product 2', 'price': 149.0},
          {'id': 3, 'name': 'Product 3', 'price': 199.0},
          {'id': 4, 'name': 'Product 4', 'price': 249.0},
        ],
      ),
    ),
    DemoPageConfig(
      title: 'Sample List (Empty)',
      builder: (context) => const SampleDemoPage(
        client: client,
        items: [],
      ),
    ),
    DemoPageConfig(
      title: 'Sample List (Loading)',
      builder: (context) => const SampleDemoPage(
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
      title: 'Flutter Project Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Use builder to capture all Flutter errors
      builder: (context, widget) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return ErrorPage(errorDetails: errorDetails);
        };
        return widget!;
      },
      home: DemoShell(
        pages: pages,
        fabColor: Colors.blue.withOpacity(0.8),
      ),
    );
  }
}
