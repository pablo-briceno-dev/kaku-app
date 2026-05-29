import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/models/transaction_type.dart';
import 'package:kaku/features/transactions/widgets/chip_horizontal_item.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';

class OptionsExtraConfig {
  final String label;
  final int id;
  final bool isSelected;

  const OptionsExtraConfig({
    required this.label,
    required this.id,
    required this.isSelected,
  });
}

class HorizontalChipsCategories extends ConsumerWidget {
  final List<OptionsExtraConfig> optionsExtra;
  final VoidCallback? onTap;

  const HorizontalChipsCategories({
    super.key,
    this.optionsExtra = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(addTransactionTypeProvider);
    final categoriesExpenseAsync = ref.watch(expenseCategoriesProvider);
    final categoriesIncomeAsync = ref.watch(incomeCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final categoriesAsync = selectedType == TransactionType.expense
        ? categoriesExpenseAsync
        : categoriesIncomeAsync;

    return categoriesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (categories) {
        final chipsList = List<OptionsExtraConfig>.from(optionsExtra);
        for (final category in categories) {
          chipsList.add(
            OptionsExtraConfig(
              label: '${category.emoji} ${category.name}',
              id: category.id,
              isSelected: category.id == selectedCategory,
            ),
          );
        }

        return SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: chipsList.length,
            itemBuilder: (context, index) {
              final chip = chipsList[index];
              return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChipHorizontalItem(
                      label: chip.label,
                      isSelected: chip.isSelected,
                      onTap: () {
                        if (chip.isSelected) {
                          ref.read(selectedCategoryProvider.notifier).state =
                              null;
                        } else {
                          ref.read(selectedCategoryProvider.notifier).state =
                              chip.id;
                        }
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
