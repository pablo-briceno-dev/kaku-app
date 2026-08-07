import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class LocalBackupService {
  static const _backupFileName = 'kaku_backup.zip.enc';

  // ════════════════════════════════════════════════════
  //  CREAR BACKUP LOCAL
  //
  //  Dos opciones al llamarlo:
  //    share: true  → abre el Share sheet del SO para que
  //                   el usuario elija dónde guardarlo
  //                   (Drive, WhatsApp, correo, etc.)
  //    share: false → guarda directo en Downloads
  // ════════════════════════════════════════════════════
  static Future<LocalBackupResult> createBackup({
    required String userKey, // email o cualquier string único del usuario
    bool share = true,
  }) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dbFile = File('${appDir.path}/kaku_app.db');

      if (!await dbFile.exists()) return LocalBackupResult.dbNotFound;

      // 1. Crear ZIP con DB + recibos
      final zipBytes = await _createZip(appDir.path, dbFile);

      // 2. Cifrar con AES-256
      final encryptedBytes = _encrypt(data: zipBytes, key: userKey);

      // 3. Guardar temporalmente
      final tempFile = File('${appDir.path}/kaku_backup_temp.zip.enc');
      await tempFile.writeAsBytes(encryptedBytes);

      if (share) {
        // Opción A: Share sheet — el usuario elige dónde guardarlo
        await SharePlus.instance.share(
          ShareParams(
            text: 'Backup de Kaku — ${_dateLabel()}',
            files: [
              XFile(
                tempFile.path,
                name: _backupFileName,
                mimeType: 'application/octet-stream',
              ),
            ],
          ),
        );
        await tempFile.delete();
      } else {
        // Opción B: Guardar directo en Downloads (requiere permiso)
        final saved = await _saveToDownloads(tempFile);
        await tempFile.delete();
        if (!saved) return LocalBackupResult.permissionDenied;
      }

      return LocalBackupResult.success;
    } catch (e) {
      // debugPrint('LocalBackupService.createBackup error: $e');
      return LocalBackupResult.error;
    }
  }

  // ════════════════════════════════════════════════════
  //  RESTAURAR BACKUP LOCAL
  //
  //  El usuario selecciona el archivo .zip.enc desde
  //  el explorador de archivos del dispositivo.
  //  Luego llama a este método con la ruta del archivo.
  // ════════════════════════════════════════════════════
  static Future<LocalRestoreResult> restoreBackup({
    required String filePath,
    required String userKey,
  }) async {
    try {
      final backupFile = File(filePath);
      if (!await backupFile.exists()) {
        return LocalRestoreResult.fileNotFound;
      }

      // 1. Leer el archivo cifrado
      final encryptedBytes = await backupFile.readAsBytes();

      // 2. Descifrar
      Uint8List zipBytes;
      try {
        zipBytes = _decrypt(data: encryptedBytes, key: userKey);
      } catch (_) {
        // Si el descifrado falla, la clave es incorrecta
        return LocalRestoreResult.wrongKey;
      }

      // 3. Descomprimir y restaurar
      final appDir = await getApplicationDocumentsDirectory();
      await _restoreFromZip(zipBytes, appDir.path);

      return LocalRestoreResult.success;
    } catch (e) {
      // debugPrint('LocalBackupService.restoreBackup error: $e');
      return LocalRestoreResult.error;
    }
  }

  // ════════════════════════════════════════════════════
  //  Info del último backup local
  // ════════════════════════════════════════════════════
  static Future<LocalBackupInfo?> getLastBackupInfo() async {
    try {
      // Busca en la carpeta temporal si hay un backup reciente
      final appDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${appDir.path}/backups');

      if (!await backupDir.exists()) return null;

      final files = await backupDir
          .list()
          .where((f) => f.path.endsWith('.zip.enc'))
          .toList();

      if (files.isEmpty) return null;

      // Ordenar por fecha de modificación (más reciente primero)
      files.sort((a, b) {
        final statA = File(a.path).statSync();
        final statB = File(b.path).statSync();
        return statB.modified.compareTo(statA.modified);
      });

      final last = File(files.first.path);
      final stat = await last.stat();
      final size = await last.length();

      return LocalBackupInfo(
        path: last.path,
        createdAt: stat.modified,
        sizeInBytes: size,
      );
    } catch (_) {
      return null;
    }
  }

  // ════════════════════════════════════════════════════
  //  Helpers privados
  // ════════════════════════════════════════════════════

  static Future<Uint8List> _createZip(String appDirPath, File dbFile) async {
    final encoder = ZipEncoder();
    final archive = Archive();

    // DB
    final dbBytes = await dbFile.readAsBytes();
    archive.addFile(ArchiveFile('kaku_app.db', dbBytes.length, dbBytes));

    // Recibos
    final receiptsDir = Directory('$appDirPath/receipts');
    if (await receiptsDir.exists()) {
      await for (final entity in receiptsDir.list()) {
        if (entity is File) {
          final bytes = await entity.readAsBytes();
          final fileName = entity.path.split('/').last;
          archive.addFile(
            ArchiveFile('receipts/$fileName', bytes.length, bytes),
          );
        }
      }
    }

    return Uint8List.fromList(encoder.encode(archive));
  }

  static Future<void> _restoreFromZip(
    Uint8List zipBytes,
    String appDirPath,
  ) async {
    final archive = ZipDecoder().decodeBytes(zipBytes);
    for (final file in archive) {
      if (file.isFile) {
        final outFile = File('$appDirPath/${file.name}');
        await outFile.parent.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
      }
    }
  }

  static Future<bool> _saveToDownloads(File tempFile) async {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        // Fallback: usar storage básico
        final storage = await Permission.storage.request();
        if (!storage.isGranted) return false;
      }
    }

    try {
      // En Android, getExternalStorageDirectory apunta a la SD o almacenamiento externo
      final extDir = await getExternalStorageDirectory();
      if (extDir == null) return false;

      // Subir un nivel para llegar a la raíz del almacenamiento
      // y luego entrar a Downloads
      final parts = extDir.path.split('/');
      final androidRoot = parts.sublist(0, 4).join('/');
      final downloadsDir = Directory('$androidRoot/Download');

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final destPath = '${downloadsDir.path}/$_backupFileName';
      await tempFile.copy(destPath);
      return true;
    } catch (e) {
      // debugPrint('_saveToDownloads error: $e');
      return false;
    }
  }

  // Cifrado AES-256 — misma lógica que BackupService de Drive
  static Uint8List _encrypt({required Uint8List data, required String key}) {
    final aesKey = enc.Key(
      Uint8List.fromList(sha256.convert(utf8.encode(key)).bytes),
    );
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(aesKey, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encryptBytes(data, iv: iv);

    final result = Uint8List(16 + encrypted.bytes.length);
    result.setAll(0, iv.bytes);
    result.setAll(16, encrypted.bytes);
    return result;
  }

  static Uint8List _decrypt({required Uint8List data, required String key}) {
    final aesKey = enc.Key(
      Uint8List.fromList(sha256.convert(utf8.encode(key)).bytes),
    );
    final iv = enc.IV(Uint8List.sublistView(data, 0, 16));
    final ciphertext = enc.Encrypted(Uint8List.sublistView(data, 16));
    final encrypter = enc.Encrypter(enc.AES(aesKey, mode: enc.AESMode.cbc));
    return Uint8List.fromList(encrypter.decryptBytes(ciphertext, iv: iv));
  }

  static String _dateLabel() {
    final now = DateTime.now();
    return '${now.day}-${now.month}-${now.year}';
  }
}

// ── Modelos de resultado ─────────────────────────────────────
enum LocalBackupResult { success, dbNotFound, permissionDenied, error }

enum LocalRestoreResult { success, fileNotFound, wrongKey, error }

class LocalBackupInfo {
  final String path;
  final DateTime createdAt;
  final int sizeInBytes;

  const LocalBackupInfo({
    required this.path,
    required this.createdAt,
    required this.sizeInBytes,
  });

  String get sizeLabel {
    final mb = sizeInBytes / (1024 * 1024);
    if (mb < 1) return '${(sizeInBytes / 1024).toStringAsFixed(0)} KB';
    return '${mb.toStringAsFixed(1)} MB';
  }
}
