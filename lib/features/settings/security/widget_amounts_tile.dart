import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/features/settings/widgets/switch_list_tile_child.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/services/calendar_widget_sync.dart';

class WidgetAmountsTile extends ConsumerStatefulWidget {
  const WidgetAmountsTile({super.key});

  @override
  ConsumerState<WidgetAmountsTile> createState() => _WidgetAmountsTileState();
}

class _WidgetAmountsTileState extends ConsumerState<WidgetAmountsTile> {
  bool _value = false;

  @override
  void initState() {
    super.initState();
    WidgetPrefs.showAmounts().then((v) {
      if (mounted) setState(() => _value = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTileChild(
      label: l10n.widgetShowAmountsTitle,
      subtitle: l10n.widgetShowAmountsSubtitle,
      icon: Icons.monetization_on,
      value: _value,
      onChanged: (v) async {
        setState(() => _value = v);
        await WidgetPrefs.setShowAmounts(v);
        await ref.read(calendarWidgetSyncProvider).push();
      },
    );
  }
}
