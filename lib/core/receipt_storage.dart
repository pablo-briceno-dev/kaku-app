import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ReceiptStorage {
  // ════════════════════════════════════════════════════════
  //  Directorio donde se guardan todos los recibos.
  //
  //  getApplicationDocumentsDirectory() devuelve:
  //    Android: /data/data/com.tuapp.kaku/files/
  //    iOS:     /var/mobile/Containers/Data/Application/<UUID>/Documents/
  //
  //  El subdirectorio 'receipts' lo creamos nosotros para
  //  mantener el directorio raíz ordenado.
  // ════════════════════════════════════════════════════════
  static Future<Directory> get _receiptsDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory(path.join(appDir.path, 'receipts'));

    // Crea el directorio si no existe (la primera vez)
    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }

    return receiptsDir;
  }

  // ════════════════════════════════════════════════════════
  //  save() — Copia la imagen temporal al almacenamiento
  //  persistente y devuelve la nueva ruta permanente.
  //
  //  [tempPath] : ruta temporal de image_picker (file.path)
  //
  //  Devuelve la ruta permanente para guardar en la DB.
  //
  //  Ejemplo:
  //    final tempPath = pickedFile.path;
  //    final savedPath = await ReceiptStorage.save(tempPath);
  //    // savedPath → ".../receipts/receipt_1716230400000.jpg"
  //    // Guarda savedPath en TransactionsTable.receiptPath
  // ════════════════════════════════════════════════════════
  static Future<String> save(String tempPath) async {
    final dir = await _receiptsDir;

    // Nombre único basado en timestamp — evita colisiones
    // si el usuario adjunta dos recibos en el mismo segundo
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(tempPath).toLowerCase();
    final ext = extension.isEmpty ? '.jpg' : extension;
    final fileName = 'receipt_$timestamp$ext';
    final destPath = path.join(dir.path, fileName);

    // Copia el archivo de la ruta temporal a la permanente
    await File(tempPath).copy(destPath);

    return destPath;
  }

  // ════════════════════════════════════════════════════════
  //  delete() — Elimina el archivo del disco.
  //  Llámalo cuando el usuario elimine una transacción
  //  o quite la foto de un recibo.
  //
  //  No lanza excepción si el archivo no existe.
  // ════════════════════════════════════════════════════════
  static Future<void> delete(String? filePath) async {
    if (filePath == null) return;
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // ════════════════════════════════════════════════════════
  //  exists() — Verifica si el archivo sigue en disco.
  //  Úsalo antes de mostrar la imagen para evitar errores.
  // ════════════════════════════════════════════════════════
  static Future<bool> exists(String? filePath) async {
    if (filePath == null) return false;
    return File(filePath).exists();
  }

  // ════════════════════════════════════════════════════════
  //  deleteAll() — Elimina todos los recibos guardados.
  //  Úsalo si el usuario borra todos sus datos desde
  //  Configuración → "Borrar todos los datos".
  // ════════════════════════════════════════════════════════
  static Future<void> deleteAll() async {
    final dir = await _receiptsDir;
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  // ════════════════════════════════════════════════════════
  //  sizeInMB() — Tamaño total de todos los recibos en MB.
  //  Útil para mostrarlo en Configuración.
  // ════════════════════════════════════════════════════════
  static Future<double> sizeInMB() async {
    final dir = await _receiptsDir;
    if (!await dir.exists()) return 0.0;

    int totalBytes = 0;
    await for (final entity in dir.list()) {
      if (entity is File) {
        totalBytes += await entity.length();
      }
    }
    return totalBytes / (1024 * 1024);
  }
}
