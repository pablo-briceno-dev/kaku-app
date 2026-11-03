import 'package:flutter/material.dart';
import 'package:kaku/core/colors_plates.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/models/account_type.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/features/accounts/widgets/card_account_type.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/widgets/selected_color_picker.dart';

class AccountStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, TextEditingController> controllers;

  const AccountStep({
    super.key,
    required this.controllers,
    required this.formKey,
  });

  @override
  State<AccountStep> createState() => _AccountStepState();
}

class _AccountStepState extends State<AccountStep> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: widget.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text('🏦', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              l10n.onboardingAccountTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.onboardingAccountSubtitle,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: widget.controllers['name'],
              keyboardType: TextInputType.text,
              maxLength: 50,
              validator: (value) => value!.isEmpty ? l10n.formRequired : null,
              decoration: InputDecoration(labelText: '${l10n.formName}*'),
            ),
            const SizedBox(height: 16),
            Text(l10n.accountType, style: ts.titleMedium),
            const SizedBox(height: 4),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 130,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: AccountType.values.length,
              itemBuilder: (_, index) {
                final accountType = AccountType.values[index];
                final isSelected =
                    index.toString() == widget.controllers['type']?.text;
                return CardAccountType(
                  cardConfig: CardAccountTypeConfig(
                    icon: accountType.icon,
                    title: accountType.label(l10n),
                    color: hexToColor(
                      widget.controllers['colorHex']?.text ?? '#7cffd4',
                    ),
                  ),
                  isSelected: isSelected,
                  onTap: () => setState(() {
                    widget.controllers['type']?.text = index.toString();
                    widget.controllers['icon']?.text = accountType.icon;
                  }),
                );
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: widget.controllers['balance'],
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false, // ← no muestra el botón "-"
              ),
              inputFormatters: [
                CurrencyFormatter.inputFormatter(
                  CurrencyType.values.firstWhere(
                    (e) => e.label == widget.controllers['currency']?.text,
                  ),
                ),
              ],
              decoration: InputDecoration(
                labelText: '${l10n.formBalanceInitial}*',
                hintText: r'$0',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.accountBalanceMessage,
              style: ts.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<CurrencyType>(
                    initialValue: CurrencyType.values.firstWhere(
                      (e) => e.label == widget.controllers['currency']?.text,
                    ),
                    items: CurrencyType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(
                        () =>
                            widget.controllers['currency']?.text = value!.label,
                      );
                    },
                    decoration: InputDecoration(
                      labelText: l10n.currencySelect,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Text(l10n.formColor, style: ts.titleMedium),
                      const SizedBox(width: 20),
                      SelectedColorPicker(
                        onColorSelected: (color) => setState(
                          () => widget.controllers['colorHex']?.text =
                              colorToHex(color),
                        ),
                        initialColor: hexToColor(
                          widget.controllers['colorHex']?.text ?? '#7cffd4',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
