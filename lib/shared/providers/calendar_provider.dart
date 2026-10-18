import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/models/entry_status.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/services/premium_service.dart';
import 'package:kaku/shared/services/reminder_service.dart';

const kFreeMaxReminders = PremiumLimits.maxCalendarReminders;

final reminderServiceProvider = Provider<ReminderService>(
  (ref) => ReminderService(FlutterLocalNotificationsPlugin()),
);

Future<bool> canUseReminder(WidgetRef ref, {int? excludeId}) async {
  final premium = await PremiumService.isPremium();
  if (premium) return true;
  final active = await ref
      .read(calendarDaoProvider)
      .countActiveReminders(excludeId: excludeId);
  return active < kFreeMaxReminders;
}

/// Lo llama AddTransactionScreen al guardar el gasto que viene de una entrada
Future<void> completeEntry(
  WidgetRef ref,
  int entryId,
  int transactionId,
) async {
  await ref
      .read(calendarDaoProvider)
      .setStatus(entryId, EntryStatus.done, transactionId: transactionId);
  await ref.read(reminderServiceProvider).cancel(entryId);
}
