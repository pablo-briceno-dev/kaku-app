import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/colors_plates.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/features/categories/widgets/category_tile.dart';
import 'package:kaku/shared/providers/database_provider.dart';
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Opacity(
        // Las inactivas se ven translúcidas
        opacity: isActive ? 1.0 : 0.4,
        child: Slidable(
          key: ValueKey('slide_${category.id}'),
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
                      'Editar',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // ── Activar / Desactivar ──
              if (!category.isSystem)
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
                        isActive ? 'Desactivar' : 'Activar',
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
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 20),
                    SizedBox(height: 4),
                    Text(
                      'Eliminar',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          child: CategoryTile(
            category: category,
            catColor: catColor,
            onTap: () => context.push(AppRoutes.categoryDetail),
          ),
        ),
      ),
    );
  }

  void _openEditForm(BuildContext context) {
    AppBottomSheet.show(
      context,
      title: 'Editar categoría',
      isFullScreen: true,
      child: const SizedBox(), // TODO: CategoryFormSheet(category: category)
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Desactivar categoría'),
        content: Text(
          '${category.emoji} ${category.name} tiene $txCount '
          '${txCount == 1 ? 'transacción' : 'transacciones'} asociadas.\n\n'
          'Al desactivarla ya no aparecerá al agregar gastos, '
          'pero las transacciones existentes se conservan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
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
            child: const Text('Desactivar'),
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

    if (txCount > 0) {
      // Tiene transacciones → no se puede eliminar, solo desactivar
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('No se puede eliminar'),
          content: Text(
            '${category.emoji} ${category.name} tiene $txCount '
            '${txCount == 1 ? 'transacción asociada' : 'transacciones asociadas'}.\n\n'
            'Para no perder el historial, solo puedes desactivarla. '
            'Seguirá visible en transacciones pasadas pero no '
            'aparecerá al agregar nuevos gastos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
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
              child: const Text('Desactivar en su lugar'),
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
        title: const Text('Eliminar categoría'),
        content: Text(
          '¿Eliminar ${category.emoji} ${category.name}?\n\n'
          'Esta categoría no tiene transacciones, '
          'por lo que se puede eliminar de forma permanente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref.read(categoriesDaoProvider).deleteCategory(category.id);
    }
  }
}
