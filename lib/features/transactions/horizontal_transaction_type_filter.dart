import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/models/transaction_type_filter.dart';
import 'package:kaku/features/transactions/categories_chips_bottom_sheet.dart';
import 'package:kaku/features/transactions/widgets/chip_horizontal_item.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';

class HorizontalTransactionTypeFilter extends ConsumerWidget {
  const HorizontalTransactionTypeFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(transactionTypeFilterProvider);
    final categories = ref.watch(getExpenseCategoriesProvider).value;
    final categorySelected = ref.watch(selectedCategoryProvider);
    final category = categories
        ?.where((e) => e.id == categorySelected)
        .firstOrNull;

    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: TransactionTypeFilter.values.length,
        itemBuilder: (context, index) {
          final transactionFilter = TransactionTypeFilter.values[index];
          final chipLabel =
              selectedFilter == TransactionTypeFilter.byCategory &&
                  transactionFilter == TransactionTypeFilter.byCategory
              ? '${category?.emoji ?? '💸'} ${category?.name ?? transactionFilter.label}'
              : '${transactionFilter == TransactionTypeFilter.byCategory ? '💸 ' : ''} ${transactionFilter.label}';

          return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChipHorizontalItem(
                  label: chipLabel,
                  isSelected: selectedFilter == transactionFilter,
                  onTap: () {
                    if (transactionFilter == TransactionTypeFilter.byCategory) {
                      AppBottomSheet.show(
                        context,
                        title: 'Categorías',
                        // isFullScreen: true,
                        child: CategoriesChipsBottomSheet(),
                      );
                    }
                    ref.read(transactionTypeFilterProvider.notifier).state =
                        transactionFilter;
                  },
                ),
              )
              .animate(delay: Duration(milliseconds: index * 50))
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.04, end: 0, duration: 300.ms);
        },
      ),
    );
  }
}
