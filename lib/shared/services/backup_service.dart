import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:path_provider/path_provider.dart';

class BackupService {
  static final _signIn = GoogleSignIn.instance;

  // Scopes necesarios para Drive
  static const _driveScopes = [drive.DriveApi.driveFileScope];

  // ── Inicializar (llama una vez al arrancar la app) ───────
  // En main.dart o en un provider de inicialización:
  //   await BackupService.initialize();
  static Future<void> initialize() async {
    await _signIn.initialize(
      serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
    );
    // Escucha eventos de autenticación
    _signIn.authenticationEvents
        .listen(_onAuthEvent)
        .onError((e) => debugPrint('Auth error: $e'));
    _signIn.attemptLightweightAuthentication();
  }

  static GoogleSignInAccount? _currentUser;
  static void _onAuthEvent(GoogleSignInAuthenticationEvent event) {
    _currentUser = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };
  }

  // ── Cuenta activa ────────────────────────────────────────
  static GoogleSignInAccount? get currentUser => _currentUser;
  static bool get isSignedIn => _currentUser != null;

  // ── Autenticar al usuario ────────────────────────────────
  // ✅ v7: authenticate() en lugar de signIn()
  static Future<bool> authenticate() async {
    try {
      if (!_signIn.supportsAuthenticate()) return false;
      await _signIn.authenticate();
      return _currentUser != null;
    } on GoogleSignInException catch (e) {
      debugPrint('BackupService.authenticate error: $e');
      return false;
    }
  }

  // ── Desconectar ──────────────────────────────────────────
  static Future<void> signOut() async {
    await _signIn.signOut();
    _currentUser = null;
  }

  // ── Realizar backup ──────────────────────────────────────
  static Future<BackupResult> backup(AppDatabase db) async {
    try {
      // 1. Verificar que hay usuario autenticado
      if (_currentUser == null) return BackupResult.notSignedIn;

      // 2. Solicitar autorización para Drive
      // ✅ v7: la autorización es separada del sign in
      final GoogleSignInClientAuthorization? authorization =
          await _currentUser!.authorizationClient.authorizationForScopes(
            _driveScopes,
          ) ??
          await _currentUser!.authorizationClient.authorizeScopes(_driveScopes);

      if (authorization == null) return BackupResult.notSignedIn;

      // 3. Cliente HTTP autenticado con el access token
      final client = _AuthClient(authorization.accessToken);
      final driveApi = drive.DriveApi(client);

      // 4. Ruta del archivo .db
      final dbDir = await getApplicationDocumentsDirectory();
      final dbFile = File('${dbDir.path}/kaku.db');
      if (!await dbFile.exists()) return BackupResult.dbNotFound;

      // 5. Buscar o crear la carpeta "Kaku Backup"
      final folderId = await _getOrCreateFolder(driveApi);

      // 6. Subir el archivo (actualiza si ya existe)
      final existing = await _findExistingBackup(driveApi, folderId);
      final media = drive.Media(
        dbFile.openRead(),
        await dbFile.length(),
        contentType: 'application/octet-stream',
      );

      if (existing != null) {
        await driveApi.files.update(
          drive.File()..name = 'kaku_backup.db',
          existing,
          uploadMedia: media,
        );
      } else {
        await driveApi.files.create(
          drive.File()
            ..name = 'kaku_backup.db'
            ..parents = [folderId],
          uploadMedia: media,
        );
      }

      client.close();
      await saveLastBackupDate();
      return BackupResult.success;
    } on GoogleSignInException catch (e) {
      debugPrint('BackupService.backup GoogleSignInException: $e');
      return BackupResult.notSignedIn;
    } catch (e) {
      debugPrint('BackupService.backup error: $e');
      return BackupResult.error;
    }
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
          "name='kaku_backup.db' "
          "and '$folderId' in parents "
          "and trashed=false",
      spaces: 'drive',
    );
    return list.files?.firstOrNull?.id;
  }
}

enum BackupResult { success, notSignedIn, dbNotFound, error }

// ── Cliente HTTP con el access token de Drive ────────────────
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
