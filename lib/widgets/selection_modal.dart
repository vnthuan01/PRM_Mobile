import 'package:flutter/material.dart';

Future<void> showSelectionModal<T>({
  required BuildContext context,
  required String title,
  required List<Map<String, T>> items,
  required dynamic selectedId,
  required Function(dynamic id) onSelected,
}) async {
  int currentPage = 1;
  String searchQuery = '';

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      final mediaHeight = MediaQuery.of(context).size.height;
      final modalHeight = mediaHeight * 0.7; // chiếm 70% màn hình

      return StatefulBuilder(
        builder: (context, setStateModal) {
          final filtered = items
              .where(
                (e) => e['name']!.toString().toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
              )
              .toList();
          final totalPages = (filtered.length / 7).ceil();
          final paginated = filtered
              .skip((currentPage - 1) * 7)
              .take(7)
              .toList();

          final isDarkMode = Theme.of(context).brightness == Brightness.dark;

          return SafeArea(
            child: Container(
              height: modalHeight,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Search
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Tìm kiếm...',
                        filled: true,
                        fillColor: isDarkMode
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setStateModal(() {
                          searchQuery = value;
                          currentPage = 1;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),

                  // List
                  Expanded(
                    child: ListView.builder(
                      itemCount: paginated.length,
                      itemBuilder: (context, index) {
                        final item = paginated[index];
                        final isSelected = item['id'] == selectedId;
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                          child: ListTile(
                            title: Text(item['name'].toString()),
                            trailing: isSelected
                                ? const Icon(Icons.check)
                                : null,
                            onTap: () {
                              onSelected(item['id']);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // Pagination
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: currentPage > 1
                              ? () => setStateModal(() => currentPage--)
                              : null,
                          child: const Text('Prev'),
                        ),
                        Text('Trang $currentPage / $totalPages'),
                        TextButton(
                          onPressed: currentPage < totalPages
                              ? () => setStateModal(() => currentPage++)
                              : null,
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
