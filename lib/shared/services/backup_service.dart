import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:kaku/core/database/app_database.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class BackupService {
  static final _signIn = GoogleSignIn.instance;
  static const _driveScopes = [drive.DriveApi.driveFileScope];
  static const _backupFileName = 'kaku_backup.zip.enc'; // cifrado + zipeado

  static GoogleSignInAccount? _currentUser;
  static bool get isSignedIn => _currentUser != null;
  static GoogleSignInAccount? get currentUser => _currentUser;

  static void _onAuthEvent(GoogleSignInAuthenticationEvent event) {
    _currentUser = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };
  }

  static Future<void> initialize({String? serverClientId}) async {
    await _signIn.initialize(serverClientId: serverClientId);
    _signIn.authenticationEvents
        .listen(_onAuthEvent)
        .onError((e) => debugPrint('Auth error: $e'));
    _signIn.attemptLightweightAuthentication();
  }

  static Future<bool> authenticate() async {
    try {
      if (!_signIn.supportsAuthenticate()) return false;
      await _signIn.authenticate();
      return _currentUser != null;
    } on GoogleSignInException catch (e) {
      // debugPrint('BackupService.authenticate error: $e');
      return false;
    }
  }

  static Future<void> signOut() async {
    await _signIn.signOut();
    _currentUser = null;
  }

  // ════════════════════════════════════════════════════
  //  BACKUP — empaqueta, cifra y sube a Drive
  // ════════════════════════════════════════════════════
  static Future<BackupResult> backup(AppDatabase db) async {
    try {
      if (_currentUser == null) return BackupResult.notSignedIn;

      final authorization =
          await _currentUser!.authorizationClient.authorizationForScopes(
            _driveScopes,
          ) ??
          await _currentUser!.authorizationClient.authorizeScopes(_driveScopes);

      final appDir = await getApplicationDocumentsDirectory();
      final dbFile = File(path.join(appDir.path, 'kaku_app.db'));
      if (!await dbFile.exists()) return BackupResult.dbNotFound;

      // 1. Crear ZIP con la DB + carpeta de recibos
      final zipBytes = await _createZip(appDir.path, dbFile);

      // 2. Cifrar el ZIP con AES-256
      // La clave se deriva del email del usuario → única por cuenta
      final encryptedBytes = _encrypt(
        data: zipBytes,
        email: _currentUser!.email,
      );

      // 3. Guardar temporalmente el archivo cifrado
      final tempFile = File('${appDir.path}/kaku_backup_temp.zip.enc');
      await tempFile.writeAsBytes(encryptedBytes);

      // 4. Subir a Drive
      final client = _AuthClient(authorization.accessToken);
      final driveApi = drive.DriveApi(client);
      final folderId = await _getOrCreateFolder(driveApi);
      final existing = await _findExistingBackup(driveApi, folderId);

      final media = drive.Media(
        tempFile.openRead(),
        await tempFile.length(),
        contentType: 'application/octet-stream',
      );

      if (existing != null) {
        await driveApi.files.update(
          drive.File()..name = _backupFileName,
          existing,
          uploadMedia: media,
        );
      } else {
        await driveApi.files.create(
          drive.File()
            ..name = _backupFileName
            ..parents = [folderId],
          uploadMedia: media,
        );
      }

      // 5. Limpiar archivo temporal
      await tempFile.delete();
      client.close();

      return BackupResult.success;
    } on GoogleSignInException {
      return BackupResult.notSignedIn;
    } catch (e) {
      // debugPrint('BackupService.backup error: $e');
      return BackupResult.error;
    }
  }

  // ════════════════════════════════════════════════════
  //  RESTAURAR — descarga, descifra y descomprime
  // ════════════════════════════════════════════════════
  static Future<RestoreResult> restore() async {
    try {
      if (_currentUser == null) return RestoreResult.notSignedIn;

      final authorization =
          await _currentUser!.authorizationClient.authorizationForScopes(
            _driveScopes,
          ) ??
          await _currentUser!.authorizationClient.authorizeScopes(_driveScopes);

      final client = _AuthClient(authorization.accessToken);
      final driveApi = drive.DriveApi(client);
      final folderId = await _getOrCreateFolder(driveApi);
      final fileId = await _findExistingBackup(driveApi, folderId);

      if (fileId == null) return RestoreResult.noBackupFound;

      // 1. Descargar el archivo cifrado
      final response =
          await driveApi.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final bytes = <int>[];
      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
      }
      final encryptedBytes = Uint8List.fromList(bytes);

      // 2. Descifrar
      final zipBytes = _decrypt(
        data: encryptedBytes,
        email: _currentUser!.email,
      );

      // 3. Descomprimir y restaurar archivos
      final appDir = await getApplicationDocumentsDirectory();
      await _restoreFromZip(zipBytes, appDir.path);

      client.close();
      return RestoreResult.success;
    } catch (e) {
      // debugPrint('BackupService.restore error: $e');
      return RestoreResult.error;
    }
  }

  // ════════════════════════════════════════════════════
  //  Helpers privados
  // ════════════════════════════════════════════════════

  // Crea ZIP con kaku.db + todos los recibos
  static Future<Uint8List> _createZip(String appDirPath, File dbFile) async {
    final encoder = ZipEncoder();
    final archive = Archive();

    // Agregar la DB
    final dbBytes = await dbFile.readAsBytes();
    archive.addFile(ArchiveFile('kaku.db', dbBytes.length, dbBytes));

    // Agregar los recibos si existen
    final receiptsDir = Directory('$appDirPath/receipts');
    if (await receiptsDir.exists()) {
      await for (final entity in receiptsDir.list()) {
        if (entity is File) {
          final fileBytes = await entity.readAsBytes();
          final fileName = entity.path.split('/').last;
          archive.addFile(
            ArchiveFile('receipts/$fileName', fileBytes.length, fileBytes),
          );
        }
      }
    }

    return Uint8List.fromList(encoder.encode(archive));
  }

  // Restaura los archivos del ZIP al directorio de la app
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

  // ── Cifrado AES-256-CBC ───────────────────────────────
  // La clave se deriva del email del usuario con SHA-256.
  // Así el backup solo puede descifrarse con la misma cuenta.
  // El IV es aleatorio en cada backup para mayor seguridad.
  static Uint8List _encrypt({required Uint8List data, required String email}) {
    final key = enc.Key(
      Uint8List.fromList(
        sha256.convert(utf8.encode(email)).bytes, // 32 bytes = AES-256
      ),
    );
    final iv = enc.IV.fromSecureRandom(16); // IV aleatorio
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encryptBytes(data, iv: iv);

    // Prepend del IV al ciphertext para poder usarlo al descifrar
    // Formato: [16 bytes IV][resto = ciphertext]
    final result = Uint8List(16 + encrypted.bytes.length);
    result.setAll(0, iv.bytes);
    result.setAll(16, encrypted.bytes);
    return result;
  }

  static Uint8List _decrypt({required Uint8List data, required String email}) {
    final key = enc.Key(
      Uint8List.fromList(sha256.convert(utf8.encode(email)).bytes),
    );
    // Extraer IV de los primeros 16 bytes
    final iv = enc.IV(Uint8List.sublistView(data, 0, 16));
    final ciphertext = enc.Encrypted(Uint8List.sublistView(data, 16));
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    return Uint8List.fromList(encrypter.decryptBytes(ciphertext, iv: iv));
  }

  static Future<String> _getOrCreateFolder(drive.DriveApi api) async {
    final list = await api.files.list(
      q:
          "name='Kaku Backup' "
          "and mimeType='application/vnd.google-apps.folder' "
          "and trashed=false",
      spaces: 'drive',
    );
    if (list.files != null && list.files!.isNotEmpty) {
      return list.files!.first.id!;
    }
    final folder = await api.files.create(
      drive.File()
        ..name = 'Kaku Backup'
        ..mimeType = 'application/vnd.google-apps.folder',
    );
    return folder.id!;
  }

  static Future<String?> _findExistingBackup(
    drive.DriveApi api,
    String folderId,
  ) async {
    final list = await api.files.list(
      q:
          "name='$_backupFileName' "
          "and '$folderId' in parents "
          "and trashed=false",
      spaces: 'drive',
    );
    return list.files?.firstOrNull?.id;
  }
}

enum BackupResult { success, notSignedIn, dbNotFound, error }

enum RestoreResult { success, notSignedIn, noBackupFound, error }

class _AuthClient extends http.BaseClient {
  final String _token;
  final _inner = http.Client();
  _AuthClient(this._token);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_token';
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
