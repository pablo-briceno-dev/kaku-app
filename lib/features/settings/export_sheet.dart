import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/services/export_service.dart';
import 'package:kaku/shared/services/premium_service.dart';
import 'package:kaku/shared/widgets/premium_gate.dart';

class ExportSheet extends ConsumerStatefulWidget {
  const ExportSheet({super.key});

  @override
  ConsumerState<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends ConsumerState<ExportSheet> {
  _ExportFormat _format = _ExportFormat.csv;
  _ExportPeriod _period = _ExportPeriod.currentMonth;
  DateTimeRange? _range;
  bool _loading = false;

  Future<void> _export() async {
    // Si eligió PDF con recibos, verificar que sea premium
    if (_format == _ExportFormat.pdfWithReceipts) {
      final reason = await PremiumService.canDo(
        PremiumFeature.exportPdfWithReceipts,
      );
      if (reason != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(reason), behavior: SnackBarBehavior.floating),
        );
        return;
      }
    }

    if (_period == _ExportPeriod.customRange && _range == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un rango de fechas'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final selectedMonth = ref.read(selectedMonthProvider);
    final currency = ref.read(currencyProvider);
    final txDao = ref.read(transactionsDaoProvider);
    final (start, end, label) = _periodRange(selectedMonth);
    final txs = await txDao.getTransactionsInRange(start, end);

    if (!mounted) return;

    try {
      switch (_format) {
        case _ExportFormat.csv:
          await ExportService.exportCsv(transactions: txs, currency: currency);
        case _ExportFormat.pdfBasic:
          await ExportService.exportPdf(
            transactions: txs,
            currency: currency,
            periodLabel: label,
          );
        case _ExportFormat.pdfWithReceipts:
          await ExportService.exportPdf(
            transactions: txs,
            currency: currency,
            periodLabel: label,
            withReceipts: true, // ← flag para incluir imágenes
          );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  (DateTime, DateTime, String) _periodRange(({int month, int year}) selected) {
    final now = DateTime.now();
    switch (_period) {
      case _ExportPeriod.currentMonth:
        return (
          DateTime(selected.year, selected.month, 1),
          DateTime(selected.year, selected.month + 1, 0, 23, 59, 59),
          '${_monthName(selected.month)} ${selected.year}',
        );
      case _ExportPeriod.last3Months:
        return (
          DateTime(now.year, now.month - 2, 1),
          DateTime(now.year, now.month + 1, 0, 23, 59, 59),
          'Últimos 3 meses',
        );
      case _ExportPeriod.thisYear:
        return (
          DateTime(now.year, 1, 1),
          DateTime(now.year, 12, 31, 23, 59, 59),
          'Año ${now.year}',
        );
      case _ExportPeriod.customRange:
        if (_range == null) {
          // Fallback al mes actual si no hay rango
          return (
            DateTime(selected.year, selected.month, 1),
            DateTime(selected.year, selected.month + 1, 0, 23, 59, 59),
            'Rango personalizado',
          );
        }
        final start = _range!.start;
        final end = _range!.end;
        return (
          DateTime(start.year, start.month, start.day),
          DateTime(end.year, end.month, end.day, 23, 59, 59),
          '${_formatDate(start)} - ${_formatDate(end)}',
        );
    }
  }

  String _monthName(int m) => const [
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
  ][m - 1];

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  // ── Selector de rango personalizado ───────────────────────────
  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _range,
    );
    if (picked != null) {
      setState(() => _range = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Selector de formato ──────────────────────
          Text(
            'FORMATO',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.1,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),

          // ✅ Lista de opciones en lugar de SegmentedButton
          _FormatTile(
            icon: Icons.table_chart_outlined,
            label: 'CSV',
            desc: 'Para abrir en Excel o Google Sheets',
            isPro: false,
            selected: _format == _ExportFormat.csv,
            onTap: () => setState(() => _format = _ExportFormat.csv),
          ),
          const SizedBox(height: 8),
          _FormatTile(
            icon: Icons.picture_as_pdf_outlined,
            label: 'PDF básico',
            desc: 'Tabla de transacciones sin fotos',
            isPro: false,
            selected: _format == _ExportFormat.pdfBasic,
            onTap: () => setState(() => _format = _ExportFormat.pdfBasic),
          ),
          const SizedBox(height: 8),
          // PDF con recibos — solo premium
          PremiumGate(
            feature: PremiumFeature.exportPdfWithReceipts,
            showLockBadge: false,
            child: _FormatTile(
              icon: Icons.picture_as_pdf_rounded,
              label: 'PDF con recibos',
              desc: 'PDF completo con fotos adjuntas',
              isPro: true,
              selected: _format == _ExportFormat.pdfWithReceipts,
              onTap: () =>
                  setState(() => _format = _ExportFormat.pdfWithReceipts),
            ),
          ),

          const SizedBox(height: 20),

          // ── Selector de período ──────────────────────
          Text(
            'PERÍODO',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.1,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),

          // ✅ RadioGroup reemplaza RadioListTile con groupValue deprecated
          RadioGroup<_ExportPeriod>(
            groupValue: _period,
            onChanged: (v) => setState(() => _period = v!),
            child: Column(
              // ← child con Column
              children: _ExportPeriod.values.map((p) {
                if (p == _ExportPeriod.customRange) {
                  return PremiumGate(
                    feature: PremiumFeature.exportCustomRange,
                    showLockBadge: false,
                    child: Material(
                      type: MaterialType.transparency,
                      child: RadioListTile<_ExportPeriod>(
                        value: p,
                        title: Row(
                          children: [
                            Text(_periodLabel(p)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade700,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.workspace_premium,
                                    size: 9,
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
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return Material(
                  type: MaterialType.transparency,
                  child: RadioListTile<_ExportPeriod>(
                    value: p,
                    title: Text(_periodLabel(p)),
                    // sin groupValue — RadioGroup lo gestiona
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Selector de rango (animado) ──────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: _period == _ExportPeriod.customRange
                ? Padding(
                    padding: const EdgeInsets.only(
                      top: 2,
                      bottom: 8,
                      left: 12,
                      right: 12,
                    ),
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Rango de fechas',
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: cs.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      controller: TextEditingController(
                        text: _range != null
                            ? '${_formatDate(_range!.start)} - ${_formatDate(_range!.end)}'
                            : '',
                      ),
                      onTap: _selectDateRange,
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 8),

          // ── Descripción del formato seleccionado ─────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Container(
              key: ValueKey(_format),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _formatDescription(_format),
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Botón exportar ───────────────────────────
          FilledButton.icon(
            onPressed: _loading ? null : _export,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(_formatIcon(_format), size: 18),
            label: Text(
              _loading ? 'Generando...' : 'Exportar ${_formatLabel(_format)}',
            ),
          ),
        ],
      ),
    );
  }

  String _periodLabel(_ExportPeriod p) => switch (p) {
    _ExportPeriod.currentMonth => 'Mes actual',
    _ExportPeriod.last3Months => 'Últimos 3 meses',
    _ExportPeriod.thisYear => 'Este año',
    _ExportPeriod.customRange => 'Rango personalizado',
  };

  String _formatDescription(_ExportFormat f) => switch (f) {
    _ExportFormat.csv =>
      '📊 CSV: abre en Excel o Google Sheets para análisis detallado.',
    _ExportFormat.pdfBasic =>
      '📄 PDF básico: tabla de transacciones limpia, lista para imprimir.',
    _ExportFormat.pdfWithReceipts =>
      '📄 PDF completo: incluye miniaturas de las fotos de recibos adjuntas. 👑 Premium',
  };

  IconData _formatIcon(_ExportFormat f) => switch (f) {
    _ExportFormat.csv => Icons.download_outlined,
    _ExportFormat.pdfBasic => Icons.picture_as_pdf_outlined,
    _ExportFormat.pdfWithReceipts => Icons.picture_as_pdf_rounded,
  };

  String _formatLabel(_ExportFormat f) => switch (f) {
    _ExportFormat.csv => 'CSV',
    _ExportFormat.pdfBasic => 'PDF básico',
    _ExportFormat.pdfWithReceipts => 'PDF con recibos',
  };
}

// ── Tile de formato de exportación ───────────────────────────
class _FormatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final bool isPro;
  final bool selected;
  final VoidCallback onTap;

  const _FormatTile({
    required this.icon,
    required this.label,
    required this.desc,
    required this.isPro,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary.withValues(alpha: 0.1)
              : cs.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? cs.primary.withValues(alpha: 0.5)
                : cs.outlineVariant.withValues(alpha: 0.3),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Ícono
            Icon(
              icon,
              size: 22,
              color: selected ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 12),

            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected ? cs.primary : cs.onSurface,
                        ),
                      ),
                      if (isPro) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.workspace_premium,
                                size: 9,
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
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            // Radio visual
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? cs.primary : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? cs.primary
                      : cs.onSurface.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: selected
                  ? Icon(Icons.check, size: 12, color: cs.onPrimary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

enum _ExportFormat { csv, pdfBasic, pdfWithReceipts }

enum _ExportPeriod { currentMonth, last3Months, thisYear, customRange }
