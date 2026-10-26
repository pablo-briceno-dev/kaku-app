import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/features/personal/calendar/calendar_view.dart';
import 'package:kaku/features/personal/goals/goals_view.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class PersonalScreen extends ConsumerStatefulWidget {
  final int initialTab;
  final DateTime? initialDay;
  final String? focusToken;

  const PersonalScreen({
    super.key,
    this.initialTab = 0,
    this.initialDay,
    this.focusToken,
  });

  @override
  ConsumerState<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends ConsumerState<PersonalScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: 2,
    vsync: this,
    initialIndex: widget.initialTab,
  );

  @override
  void didUpdateWidget(PersonalScreen old) {
    super.didUpdateWidget(old);
    if (widget.focusToken != old.focusToken) {
      final target = widget.initialTab;
      // fuera del build: animar la pestaña durante la actualización da error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _tabs.index != target) _tabs.animateTo(target);
      });
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final activeGoalsAsync = ref.watch(activeGoalsProvider);
    final completedGoalsAsync = ref.watch(completedGoalsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(l10n.appShellTabPersonal),
        defaultActions: true,
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.calendar_month_outlined),
                      const SizedBox(width: 8),
                      Text(l10n.calendarTab),
                    ],
                  ),
                  Text(
                    l10n.calendarTabSubtitle,
                    maxLines: 2,
                    style: ts.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Tab(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.flag_outlined),
                      const SizedBox(width: 8),
                      Text(l10n.goalsTitle),
                    ],
                  ),
                  Row(
                    children: [
                      activeGoalsAsync.when(
                        data: (activeGoal) => Text(
                          l10n.goalsActive(activeGoal.length),
                          style: ts.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        error: (e, _) => Text(
                          l10n.goalsActive(0),
                          style: ts.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        loading: () => Text(
                          l10n.loading,
                          style: ts.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      completedGoalsAsync.when(
                        data: (completedGoal) => Text(
                          l10n.goalComplete(completedGoal.length),
                          style: ts.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        error: (e, _) => Text(
                          l10n.goalComplete(0),
                          style: ts.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        loading: () => Text(
                          l10n.loading,
                          style: ts.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          CalendarView(
            initialDay: widget.initialDay,
            focusToken: widget.focusToken,
          ),
          const GoalsView(),
        ],
      ),
    );
  }
}
