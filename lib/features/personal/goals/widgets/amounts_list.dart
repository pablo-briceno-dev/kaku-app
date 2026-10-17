import 'package:flutter/material.dart';

class AmountsList extends StatelessWidget {
  final List<(String, num)> amounts;
  final int selectedAmount;
  final Function(int) onAmountSelected;

  const AmountsList({
    super.key,
    required this.amounts,
    required this.selectedAmount,
    required this.onAmountSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 50,
        crossAxisSpacing: 12,
        mainAxisSpacing: 15,
      ),
      itemCount: amounts.length,
      itemBuilder: (_, index) {
        final (label, amount) = amounts[index];
        final isSelected = index == selectedAmount;

        return InkWell(
          onTap: () => onAmountSelected(index),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color:
                  (isSelected
                          ? cs.primaryContainer
                          : cs.surfaceContainerHighest)
                      .withAlpha(50),
              border: Border.all(
                color: isSelected
                    ? cs.primaryContainer
                    : cs.surfaceContainerHighest,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 25,
                  color: isSelected ? cs.primary : cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
