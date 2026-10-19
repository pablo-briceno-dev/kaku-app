import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/features/personal/calendar/widgets/limit_dialog.dart';
import 'package:kaku/features/personal/calendar/widgets/stat.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/premium_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/services/premium_service.dart';
import 'package:kaku/shared/widgets/premium_gate.dart';

class MonthLimitCard extends ConsumerWidget {
  final int year, month;
  final double spent; // gastos reales del mes
  final double planned; // gastos programados pendientes del mes

  const MonthLimitCard({
    super.key,
    required this.year,
    required this.month,
    required this.spent,
    required this.planned,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final currency = ref.watch(currencyProvider);
    String money(double v) => CurrencyFormatter.format(v, currency);

    if (!ref.watch(isPremiumProvider)) {
      return PremiumGate(
        feature: PremiumFeature.blockedCalendarLimit,
        showLockBadge: true,
        child: Card(
          child: ListTile(
            leading: Icon(Icons.lock_outline_rounded, color: cs.primary),
            title: Text(l10n.calendarLimitLocked),
          ),
        ),
      );
    }

    final limit =
        ref
            .watch(monthLimitProvider((month: month, year: year)))
            .value
            ?.amount ??
        0;

    if (limit <= 0) {
      return Card(
        child: ListTile(
          leading: Icon(Icons.savings_outlined, color: cs.primary),
          title: Text(l10n.calendarLimitEmpty),
          trailing: FilledButton.tonal(
            onPressed: () => _edit(context, ref, limit),
            child: Text(l10n.calendarLimitSet),
          ),
        ),
      );
    }

    final now = DateTime.now();
    final isCurrent = now.year == year && now.month == month;
    final isFuture = DateTime(
      year,
      month,
    ).isAfter(DateTime(now.year, now.month));
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final daysLeft = isCurrent
        ? daysInMonth - now.day + 1
        : (isFuture ? daysInMonth : 0);

    final available = limit - spent - planned;
    final daily = (daysLeft > 0 && available > 0) ? available / daysLeft : 0.0;
    final used = ((spent + planned) / limit).clamp(0.0, 1.0).toDouble();
    final over = available < 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n.calendarLimitTitle} · ${money(limit)}',
                    style: ts.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: l10n.btnEdit,
                  onPressed: () => _edit(context, ref, limit),
                ),
              ],
            ),
            LinearProgressIndicator(
              value: used,
              color: over ? cs.error : cs.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Stat(label: l10n.calendarLimitSpent, value: money(spent)),
                Stat(label: l10n.calendarLimitPlanned, value: money(planned)),
                Stat(
                  label: l10n.calendarLimitAvailable,
                  value: money(available),
                  error: over,
                ),
              ],
            ),
            if (over || daysLeft > 0) ...[
              const SizedBox(height: 12),
              Text(
                over
                    ? l10n.calendarLimitExceeded(money(-available))
                    : l10n.calendarLimitDaily(money(daily)),
                style: ts.bodyMedium?.copyWith(
                  color: over ? cs.error : cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    double current,
  ) async {
    final blocked = await PremiumLimitChecker.blockIfFree(
      context: context,
      feature: PremiumFeature.blockedCalendarLimit,
    );
    if (blocked || !context.mounted) return;
    final dao = ref.read(calendarDaoProvider);
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => LimitDialog(current: current),
    );
    if (amount != null) await dao.setLimit(year, month, amount);
  }
}
