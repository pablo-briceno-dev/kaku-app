import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/shared/providers/theme_provider.dart';
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
final addTransactionTypeProvider = StateProvider.autoDispose<String>(
  (_) => 'expense',
);

//  Qué hace: la cuenta seleccionada en el formulario de
//  AddTransactionScreen. También autoDispose.
final selectedAccountProvider = StateProvider.autoDispose<int?>((_) => null);

//  Qué hace: la categoría seleccionada en AddTransactionScreen.
final selectedCategoryProvider = StateProvider.autoDispose<int?>((_) => null);
