import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/helpers/app_snackbar.dart';
import 'package:kaku/features/goals/selected_account_goal.dart';
import 'package:kaku/features/goals/widgets/amounts_list.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/goal_confetti.dart';

class ContributeGoalSheet extends ConsumerStatefulWidget {
  final int goalId;
  final double targetAmount;
  final double savedAmount;
  final String emoji;
  final String name;

  const ContributeGoalSheet({
    super.key,
    required this.goalId,
    required this.targetAmount,
    required this.savedAmount,
    required this.emoji,
    required this.name,
  });

  @override
  ConsumerState<ContributeGoalSheet> createState() =>
      _ContributeGoalSheetState();
}

class _ContributeGoalSheetState extends ConsumerState<ContributeGoalSheet> {
  TextEditingController _amountController = TextEditingController();
  int _selectedAmount = 1;

  @override
  void initState() {
    super.initState();
    _amountController.text = CurrencyFormatter.format(
      100000,
      ref.read(currencyProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currency = ref.watch(currencyProvider);
    final listAmounts = [
      (CurrencyFormatter.compact(50000, currency), 50000),
      (CurrencyFormatter.compact(100000, currency), 100000),
      (CurrencyFormatter.compact(200000, currency), 200000),
      (
        'Todo',
        BudgetCalculator.goalRemaining(widget.savedAmount, widget.targetAmount),
      ),
    ];
    final selectedAccount = ref.watch(selectedAccountProvider);
    final account = ref.watch(accountByIdProvider(selectedAccount ?? 0)).value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Quedan ${CurrencyFormatter.format(BudgetCalculator.goalRemaining(widget.savedAmount, widget.targetAmount), currency)} para completar',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant.withAlpha(90),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Monto a aportar hoy'.toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyFormatter.inputFormatter(currency)],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo requerido';
              }
              if (CurrencyFormatter.parse(value) <= 0) {
                return 'Debe ser mayor a 0';
              }
              if (CurrencyFormatter.parse(value) >
                  widget.targetAmount - widget.savedAmount) {
                return 'No puedes aportar más que el total';
              }
              if (CurrencyFormatter.parse(value) > (account?.balance ?? 0)) {
                return 'Cuenta sin saldo suficiente';
              }
              return null;
            },
            style: TextStyle(fontSize: 50, color: cs.primary),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: r'$0'),
          ),
          const SizedBox(height: 16),
          AmountsList(
            amounts: listAmounts,
            onAmountSelected: (index) {
              final (_, amount) = listAmounts[index];
              _amountController.text = CurrencyFormatter.format(
                double.parse(amount.toStringAsFixed(0)),
                currency,
              );
              setState(() => _selectedAmount = index);
            },
            selectedAmount: _selectedAmount,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: cs.surfaceContainerHighest.withAlpha(60),
              border: Border.all(color: cs.surfaceContainerHighest, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Nuevo progreso',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.percentage(
                        ((widget.savedAmount +
                                    listAmounts[_selectedAmount].$2) /
                                widget.targetAmount) *
                            100,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: BudgetCalculator.goalProgress(
                    widget.savedAmount + listAmounts[_selectedAmount].$2,
                    widget.targetAmount,
                  ),
                  backgroundColor: cs.surfaceContainerHighest.withAlpha(60),
                  valueColor: AlwaysStoppedAnimation(cs.primary),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SelectedAccountGoal(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  selectedAccount == null ||
                      CurrencyFormatter.parse(_amountController.text) >
                          (account?.balance ?? 0)
                  ? null
                  : () async {
                      final newSaved =
                          widget.savedAmount +
                          CurrencyFormatter.parse(_amountController.text);
                      final completed = newSaved >= widget.targetAmount;

                      // 1. Guarda en la DB
                      await ref
                          .read(goalsDaoProvider)
                          .contribute(
                            goalId: widget.goalId,
                            accountId: selectedAccount,
                            amount: CurrencyFormatter.parse(
                              _amountController.text,
                            ),
                            balance: account?.balance ?? 0,
                          );

                      if (!mounted) return;

                      // 3. Si completó la meta → confeti sobre toda la pantalla
                      if (context.mounted) {
                        if (completed) {
                          GoalConfettiOverlay.show(context);
                        } else {
                          AppSnackbar.success(context, 'Aporte realizado');
                        }
                        Navigator.pop(context);
                      }
                    },
              child: const Text('Confirmar aporte'),
            ),
          ),
        ],
      ),
    );
  }
}
