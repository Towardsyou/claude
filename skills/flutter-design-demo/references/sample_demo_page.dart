import 'package:flutter/material.dart';

/// Sample demo page showing client injection pattern
/// This page demonstrates the recommended pattern for creating demo pages
class SampleDemoPage extends StatelessWidget {
  final Map<String, Function> client;
  final List<Map<String, dynamic>>? items;
  final bool isLoading;

  const SampleDemoPage({
    super.key,
    required this.client,
    this.items,
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
            Text('Loading...'),
          ],
        ),
      );
    }

    // Empty state
    if (items == null || items!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No items',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Call client method to fetch data
                client['fetch_items']?.call();
              },
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    // Data state
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (value) {
              // Call client search method
              client['search_items']?.call(value);
            },
          ),
        ),

        // Items list
        Expanded(
          child: ListView.builder(
            itemCount: items!.length,
            itemBuilder: (context, index) {
              final item = items![index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      item['name'][0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(item['name']),
                  subtitle: Text('\$${item['price']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: () {
                      // Call client action method
                      client['add_item']?.call(item['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${item['name']}'),
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
