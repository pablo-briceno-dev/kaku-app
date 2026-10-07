import 'package:kaku/core/errors/app_error_code.dart';

class AppException implements Exception {
  final AppErrorCode code;
  final Object? details; // opcional, para debug/logs

  const AppException(this.code, [this.details]);
}
