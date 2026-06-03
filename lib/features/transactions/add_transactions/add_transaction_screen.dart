import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/models/transaction_type.dart';
import 'package:kaku/features/transactions/add_transactions/add_transaction_form.dart';
import 'package:kaku/features/transactions/add_transactions/add_transaction_transfer_form.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

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
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_currentTab != _tabController.index) {
        setState(() {
          _currentTab = _tabController.index;
        });
        ref
            .read(addTransactionTypeProvider.notifier)
            .state = switch (_currentTab) {
          0 => TransactionType.expense,
          1 => TransactionType.income,
          2 => TransactionType.transfer,
          _ => TransactionType.expense,
        };
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preselectAccountIfOnlyOne();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _preselectAccountIfOnlyOne() async {
    final accounts = await ref.read(accountsDaoProvider).getActiveAccounts();
    if (accounts.length == 1 && mounted) {
      ref.read(selectedAccountProvider.notifier).state = accounts.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currentColor = switch (_currentTab) {
      0 => TransactionType.expense.color,
      1 => TransactionType.income.color,
      2 => TransactionType.transfer.color,
      _ => Colors.transparent,
    };

    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Nueva transacción'),
        defaultActions: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: currentColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: cs.onSurfaceVariant,
                tabs: const [
                  Tab(text: 'Gasto'),
                  Tab(text: 'Ingreso'),
                  Tab(text: 'Transferencia'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AddTransactionForm(),
          AddTransactionForm(),
          AddTransactionTransferForm(),
        ],
      ),
    );
  }
}
