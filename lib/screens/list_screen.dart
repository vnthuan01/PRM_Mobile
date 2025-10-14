import 'package:flutter/material.dart';
import '../widgets/empty_state.dart';

class ListScreen extends StatelessWidget {
  final List<String> items;
  const ListScreen({super.key, this.items = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách'), centerTitle: true, backgroundColor: Theme.of(context).scaffoldBackgroundColor, foregroundColor: Theme.of(context).colorScheme.primary),
      body: items.isEmpty
          ? const EmptyState(message: 'Không có dữ liệu')
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.list, color: Theme.of(context).colorScheme.primary),
                  title: Text(items[index], style: Theme.of(context).textTheme.titleMedium),
                  trailing: const Icon(Icons.chevron_right, color: Colors.black26),
                  onTap: (){},
                );
              },
            ),
    );
  }
}
