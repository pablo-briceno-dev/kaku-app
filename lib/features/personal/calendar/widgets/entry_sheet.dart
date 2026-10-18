import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/l10n/category_l10n.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/core/recurrence.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/calendar_provider.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/locale_provider.dart';
import 'package:kaku/shared/providers/premium_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/services/premium_service.dart';
import 'package:kaku/shared/widgets/premium_gate.dart';
import 'package:permission_handler/permission_handler.dart';

class EntrySheet extends ConsumerStatefulWidget {
  final DateTime date;
  final CalendarEntry? entry;

  const EntrySheet({super.key, required this.date, this.entry});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EntrySheetState();
}

class _EntrySheetState extends ConsumerState<EntrySheet> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(
    text: widget.entry?.title,
  );
  late final _amountController = TextEditingController(
    text: widget.entry?.amount.toString(),
  );
  late final DateTime _day = DateUtils.dateOnly(
    widget.entry?.date ?? widget.date,
  );

  int? _categoryId;
  int? _accountId;
  bool _remind = false;
  int _daysBefore = 0;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  Recurrence _recurrence = Recurrence.none;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    if (e == null) return;
    _categoryId = e.categoryId;
    _accountId = e.accountId;
    final r = e.remindAt;
    if (r != null) {
      _remind = true;
      _time = TimeOfDay.fromDateTime(r);
      _daysBefore = _day
          .difference(DateUtils.dateOnly(r))
          .inDays
          .clamp(0, 1)
          .toInt();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double? _parseAmount(CurrencyType currency) =>
      CurrencyFormatter.parse(_amountController.text, currency);

  DateTime _remindAt() => DateTime(
    _day.year,
    _day.month,
    _day.day - _daysBefore,
    _time.hour,
    _time.minute,
  );

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  Future<bool> _ensureNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) return true;
    if (!mounted) return false;
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.notifPermissionTitle),
        content: Text(l10n.notifPermissionSubtitle),
        actions: [
          TextButton(
            child: Text(l10n.btnCancel),
            onPressed: () => Navigator.pop(ctx),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: Text(l10n.btnOpenSettings),
          ),
        ],
      ),
    );
    return false;
  }

  Future<void> _syncReminder(CalendarEntry e) async {
    await ref
        .read(reminderServiceProvider)
        .schedule(
          entry: e,
          l10n: AppLocalizations.of(context)!,
          locale: Localizations.localeOf(context).languageCode,
          currency: ref.read(currencyProvider),
        );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final dao = ref.read(calendarDaoProvider);
    final old = widget.entry;
    final remindAt = _remind ? _remindAt() : null;

    if (remindAt != null) {
      if (!remindAt.isAfter(DateTime.now())) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.calendarReminderInPast)),
        );
        return;
      }
      if (!await _ensureNotificationPermission()) return;
      if (!await canUseReminder(ref, excludeId: old?.id)) {
        if (mounted) {
          await PremiumLimitChecker.check(
            context: context,
            feature: PremiumFeature.unlimitedGoals,
            currentCount: 3,
            limit: PremiumLimits.maxGoals,
          );
        }
        return;
      }
    }
    final amount = _parseAmount(ref.read(currencyProvider));
    if (old == null && _recurrence != Recurrence.none) {
      final until = DateTime(_day.year, _day.month + 12, _day.day);
      await dao.insertSeries([
        for (final d in recurrenceDates(_day, _recurrence, until))
          CalendarEntriesTableCompanion.insert(
            date: d,
            title: _titleController.text.trim(),
            amount: drift.Value(amount),
            categoryId: drift.Value(_categoryId),
            accountId: drift.Value(_accountId),
            remindAt: drift.Value(shiftReminder(d, remindAt, d)),
            recurrence: drift.Value(_recurrence.name),
          ),
      ]);
      if (mounted) {
        await ref
            .read(calendarControllerProvider)
            .rescheduleAll(ref.read(localeProvider));
      }
      if (mounted) nav.pop();
      return;
    }
    final int id;
    if (old == null) {
      id = await dao.insertEntry(
        CalendarEntriesTableCompanion.insert(
          date: _day,
          title: _titleController.text.trim(),
          amount: drift.Value(amount),
          categoryId: drift.Value(_categoryId),
          accountId: drift.Value(_accountId),
          remindAt: drift.Value(remindAt),
        ),
      );
    } else {
      id = old.id;
      await dao.updateEntry(
        old.copyWith(
          title: _titleController.text.trim(),
          amount: drift.Value(amount),
          categoryId: drift.Value(_categoryId),
          accountId: drift.Value(_accountId),
          remindAt: drift.Value(remindAt),
        ),
      );
    }
    final saved = await dao.getById(id);
    if (saved != null && mounted) await _syncReminder(saved);
    if (mounted) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider);
    final ml = MaterialLocalizations.of(context);
    final categories =
        ref.watch(expenseCategoriesProvider).value ?? const <Category>[];
    final accounts =
        ref.watch(activeAccountsProvider).value ?? const <Account>[];
    final isPremium = ref.watch(isPremiumProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.calendarEntryTitleLabel,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.formRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              inputFormatters: [CurrencyFormatter.inputFormatter(currency)],
              decoration: InputDecoration(
                labelText: l10n.calendarEntryAmountLabel,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final n = _parseAmount(currency);
                return (n == null || n <= 0) ? l10n.formAmountMajor : null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              // la key fuerza a reconstruir cuando termina de cargar la lista
              key: ValueKey('cat-${categories.length}'),
              initialValue: categories.any((c) => c.id == _categoryId)
                  ? _categoryId
                  : null,
              decoration: InputDecoration(
                labelText: l10n.calendarEntryCategoryLabel,
              ),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('—')),
                for (final c in categories)
                  DropdownMenuItem<int?>(
                    value: c.id,
                    child: Text(c.displayName(context)),
                  ),
              ],
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              key: ValueKey('acc-${accounts.length}'),
              initialValue: accounts.any((a) => a.id == _accountId)
                  ? _accountId
                  : null,
              decoration: InputDecoration(
                labelText: l10n.calendarEntryAccountLabel,
              ),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('—')),
                for (final a in accounts)
                  DropdownMenuItem<int?>(value: a.id, child: Text(a.name)),
              ],
              onChanged: (v) => setState(() => _accountId = v),
            ),
            if (widget.entry == null) ...[
              const SizedBox(height: 12),
              Text(
                l10n.calendarRepeatLabel,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              SegmentedButton<Recurrence>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: Recurrence.none,
                    label: Text(l10n.calendarRepeatNone),
                  ),
                  ButtonSegment(
                    value: Recurrence.weekly,
                    label: Text(l10n.calendarRepeatWeekly),
                  ),
                  ButtonSegment(
                    value: Recurrence.monthly,
                    label: Text(l10n.calendarRepeatMonthly),
                  ),
                ],
                selected: {_recurrence},
                onSelectionChanged: (s) async {
                  final v = s.first;
                  if (v != Recurrence.none && !ref.read(isPremiumProvider)) {
                    await PremiumLimitChecker.check(
                      context: context,
                      feature: PremiumFeature.blockedCalendarRecurring,
                      currentCount: 0,
                      limit: 0,
                    );
                    return;
                  }
                  setState(() => _recurrence = v);
                },
              ),
            ],
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.calendarReminderToggle),
              subtitle: isPremium
                  ? null
                  : Text(l10n.calendarReminderFreeHint(kFreeMaxReminders)),
              value: _remind,
              onChanged: (v) => setState(() => _remind = v),
            ),
            if (_remind) ...[
              SegmentedButton<int>(
                segments: [
                  ButtonSegment(
                    value: 0,
                    label: Text(l10n.calendarReminderSameDay),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text(l10n.calendarReminderDayBefore),
                  ),
                ],
                selected: {_daysBefore},
                onSelectionChanged: (s) =>
                    setState(() => _daysBefore = s.first),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.schedule, size: 18),
                label: Text(ml.formatTimeOfDay(_time)),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: Text(l10n.btnSave)),
          ],
        ),
      ),
    );
  }
}
