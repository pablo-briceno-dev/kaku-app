import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class CategoryDetailScreen extends ConsumerWidget {
  final int id;
  final int month;
  final int year;

  const CategoryDetailScreen({
    super.key,
    required this.id,
    required this.month,
    required this.year,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(categoryByIdProvider(id));

    return Scaffold(
      appBar: CustomAppBar(
        title: categoryAsync.when(
          data: (category) => Text(
            category != null
                ? '${category.emoji} ${category.name}'
                : 'Categoría $id',
          ),
          error: (e, _) => Text('Categoría $id'),
          loading: () => const Text('Categoría...'),
        ),
      ),
      body: Center(child: Text('CategoryDetailScreen')),
    );
  }
}
