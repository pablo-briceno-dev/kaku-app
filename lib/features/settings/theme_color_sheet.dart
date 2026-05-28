import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/models/theme_model.dart';
import 'package:kaku/shared/providers/theme_provider.dart';

class ThemeColorSheet extends ConsumerWidget {
  const ThemeColorSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Column(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: AppAccent.values.map((accent) {
            final isSelected = accent == themeMode.accent;
            return InkWell(
              onTap: () => ref.read(themeProvider.notifier).setAccent(accent),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: isSelected ? 80 : 60,
                  height: isSelected ? 80 : 60,
                  padding: EdgeInsets.all(isSelected ? 5 : 0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: accent.color, width: 5),
                  ),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: accent.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
