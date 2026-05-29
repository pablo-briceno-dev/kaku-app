abstract class AppRoutes {
  // Tabs principales (dentro del ShellRoute)
  static const String dashboard = '/';
  static const String stats = '/stats';
  static const String goals = '/goals';
  static const String accounts = '/accounts';
  static const String settings = '/settings';

  static const String transactions = '/transactions';

  // Sub-rutas de detalle (también dentro del ShellRoutes)
  static const String transactionDetail = '/transaction/:id';
  static const String categoryDetail = '/category/:id';
  static const String accountDetail = '/accounts/:id';

  // Categorías
  static const String categories = '/categories';

  // Pantallas completas (fuera del ShellRoutes -> sin bottom nav)
  static const String addTransaction = '/add-transaction';

  // Helpers para construir rutas con parámetros ---
  // Uso: context.go(AppRoutes.toTransaction(42))
  static String toTransaction(int id) =>
      transactionDetail.replaceAll(':id', id.toString());
  static String toCategory(int id, int month, int year) =>
      '${categoryDetail.replaceAll(':id', id.toString())}?month=$month&year=$year';
  static String toAccountDetail(int id) =>
      accountDetail.replaceAll(':id', id.toString());
  static String toAddTransaction({int? accountId}) => accountId != null
      ? '$addTransaction?accountId=$accountId'
      : addTransaction;

  // Lista de tabs del bottom nav (mismo orden que los BottomNavigationBarItems)
  static const List<String> shellTabs = [dashboard, stats, goals, accounts];
}
