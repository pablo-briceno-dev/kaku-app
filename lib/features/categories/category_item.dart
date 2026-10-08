import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/colors_plates.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/l10n/category_l10n.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/features/categories/category_form_sheet.dart';
import 'package:kaku/features/categories/widgets/category_tile.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';

class CategoryItem extends ConsumerWidget {
  final Category category;
  final int index;

  const CategoryItem({required this.category, required this.index, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final catColor = hexToColor(category.colorHex);
    final isActive = category.isActive;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Opacity(
        // Las inactivas se ven translúcidas
        opacity: isActive ? 1.0 : 0.4,
        child: Material(
          type: MaterialType.transparency,
          child: Slidable(
            key: ValueKey('slide_${category.id}'),
            // key: ValueKey(category.id),
            // key: ObjectKey(category),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.62,
              children: [
                // ── Editar ──
                CustomSlidableAction(
                  onPressed: (_) => _openEditForm(context),
                  backgroundColor: cs.primary.withValues(alpha: 0.12),
                  foregroundColor: cs.primary,
                  borderRadius: BorderRadius.circular(12),
                  padding: EdgeInsets.zero,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_outlined, size: 20),
                      SizedBox(height: 4),
                      Text(
                        l10n.btnEdit,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Activar / Desactivar ──
                if (!category.isSystem) ...[
                  CustomSlidableAction(
                    onPressed: (_) => _toggleActive(context, ref),
                    backgroundColor: isActive
                        ? cs.error.withValues(alpha: 0.12)
                        : cs.primary.withValues(alpha: 0.12),
                    foregroundColor: isActive ? cs.error : cs.primary,
                    borderRadius: BorderRadius.circular(12),
                    padding: EdgeInsets.zero,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isActive
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isActive ? l10n.btnDeactivate : l10n.btnActivate,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomSlidableAction(
                    onPressed: (_) => _tryDelete(context, ref),
                    backgroundColor: cs.error.withValues(alpha: 0.12),
                    foregroundColor: cs.error,
                    borderRadius: BorderRadius.circular(12),
                    padding: EdgeInsets.zero,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 20),
                        SizedBox(height: 4),
                        Text(
                          l10n.btnDelete,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            child: CategoryTile(
              category: category,
              catColor: catColor,
              onTap: () {
                Slidable.of(context)?.close();

                context.push(
                  AppRoutes.toCategory(
                    category.id,
                    selectedMonth.month,
                    selectedMonth.year,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _openEditForm(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    AppBottomSheet.show(
      context,
      title: l10n.editCategoryTitle,
      isFullScreen: true,
      child: CategoryFormSheet(
        category: category,
        defaultName: category.displayName(context),
      ),
    );
  }

  Future<void> _toggleActive(BuildContext context, WidgetRef ref) async {
    // Si quiere desactivar y tiene transacciones → aviso
    if (category.isActive) {
      final txCount = await ref
          .read(transactionsDaoProvider)
          .countByCategory(category.id);

      if (txCount > 0 && context.mounted) {
        _showDeactivateConfirm(context, ref, txCount);
        return;
      }
    }

    await ref
        .read(categoriesDaoProvider)
        .toggleActive(category.id, !category.isActive);
  }

  void _showDeactivateConfirm(
    BuildContext context,
    WidgetRef ref,
    int txCount,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.categoryDeactivateTitle),
        content: Text(
          l10n.categoryDeactivateSubtitle(
            emoji: category.emoji,
            category: category.displayName(context),
            txCount: txCount,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.btnCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(categoriesDaoProvider)
                  .toggleActive(category.id, false);
            },
            child: Text(l10n.btnDeactivate),
          ),
        ],
      ),
    );
  }

  Future<void> _tryDelete(BuildContext context, WidgetRef ref) async {
    final txCount = await ref
        .read(transactionsDaoProvider)
        .countByCategory(category.id);

    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;

    if (txCount > 0) {
      // Tiene transacciones → no se puede eliminar, solo desactivar
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(l10n.categoryNotDeleted),
          content: Text(
            l10n.categoryNotDeletedSubtitle(
              emoji: category.emoji,
              category: category.displayName(context),
              txCount: txCount,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.btnUnderstood),
            ),
            // Ofrece desactivar como alternativa
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await ref
                    .read(categoriesDaoProvider)
                    .toggleActive(category.id, false);
              },
              child: Text(l10n.btnDisableInstead),
            ),
          ],
        ),
      );
      return;
    }

    // Sin transacciones → confirmar eliminación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.categoryDeleteConfirm),
        content: Text(
          l10n.categoryDeleteConfirmSubtitle(
            emoji: category.emoji,
            category: category.displayName(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.btnCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.btnDelete),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref.read(categoriesDaoProvider).deleteCategory(category.id);
    }
  }
}
