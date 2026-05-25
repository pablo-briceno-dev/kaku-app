import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/features/transactions/widgets/chip_horizontal_item.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';

class CategoriesChipsBottomSheet extends ConsumerWidget {
  final VoidCallback? onTap;

  const CategoriesChipsBottomSheet({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(getExpenseCategoriesProvider);
    final categorySelected = ref.watch(selectedCategoryProvider);

    return categoriesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (categories) {
        if (categories.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == categories.length - 1 ? 20 : 12,
                    ),
                    child: ChipHorizontalItem(
                      label: '${category.emoji} ${category.name}',
                      isSelected: category.id == categorySelected,
                      onTap: category.id == categorySelected
                          ? null
                          : () {
                              ref
                                      .read(selectedCategoryProvider.notifier)
                                      .state =
                                  category.id;
                              onTap?.call();
                              Navigator.of(context).pop();
                            },
                    ),
                  )
                  .animate(delay: Duration(milliseconds: index * 50))
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.04, end: 0, duration: 300.ms);
            },
          ),
        );
      },
    );
  }
}
