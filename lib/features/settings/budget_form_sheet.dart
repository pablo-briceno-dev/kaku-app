// lib/features/budgets/budget_form_sheet.dart
//
// Bottom sheet para crear o editar el presupuesto de una categoría.
// Se abre desde BudgetListScreen al tocar una categoría.
// Usa AppBottomSheet.show() para abrirlo.

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/shared/providers/database_provider.dart';

class BudgetFormSheet extends ConsumerStatefulWidget {
  /// Categoría a la que se le asigna el presupuesto.
  final Category category;

  /// Budget existente — si es null se está creando uno nuevo.
  final Budget? existingBudget;

  /// Mes y año para el que aplica este presupuesto.
  final int month;
  final int year;

  const BudgetFormSheet({
    super.key,
    required this.category,
    required this.month,
    required this.year,
    this.existingBudget,
  });

  @override
  ConsumerState<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends ConsumerState<BudgetFormSheet> {
  late final TextEditingController _limitController;
  bool _rollover = false; // si el sobrante pasa al siguiente mes
  bool _isSaving = false;

  bool get _isEditing => widget.existingBudget != null;

  @override
  void initState() {
    super.initState();
    // Si edita, pre-carga el límite formateado
    final initial = widget.existingBudget?.limitAmount;
    _limitController = TextEditingController(
      text: initial != null && initial > 0
          ? CurrencyFormatter.format(initial)
          : '',
    );
    _rollover = widget.existingBudget?.rollover ?? false;
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = CurrencyFormatter.parse(_limitController.text);

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un límite mayor a 0'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final dao = ref.read(budgetsDaoProvider);

    // upsertBudget: inserta si no existe, actualiza si ya existe.
    // La clave única es (categoryId + month + year).
    await dao.upsertBudget(
      BudgetsTableCompanion.insert(
        categoryId: widget.category.id,
        limitAmount: amount,
        month: widget.month,
        year: widget.year,
        rollover: drift.Value(_rollover),
      ),
    );

    if (mounted) Navigator.of(context).pop(true); // true = guardó
  }

  Future<void> _delete() async {
    if (widget.existingBudget == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar presupuesto'),
        content: Text(
          '¿Eliminar el presupuesto de ${widget.category.emoji} '
          '${widget.category.name} para este mes?',
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

    if (confirm != true) return;

    await ref.read(budgetsDaoProvider).deleteBudget(widget.existingBudget!.id);

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Color de la categoría para el ícono
    final catColor = Color(
      int.parse(widget.category.colorHex.replaceFirst('#', 'FF'), radix: 16),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Categoría seleccionada ──
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.category.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${_monthName(widget.month)} ${widget.year}',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Campo de límite ──
          Text(
            'LÍMITE MENSUAL',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.12,
              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _limitController,
            keyboardType: TextInputType.number,
            autofocus: true,
            inputFormatters: [CurrencyFormatter.inputFormatter()],
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: catColor,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '\$0',
              hintStyle: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: cs.onSurface.withValues(alpha: 0.2),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),

          // ── Sugerencias rápidas ──
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final amount in [100000.0, 300000.0, 500000.0, 1000000.0])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ActionChip(
                    label: Text(CurrencyFormatter.compact(amount)),
                    labelStyle: const TextStyle(fontSize: 11),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _limitController.text = CurrencyFormatter.format(amount);
                    },
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Toggle rollover ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Acumular sobrante',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Si gastas menos de lo planeado, '
                        'el sobrante se suma al próximo mes.',
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: _rollover,
                  onChanged: (v) => setState(() => _rollover = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Botón guardar ──
          FilledButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _isEditing ? 'Actualizar presupuesto' : 'Crear presupuesto',
                  ),
          ),

          // ── Botón eliminar (solo al editar) ──
          if (_isEditing) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _delete,
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.error,
                side: BorderSide(color: cs.error.withValues(alpha: 0.4)),
              ),
              child: const Text('Eliminar presupuesto'),
            ),
          ],
        ],
      ),
    );
  }

  String _monthName(int month) => const [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ][month - 1];
}
