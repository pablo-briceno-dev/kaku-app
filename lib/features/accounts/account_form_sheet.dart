import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/colors_plates.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/helpers/app_snackbar.dart';
import 'package:kaku/core/models/account_type.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/features/accounts/widgets/card_account_type.dart';
import 'package:kaku/features/accounts/widgets/selected_color_picker.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/preview_icon_for_widgets.dart';

class AccountFormSheet extends ConsumerStatefulWidget {
  final Account? account;

  const AccountFormSheet({super.key, this.account});

  @override
  ConsumerState<AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends ConsumerState<AccountFormSheet> {
  final controllers = <String, TextEditingController>{
    'name': TextEditingController(),
    'type': TextEditingController(),
    'currency': TextEditingController(),
    'balance': TextEditingController(),
    'colorHex': TextEditingController(),
    'icon': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      controllers['name']?.text = widget.account!.name;
      controllers['type']?.text = widget.account!.type.toString();
      controllers['currency']?.text = widget.account!.currency;
      controllers['icon']?.text = widget.account!.icon;
      controllers['colorHex']?.text = widget.account!.colorHex;
      controllers['balance']?.text = CurrencyFormatter.format(
        widget.account!.balance,
        CurrencyType.values.firstWhere(
          (e) => e.label == widget.account!.currency,
        ),
      );
    } else {
      controllers['name']?.text = 'Mi Cuenta';
      controllers['type']?.text = '1';
      controllers['currency']?.text = ref.read(currencyProvider).label;
      controllers['icon']?.text = AccountType.values[1].icon;
      controllers['colorHex']?.text = '#7cffd4';
    }

    controllers['name']?.addListener(_refresh);
    controllers['balance']?.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controllers['name']?.removeListener(_refresh);
    controllers['balance']?.removeListener(_refresh);

    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final accountType =
        AccountType.values[int.tryParse(controllers['type']?.text ?? '0') ?? 0];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview
          Center(
            child: PreviewIconForWidgets(
              color: hexToColor(controllers['colorHex']?.text ?? '#7cffd4'),
              icon: accountType.icon,
              label: controllers['name']?.text,
              subtitle:
                  '${accountType.label} · ${controllers['balance']?.text ?? ''}',
              size: 90,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 2),
          const SizedBox(height: 20),
          // Form
          TextFormField(
            controller: controllers['name'],
            keyboardType: TextInputType.text,
            maxLength: 50,
            validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
            decoration: const InputDecoration(labelText: 'Nombre*'),
          ),
          const SizedBox(height: 16),
          Text('Tipo de Cuenta', style: ts.titleMedium),
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
              final isSelected = index.toString() == controllers['type']?.text;
              return CardAccountType(
                cardConfig: CardAccountTypeConfig(
                  icon: accountType.icon,
                  title: accountType.label,
                  color: hexToColor(controllers['colorHex']?.text ?? '#7cffd4'),
                ),
                isSelected: isSelected,
                onTap: () => setState(() {
                  controllers['type']?.text = index.toString();
                  controllers['icon']?.text = accountType.icon;
                }),
              );
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: controllers['balance'],
            keyboardType: const TextInputType.numberWithOptions(
              decimal:
                  true, // ← muestra "." o "," según el idioma del dispositivo
              signed: false, // ← no muestra el botón "-"
            ),
            inputFormatters: [
              CurrencyFormatter.inputFormatter(
                CurrencyType.values.firstWhere(
                  (e) => e.label == controllers['currency']?.text,
                ),
              ),
            ],
            decoration: const InputDecoration(
              labelText: 'Saldo Inicial*',
              hintText: r'$0',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Este es el saldo actual de tu cuenta. Las transacciones futuras ajustarán este valor',
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
                    (e) => e.label == controllers['currency']?.text,
                  ),
                  items: CurrencyType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(
                      () => controllers['currency']?.text = value!.label,
                    );
                  },
                  decoration: const InputDecoration(
                    labelText: 'Moneda',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Text('Color', style: ts.titleMedium),
                    const SizedBox(width: 20),
                    SelectedColorPicker(
                      onColorSelected: (color) => setState(
                        () => controllers['colorHex']?.text = colorToHex(color),
                      ),
                      initialColor: hexToColor(
                        controllers['colorHex']?.text ?? '#7cffd4',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  controllers['name']?.text != null &&
                      controllers['name']!.text.isNotEmpty &&
                      controllers['balance']?.text != null &&
                      controllers['balance']!.text.isEmpty
                  ? null
                  : () async {
                      final dao = ref.read(accountsDaoProvider);
                      if (widget.account != null) {
                        await dao.updateAccount(
                          Account(
                            id: widget.account!.id,
                            name: controllers['name']!.text,
                            type: int.tryParse(controllers['type']!.text) ?? 0,
                            currency: controllers['currency']!.text,
                            balance: CurrencyFormatter.parse(
                              controllers['balance']!.text,
                              CurrencyType.values.firstWhere(
                                (e) => e.label == controllers['currency']!.text,
                              ),
                            ),
                            colorHex: controllers['colorHex']!.text,
                            icon: controllers['icon']!.text,
                            isActive: widget.account!.isActive,
                            createdAt: widget.account!.createdAt,
                          ),
                        );
                      } else {
                        await dao.insertAccount(
                          AccountsTableCompanion.insert(
                            name: controllers['name']!.text,
                            type: drift.Value(
                              int.tryParse(controllers['type']!.text) ?? 0,
                            ),
                            currency: drift.Value(
                              controllers['currency']!.text,
                            ),
                            balance: drift.Value(
                              CurrencyFormatter.parse(
                                controllers['balance']!.text,
                                CurrencyType.values.firstWhere(
                                  (e) =>
                                      e.label == controllers['currency']!.text,
                                ),
                              ),
                            ),
                            colorHex: drift.Value(
                              controllers['colorHex']!.text,
                            ),
                            icon: drift.Value(controllers['icon']!.text),
                          ),
                        );
                      }

                      if (context.mounted) {
                        AppSnackbar.success(
                          context,
                          widget.account != null
                              ? 'Cuenta actualizada'
                              : 'Cuenta creada',
                        );
                        Navigator.pop(context);
                      }
                    },
              child: widget.account != null
                  ? const Text('Actualizar')
                  : const Text('Crear Cuenta'),
            ),
          ),
        ],
      ),
    );
  }
}
