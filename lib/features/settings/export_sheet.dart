import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/services/export_service.dart';

class ExportSheet extends ConsumerStatefulWidget {
  const ExportSheet({super.key});

  @override
  ConsumerState<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends ConsumerState<ExportSheet> {
  _ExportFormat _format = _ExportFormat.csv;
  _ExportPeriod _period = _ExportPeriod.currentMonth;
  bool _loading = false;

  Future<void> _export() async {
    setState(() => _loading = true);

    final selectedMonth = ref.read(selectedMonthProvider);
    final currency = ref.read(currencyProvider);
    final txDao = ref.read(transactionsDaoProvider);

    // Calcular rango de fechas según el período
    final (start, end, label) = _periodRange(selectedMonth);

    // Obtener transacciones del período
    final txs = await txDao.getTransactionsInRange(start, end);

    if (!mounted) return;

    try {
      if (_format == _ExportFormat.csv) {
        await ExportService.exportCsv(transactions: txs, currency: currency);
      } else {
        await ExportService.exportPdf(
          transactions: txs,
          currency: currency,
          periodLabel: label,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  (DateTime, DateTime, String) _periodRange(({int month, int year}) selected) {
    final now = DateTime.now();
    return switch (_period) {
      _ExportPeriod.currentMonth => (
        DateTime(selected.year, selected.month, 1),
        DateTime(selected.year, selected.month + 1, 0, 23, 59, 59),
        '${_monthName(selected.month)} ${selected.year}',
      ),
      _ExportPeriod.last3Months => (
        DateTime(now.year, now.month - 2, 1),
        DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        'Últimos 3 meses',
      ),
      _ExportPeriod.thisYear => (
        DateTime(now.year, 1, 1),
        DateTime(now.year, 12, 31, 23, 59, 59),
        'Año ${now.year}',
      ),
    };
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selector de formato
          Text(
            'FORMATO',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.1,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<_ExportFormat>(
            segments: const [
              ButtonSegment(
                value: _ExportFormat.csv,
                icon: Icon(Icons.table_chart_outlined),
                label: Text('CSV'),
              ),
              ButtonSegment(
                value: _ExportFormat.pdf,
                icon: Icon(Icons.picture_as_pdf_outlined),
                label: Text('PDF'),
              ),
            ],
            selected: {_format},
            onSelectionChanged: (s) => setState(() => _format = s.first),
          ),

          const SizedBox(height: 20),

          // Selector de período
          Text(
            'PERÍODO',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.1,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          ..._ExportPeriod.values.map(
            (p) => RadioListTile<_ExportPeriod>(
              value: p,
              groupValue: _period,
              onChanged: (v) => setState(() => _period = v!),
              title: Text(
                _periodLabel(p),
                style: const TextStyle(fontSize: 13),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(height: 8),

          // Descripción del formato
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _format == _ExportFormat.csv
                  ? '📊 CSV: abre en Excel o Google Sheets para análisis detallado.'
                  : '📄 PDF: diseño limpio listo para imprimir o compartir.',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 16),

          // Botón exportar
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
                : Icon(
                    _format == _ExportFormat.csv
                        ? Icons.download_outlined
                        : Icons.picture_as_pdf_outlined,
                    size: 18,
                  ),
            label: Text(
              _loading
                  ? 'Generando...'
                  : 'Exportar como ${_format.name.toUpperCase()}',
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
  };
}

enum _ExportFormat { csv, pdf }

enum _ExportPeriod { currentMonth, last3Months, thisYear }
