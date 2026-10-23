abstract class AppRoutes {
  static const String root = '/lock';

  // Tabs principales (dentro del ShellRoute)
  static const String dashboard = '/';
  static const String stats = '/stats';
  static const String personal = '/personal';
  static const String goals = '/goals';
  static const String accounts = '/accounts';
  static const String settings = '/settings';

  static const String transactions = '/transactions';

  static const String budgets = '/budgets';

  // Sub-rutas de detalle (también dentro del ShellRoutes)
  static const String transactionDetail = '/transaction/:id';
  static const String categoryDetail = '/category/:id';
  static const String accountDetail = '/accounts/:id';

  // Categorías
  static const String categories = '/categories';

  // Pantallas completas (fuera del ShellRoutes -> sin bottom nav)
  static const String addTransaction = '/add-transaction';

  // Premium
  static const String premium = '/premium';

  // Helpers para construir rutas con parámetros ---
  // Uso: context.go(AppRoutes.toTransaction(42))
  static String toTransaction(int id) =>
      transactionDetail.replaceAll(':id', id.toString());
  static String toCategory(int id, int month, int year) =>
      '${categoryDetail.replaceAll(':id', id.toString())}?month=$month&year=$year';
  static String toAccountDetail(int id) =>
      accountDetail.replaceAll(':id', id.toString());
  static String toAddTransaction({int? accountId, int? entryId}) {
    final params = <String, String>{
      if (accountId != null) 'accountId': accountId.toString(),
      if (entryId != null) 'entryId': entryId.toString(),
    };
    return params.isEmpty
        ? addTransaction
        : Uri(path: addTransaction, queryParameters: params).toString();
  }

  static String toPersonal({
    String? initialTab,
    DateTime? date,
    String? focusToken,
  }) {
    final params = <String, String>{
      'tab': ?initialTab,
      if (date != null) 'date': date.toIso8601String(),
      'n': ?focusToken,
    };
    return params.isEmpty
        ? personal
        : Uri(path: personal, queryParameters: params).toString();
  }

  // Lista de tabs del bottom nav (mismo orden que los BottomNavigationBarItems)
  static const List<String> shellTabs = [dashboard, stats, personal, accounts];
}
