import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/features/categories/category_item.dart';
import 'package:kaku/features/categories/widgets/categories_empty_state.dart';

class CategoriesList extends ConsumerWidget {
  final List<Category> categories;

  final Future<void> Function(List<Category>) onReorder;

  const CategoriesList({
    super.key,
    required this.categories,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.isEmpty) {
      return const CategoriesEmptyState();
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: categories.length,
      // Icono de drag que aparece en cada ítem
      proxyDecorator: (child, index, animation) => Material(
        type: MaterialType.transparency,
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
      onReorderItem: (oldIndex, newIndex) {
        final updated = [...categories];
        final item = updated.removeAt(oldIndex);
        updated.insert(newIndex, item);
        onReorder(updated);
      },
      itemBuilder: (context, index) {
        final cat = categories[index];
        // Key obligatorio para ReorderableListView
        return CategoryItem(key: ValueKey(cat.id), category: cat, index: index);
      },
    );
  }
}
