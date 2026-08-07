import 'dart:io';

import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/receipt_storage.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  // Info del espacio usado
  static Future<StorageInfo> getInfo() async {
    final sizeMb = await ReceiptStorage.sizeInMB();
    final count = await _countReceipts();
    return StorageInfo(sizeMb: sizeMb, count: count);
  }

  static Future<int> _countReceipts() async {
    final dir = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/receipts',
    );
    if (!await dir.exists()) return 0;
    int count = 0;
    await for (final _ in dir.list()) {
      count++;
    }
    return count;
  }

  // Elimina todos los recibos del disco
  // Llama esto DESPUÉS de poner receiptPath = null en todas las txs
  static Future<void> clearReceipts(AppDatabase db) async {
    // 1. Limpia los paths en la DB
    await db.customStatement(
      "UPDATE transactions_table SET receipt_path = NULL "
      "WHERE receipt_path IS NOT NULL",
    );
    // 2. Elimina los archivos del disco
    await ReceiptStorage.deleteAll();
  }
}

class StorageInfo {
  final double sizeMb;
  final int count;
  const StorageInfo({required this.sizeMb, required this.count});

  String get sizeLabel {
    if (sizeMb < 1) return '${(sizeMb * 1024).toStringAsFixed(0)} KB';
    return '${sizeMb.toStringAsFixed(1)} MB';
  }
}
