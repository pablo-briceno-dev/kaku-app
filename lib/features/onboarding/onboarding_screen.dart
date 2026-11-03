import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/models/account_type.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/features/onboarding/steps/account_step.dart';
import 'package:kaku/features/onboarding/steps/currency_step.dart';
import 'package:kaku/features/onboarding/steps/welcome_step.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/onboarding_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:drift/drift.dart' as drift;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  int _currentPage = 0;

  CurrencyType _currency = CurrencyType.usd;

  final _accountControllers = <String, TextEditingController>{
    'name': TextEditingController(),
    'type': TextEditingController(),
    'currency': TextEditingController(),
    'balance': TextEditingController(),
    'colorHex': TextEditingController(),
    'icon': TextEditingController(),
  };

  static const _totalPages = 3;

  @override
  void initState() {
    super.initState();
    _accountControllers['type']?.text = '1';
    _accountControllers['currency']?.text = ref.read(currencyProvider).label;
    _accountControllers['icon']?.text = AccountType.values[1].icon;
    _accountControllers['colorHex']?.text = '#7cffd4';

    _accountControllers['name']?.addListener(_refresh);
    _accountControllers['balance']?.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _accountControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _previous() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _next() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _complete() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      HapticFeedback.mediumImpact();
      return;
    }

    ref.read(currencyProvider.notifier).setCurrency(_currency);

    await ref
        .read(accountsDaoProvider)
        .insertAccount(
          AccountsTableCompanion.insert(
            name: _accountControllers['name']!.text,
            type: drift.Value(
              int.tryParse(_accountControllers['type']!.text) ?? 0,
            ),
            currency: drift.Value(_accountControllers['currency']!.text),
            balance: drift.Value(
              CurrencyFormatter.parse(
                _accountControllers['balance']!.text,
                CurrencyType.values.firstWhere(
                  (e) => e.label == _accountControllers['currency']!.text,
                ),
              ),
            ),
            colorHex: drift.Value(_accountControllers['colorHex']!.text),
            icon: drift.Value(_accountControllers['icon']!.text),
          ),
        );

    ref.read(appRefreshCounterProvider.notifier).state++;

    await ref.read(onboardingProvider.notifier).complete();

    if (mounted) context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isFirstPage = _currentPage == 0;
    final isLastPage = _currentPage == _totalPages - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / _totalPages, // 🆕
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  if (!isLastPage)
                    TextButton(
                      onPressed: () => _pageController.animateToPage(
                        _totalPages - 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      ),
                      child: Text(l10n.onboardingSkip),
                    )
                  else
                    const SizedBox(width: 8),
                ],
              ),
            ),

             Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  const WelcomeStep(), // 🆕 Paso 0
                  CurrencyStep(
                    selected: _currency,
                    onChanged: (c) => setState(() => _currency = c),
                  ),
                  AccountStep(
                    formKey: _formKey,
                    controllers: _accountControllers,
                  ),
                ],
              ),
            ),

            // ── Botones ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Row(
                children: [
                  if (!isFirstPage)
                    TextButton.icon(
                      onPressed: _previous,
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: Text(l10n.onboardingBack),
                    )
                  else
                    const SizedBox(width: 88),
                  const Spacer(),
                  FilledButton(
                    onPressed: isLastPage ? _complete : _next,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(120, 48),
                    ),
                    child: Text(
                      isLastPage
                          ? l10n.onboardingStart
                          : l10n.onboardingContinue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
