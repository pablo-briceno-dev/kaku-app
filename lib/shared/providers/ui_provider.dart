import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/core/date_formatter.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/core/models/transaction_type.dart';
import 'package:kaku/core/models/transaction_type_filter.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/theme_provider.dart';
import 'package:kaku/shared/services/storage_service.dart';
import 'package:riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final selectedMonthProvider = StateProvider<({int month, int year})>((ref) {
  final now = DateTime.now();
  return (month: now.month, year: now.year);
});

// Extensión de conveniencia para cambiar el mes
extension SelectedMonthExtension on StateController<({int month, int year})> {
  void toPrevious() {
    final prev = BudgetCalculator.previousMonth(state.year, state.month);
    state = (month: prev.month, year: prev.year);
  }

  void toNext() {
    final next = BudgetCalculator.nextMonth(state.year, state.month);
    state = (month: next.month, year: next.year);
  }

  bool isCurrentMonth() =>
      BudgetCalculator.isCurrentMonth(state.year, state.month);
}

// Controla si StatsScreen muestra datos del mes, trimestre o año completo
enum StatsPeriod { month, quarter, year }

final statsPeriodProvider = StateProvider<StatsPeriod>(
  (ref) => StatsPeriod.month,
);

//  Qué hace: la moneda seleccionada por el usuario en Ajustes.
//  Se persiste en SharedPreferences porque debe sobrevivir
//  al cerrar la app (a diferencia del mes seleccionado).
const String _kCurrency = 'selected_currency';

class CurrencyNotifier extends StateNotifier<CurrencyType> {
  final SharedPreferences _prefs;

  CurrencyNotifier(this._prefs)
    : super(
        CurrencyType.values.firstWhere(
          (e) => e.label == (_prefs.getString(_kCurrency) ?? 'COP'),
        ),
      );

  Future<void> setCurrency(CurrencyType currency) async {
    state = currency;
    await _prefs.setString(_kCurrency, currency.label);
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, CurrencyType>(
  (ref) => CurrencyNotifier(ref.watch(sharedPrefsProvider)),
);

//  Qué hace: el toggle Gasto / Ingreso en AddTransactionScreen.
//  Solo vive mientras la pantalla está abierta.
final addTransactionTypeProvider = StateProvider.autoDispose<TransactionType>(
  (_) => TransactionType.expense,
);

//  Qué hace: la cuenta seleccionada en el formulario de
//  AddTransactionScreen. También autoDispose.
final selectedAccountProvider = StateProvider.autoDispose<int?>((_) => null);

//  Qué hace: la categoría seleccionada en AddTransactionScreen.
final selectedCategoryProvider = StateProvider.autoDispose<int?>((_) => null);

// Qué hace: maneja el filtro de tipo de transacción en TransactionsScreen.
final transactionTypeFilterProvider =
    StateProvider.autoDispose<TransactionTypeFilter>(
      (_) => TransactionTypeFilter.all,
    );

// Backup - Info
const _kLastBackupKey = 'last_backup_date';

// Llama esto en BackupService.backup() cuando result == success:
//   await saveLastBackupDate();
Future<void> saveLastBackupDate() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kLastBackupKey, DateTime.now().toIso8601String());
}

// Señal para el backup — se incrementa tras cada backup exitoso
final backupRefreshSignalProvider = StateProvider<int>((ref) => 0);

// Señal para el almacenamiento — se incrementa al adjuntar/borrar recibos
final storageRefreshSignalProvider = StateProvider<int>((ref) => 0);

final lastBackupSubtitleProvider = FutureProvider.autoDispose<String>((
  ref,
) async {
  // Observar la señal — cuando cambie este provider se recalcula
  ref.watch(backupRefreshSignalProvider);

  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('last_backup_date');
  if (raw == null) return 'Sin sincronizar';

  final date = DateTime.tryParse(raw);
  if (date == null) return 'Sin sincronizar';

  return 'Última sync: ${DateFormatter.relative(date)}';
});

// ════════════════════════════════════════════════════════
//  storageSubtitleProvider — reactivo
//
//  Se recalcula cuando storageRefreshSignalProvider cambia.
//  También observa las transacciones para detectar cuando
//  se adjunta o elimina una foto de recibo.
// ════════════════════════════════════════════════════════
final storageSubtitleProvider = FutureProvider.autoDispose<String>((ref) async {
  // Señal manual (al limpiar recibos desde el sheet)
  ref.watch(storageRefreshSignalProvider);

  // También se recalcula cuando cambian las transacciones
  // porque adjuntar/eliminar una foto modifica el conteo
  ref.watch(activeAccountsProvider);

  final info = await StorageService.getInfo();
  if (info.count == 0) return 'Sin recibos guardados';
  return '${info.sizeLabel} · ${info.count} '
      '${info.count == 1 ? 'foto' : 'fotos'}';
});
