import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/helpers/app_snackbar.dart';
import 'package:kaku/core/models/transaction_type.dart';
import 'package:kaku/features/transactions/add_transaction_form.dart';
import 'package:kaku/features/transactions/horizontal_chips_categories.dart';
import 'package:kaku/features/transactions/selected_account.dart';
import 'package:kaku/features/transactions/widgets/toggle_app_bar.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/content_widget_empty.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';
import 'package:kaku/shared/widgets/date_picker_field.dart';
import 'package:kaku/shared/widgets/receipt_picker.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final int? accountId;

  const AddTransactionScreen({super.key, this.accountId});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Nueva transacción'),
        defaultActions: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Gasto'),
            Tab(text: 'Ingreso'),
            Tab(text: 'Transferencia'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AddTransactionForm(
            // type: TransactionType.expense,
            // onSaved: (_) => _tabController.animateTo(1),
          ),
          AddTransactionForm(
            // type: TransactionType.income,
            // onSaved: (_) => _tabController.animateTo(2),
          ),
          AddTransactionForm(
            // type: TransactionType.transfer,
            // onSaved: (_) => _tabController.animateTo(3),
          ),
        ],
      ),
    );
  }
}
