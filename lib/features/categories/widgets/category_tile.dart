import 'package:flutter/material.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/features/categories/transaction_count.dart';

class CategoryTile extends StatelessWidget {
  final Category category;
  final Color catColor;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.category,
    required this.catColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: catColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: Text(category.emoji, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
        ),
        subtitle: TransactionCount(categoryId: category.id),
        trailing: ReorderableDragStartListener(
          index: 0,
          child: Icon(
            Icons.drag_indicator_rounded,
            color: cs.onSurfaceVariant.withValues(alpha: 0.35),
            size: 22,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
