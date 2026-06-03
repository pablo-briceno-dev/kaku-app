import 'dart:convert';
import 'dart:io';

import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/daos/transactions_dao.dart';
import 'package:kaku/core/date_formatter.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/shared/services/premium_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ExportService {
  // Verifica si el formato está disponible para el plan actual
  static Future<bool> isFormatAvailable(ExportFormat format) async {
    final premium = await PremiumService.isPremium();
    if (premium) return true;

    return switch (format) {
      ExportFormat.csv => true, // free ✅
      ExportFormat.pdfBasic => true, // free ✅
      ExportFormat.pdfWithReceipts => false, // solo premium ❌
    };
  }

  // ── Exportar CSV ─────────────────────────────────────────
  static Future<void> exportCsv({
    required List<TransactionWithCategory> transactions,
    required CurrencyType currency,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('Fecha,Descripcion,Categoria,Tipo,Monto');

    for (final txc in transactions) {
      final tx = txc.transaction;
      final cat = txc.category?.name ?? 'Sin categoría';
      // ✅ Usa relative() + time() que sabemos que existen
      final date =
          '${DateFormatter.relative(tx.date)} ${DateFormatter.time(tx.date)}';
      final desc = (tx.description ?? cat).replaceAll(',', ' ');
      final type = tx.type == 'expense' ? 'Gasto' : 'Ingreso';
      final amt = CurrencyFormatter.format(tx.amount, currency);
      buffer.writeln('$date,$desc,$cat,$type,$amt');
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/kaku_export.csv');
    await file.writeAsString(buffer.toString(), encoding: utf8);

    await SharePlus.instance.share(
      ShareParams(
        text: 'Kaku — Exportación de transacciones',
        files: [XFile(file.path, mimeType: 'text/csv')],
      ),
    );
  }

  // ── Exportar PDF ─────────────────────────────────────────
  static Future<void> exportPdf({
    required List<TransactionWithCategory> transactions,
    required CurrencyType currency,
    required String periodLabel,
  }) async {
    final doc = pw.Document();

    final totalExpenses = transactions
        .where((t) => t.transaction.type == 'expense')
        .fold(0.0, (s, t) => s + t.transaction.amount);
    final totalIncome = transactions
        .where((t) => t.transaction.type == 'income')
        .fold(0.0, (s, t) => s + t.transaction.amount);

    // ✅ Fecha del reporte usando DateTime.now() directamente
    final now = DateTime.now();
    final nowLabel = '${now.day}/${now.month}/${now.year}';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Encabezado
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Kaku - Reporte $periodLabel',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(nowLabel, style: const pw.TextStyle(fontSize: 10)),
            ],
          ),

          pw.SizedBox(height: 16),

          // Resumen
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _summaryItem(
                  'Ingresos',
                  CurrencyFormatter.format(totalIncome, currency),
                  PdfColors.green700,
                ),
                _summaryItem(
                  'Gastos',
                  CurrencyFormatter.format(totalExpenses, currency),
                  PdfColors.red700,
                ),
                _summaryItem(
                  'Balance',
                  CurrencyFormatter.format(
                    totalIncome - totalExpenses,
                    currency,
                  ),
                  PdfColors.blue700,
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // Tabla
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: const {
              0: pw.FlexColumnWidth(1.8),
              1: pw.FlexColumnWidth(2.5),
              2: pw.FlexColumnWidth(1.5),
              3: pw.FlexColumnWidth(1),
              4: pw.FlexColumnWidth(1.5),
            },
            children: [
              // Cabecera
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: ['Fecha', 'Descripción', 'Categoría', 'Tipo', 'Monto']
                    .map(
                      (h) => pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          h,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              // Filas
              ...transactions.map((txc) {
                final tx = txc.transaction;
                final isExp = tx.type == 'expense';
                // ✅ Fecha formateada con DateFormatter.dayMonth()
                final dateStr = DateFormatter.dayMonth(tx.date);
                return pw.TableRow(
                  children: [
                    _cell(dateStr),
                    _cell(tx.description ?? txc.category?.name ?? '—'),
                    _cell(txc.category?.name ?? 'Sin categoría'),
                    _cell(isExp ? 'Gasto' : 'Ingreso'),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        CurrencyFormatter.format(tx.amount, currency),
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: isExp ? PdfColors.red700 : PdfColors.green700,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/kaku_reporte.pdf');
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        text: 'Kaku — Reporte $periodLabel',
        files: [XFile(file.path, mimeType: 'application/pdf')],
      ),
    );
  }

  // ── PDF con imágenes de recibos (PREMIUM) ─────────────────
  static Future<void> exportPdfWithReceipts({
    required List<TransactionWithCategory> transactions,
    required String currency,
    required String periodLabel,
  }) async {
    // Verificar que sea premium antes de llamar
    final canExport = await PremiumService.canDo(
      PremiumFeature.exportPdfWithReceipts,
    );
    if (canExport != null) throw Exception(canExport);

    final doc = pw.Document();
    // ... mismo código del PDF básico pero agrega las imágenes:

    // Para cada transacción con recibo:
    for (final txc in transactions) {
      final tx = txc.transaction;
      if (tx.receiptPath == null) continue;

      final file = File(tx.receiptPath!);
      if (!await file.exists()) continue;

      final imageBytes = await file.readAsBytes();
      final image = pw.MemoryImage(imageBytes);

      // Agrega miniatura en la fila de la tabla
      doc.addPage(
        pw.Page(
          build: (context) => pw.Column(
            children: [
              pw.Text('Recibo — ${DateFormatter.dayMonth(tx.date)}'),
              pw.SizedBox(height: 8),
              pw.Image(image, height: 200, fit: pw.BoxFit.contain),
            ],
          ),
        ),
      );
    }
  }

  static pw.Widget _summaryItem(String label, String value, PdfColor color) =>
      pw.Column(
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      );

  static pw.Widget _cell(String t) => pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(t, style: const pw.TextStyle(fontSize: 9)),
  );
}

enum ExportFormat {
  csv, // free + premium
  pdfBasic, // free + premium (sin imágenes)
  pdfWithReceipts, // solo premium (con imágenes)
}
