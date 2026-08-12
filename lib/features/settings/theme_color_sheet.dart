import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/models/theme_model.dart';
import 'package:kaku/shared/providers/theme_provider.dart';
import 'package:kaku/shared/services/premium_service.dart';
import 'package:kaku/shared/widgets/premium_gate.dart';
import 'package:kaku/shared/widgets/selected_color_picker.dart';

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
          children: [
            ...AppAccent.values.map((accent) {
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
            }),
            // Selector de color personalizado (PREMIUM)
            Stack(
              alignment: Alignment.topRight,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SelectedColorPicker(
                    key: ValueKey(
                      themeMode.customAccentColor ?? themeMode.accentColor,
                    ),
                    onColorSelected: (color) => ref
                        .read(themeProvider.notifier)
                        .setCustomAccentColor(color),
                    initialColor:
                        themeMode.customAccentColor ?? themeMode.accentColor,
                    size: 60,
                  ),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          size: 10,
                          color: Colors.white,
                        ),
                        SizedBox(width: 2),
                        Text(
                          'PRO',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // PremiumGate(
            //   feature: PremiumFeature.customThemeColor,
            //   showLockBadge: false,
            //   child: Stack(
            //     alignment: Alignment.topRight,
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.all(4.0),
            //         child: SelectedColorPicker(
            //           onColorSelected: (color) => ref
            //               .read(themeProvider.notifier)
            //               .setCustomAccentColor(color),
            //           initialColor:
            //               themeMode.customAccentColor ?? themeMode.accentColor,
            //           size: 60,
            //         ),
            //       ),
            //       Positioned(
            //         top: -2,
            //         right: -2,
            //         child: Container(
            //           padding: const EdgeInsets.symmetric(
            //             horizontal: 6,
            //             vertical: 2,
            //           ),
            //           decoration: BoxDecoration(
            //             color: Colors.amber.shade700,
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //           child: const Row(
            //             mainAxisSize: MainAxisSize.min,
            //             children: [
            //               Icon(
            //                 Icons.workspace_premium,
            //                 size: 10,
            //                 color: Colors.white,
            //               ),
            //               SizedBox(width: 2),
            //               Text(
            //                 'PRO',
            //                 style: TextStyle(
            //                   fontSize: 8,
            //                   fontWeight: FontWeight.w800,
            //                   color: Colors.white,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ],
    );
  }
}
