import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/daos/transactions_dao.dart';
import 'package:kaku/core/l10n/date_context_x.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/l10n/app_localizations.dart';
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
    required BuildContext context,
    required List<TransactionWithCategory> transactions,
    required CurrencyType currency,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final buffer = StringBuffer();
    buffer.writeln(l10n.exportCsvHeader);

    for (final txc in transactions) {
      final tx = txc.transaction;
      final cat = txc.category?.name ?? l10n.exportUncategorized;
      // ✅ Usa relative() + time() que sabemos que existen
      final date =
          '${context.dates.relative(tx.date)} ${context.dates.time(tx.date)}';
      final desc = (tx.description ?? cat).replaceAll(',', ' ');
      final type = tx.type == 'expense'
          ? l10n.transactionTypeExpense(count: 1)
          : l10n.transactionTypeIncome(count: 1);
      final amt = CurrencyFormatter.format(tx.amount, currency);
      final quantity = tx.quantity.toString();
      final unitPrice = CurrencyFormatter.format(tx.unitPrice, currency);
      buffer.writeln('$date,$desc,$cat,$type,$quantity,$unitPrice,$amt');
    }

    final dateLabel = context.dates.abbrMonthDayYear(DateTime.now());

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/kaku_export_$dateLabel.csv');
    await file.writeAsString(buffer.toString(), encoding: utf8);

    await SharePlus.instance.share(
      ShareParams(
        text: l10n.exportCsvShareText,
        files: [XFile(file.path, mimeType: 'text/csv')],
      ),
    );
  }

  // ── Exportar PDF ─────────────────────────────────────────
  static Future<void> exportPdf({
    required BuildContext buildContext,
    required List<TransactionWithCategory> transactions,
    required CurrencyType currency,
    required String periodLabel,
    bool withReceipts = false, // ← true solo para premium
  }) async {
    final l10n = AppLocalizations.of(buildContext)!;
    // Extraer todas las etiquetas ANTES de construir el PDF
    final List<String> headers = [
      l10n.exportDate,
      l10n.exportDescription,
      l10n.exportCategory,
      l10n.exportType,
      l10n.exportAmount,
      l10n.exportUnitAmount,
      l10n.exportTotal,
    ];
    final doc = pw.Document();

    final totalExpenses = transactions
        .where((t) => t.transaction.type == 'expense')
        .fold(0.0, (s, t) => s + t.transaction.amount);
    final totalIncome = transactions
        .where((t) => t.transaction.type == 'income')
        .fold(0.0, (s, t) => s + t.transaction.amount);

    final now = DateTime.now();
    final nowLabel = '${now.day}/${now.month}/${now.year}';

    // ── Página principal con la tabla ──
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
                l10n.exportReportTitle(period: periodLabel),
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
                  l10n.transactionTypeIncome(count: 2),
                  CurrencyFormatter.format(totalIncome, currency),
                  PdfColors.green700,
                ),
                _summaryItem(
                  l10n.transactionTypeExpense(count: 2),
                  CurrencyFormatter.format(totalExpenses, currency),
                  PdfColors.red700,
                ),
                _summaryItem(
                  l10n.exportBalance,
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
              0: pw.FlexColumnWidth(1.8), //Fecha
              1: pw.FlexColumnWidth(2.0), //Descripcion
              2: pw.FlexColumnWidth(1.2), //Categoría
              3: pw.FlexColumnWidth(0.8), //Tipo
              4: pw.FlexColumnWidth(0.8), //Cantidad
              5: pw.FlexColumnWidth(1.2), //M.Unitario
              6: pw.FlexColumnWidth(1.2), //Total o Monto
            },
            children: [
              // Cabecera
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: headers
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
                final dateStr = buildContext.dates.dayMonth(tx.date);
                return pw.TableRow(
                  children: [
                    _cell(dateStr),
                    _cell(tx.description ?? txc.category?.name ?? '—'),
                    _cell(txc.category?.name ?? l10n.exportUncategorized),
                    _cell(
                      isExp
                          ? l10n.transactionTypeExpense(count: 1)
                          : l10n.transactionTypeIncome(count: 1),
                    ),
                    _cell(tx.quantity.toString()),
                    _cell(CurrencyFormatter.format(tx.unitPrice, currency)),
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

    // ── Páginas de recibos (solo premium) ──────────────────
    if (withReceipts) {
      for (final txc in transactions) {
        final tx = txc.transaction;
        if (tx.receiptPath == null) continue;

        final receiptFile = File(tx.receiptPath!);
        if (!await receiptFile.exists()) continue;

        final imageBytes = await receiptFile.readAsBytes();
        final image = pw.MemoryImage(imageBytes);
        if (!buildContext.mounted) return;
        final dateStr = buildContext.dates.dayMonth(tx.date);
        final desc = tx.description ?? txc.category?.name ?? l10n.exportUncategorized;

        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            build: (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Mini encabezado del recibo
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        l10n.exportReceiptTitle(desc),
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      pw.Text(
                        '$dateStr · ${CurrencyFormatter.format(tx.amount, currency)}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
                // Imagen del recibo centrada
                pw.Center(
                  child: pw.Image(image, fit: pw.BoxFit.contain, height: 600),
                ),
              ],
            ),
          ),
        );
      }
    }

    final dateLabel = buildContext.dates.abbrMonthDayYear(DateTime.now());

    final bytes = await doc.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/kaku_reporte_$dateLabel.pdf');
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        text: l10n.exportReportTitle(period: periodLabel),
        files: [XFile(file.path, mimeType: 'application/pdf')],
      ),
    );
  }

  // ── PDF con imágenes de recibos (PREMIUM) ─────────────────
  // Mantiene compatibilidad - delega a exportPdf con withReceipts: true
  static Future<void> exportPdfWithReceipts({
    required BuildContext context,
    required List<TransactionWithCategory> transactions,
    required CurrencyType currency,
    required String periodLabel,
  }) async {
    final canExport = await PremiumService.canDo(
      PremiumFeature.exportPdfWithReceipts,
    );
    if (canExport != null) throw Exception(canExport);
    if (!context.mounted) return;

    await exportPdf(
      buildContext: context,
      transactions: transactions,
      currency: currency,
      periodLabel: periodLabel,
      withReceipts: true,
    );
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
