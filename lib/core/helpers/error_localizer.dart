import 'package:flutter/material.dart';
import 'package:kaku/core/errors/app_error_code.dart';
import 'package:kaku/l10n/app_localizations.dart';

String localizeError(
  BuildContext context,
  AppErrorCode code, {
  String? messageComplement,
}) {
  final l10n = AppLocalizations.of(context)!;
  return switch (code) {
    AppErrorCode.insufficientFunds => l10n.errorInsufficientFunds,
    AppErrorCode.accountNotFound => l10n.errorAccountNotFound,
    AppErrorCode.invalidAmount => l10n.errorInvalidAmount,
    AppErrorCode.networkError => l10n.errorNetworkError,
    AppErrorCode.messageNoReceipt => l10n.messageNoReceipt(
      source: messageComplement ?? '',
    ),
  };
}
