import 'package:flutter/material.dart';
import 'package:kaku/features/personal/calendar/calendar_view.dart';
import 'package:kaku/features/personal/goals/goals_view.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class PersonalScreen extends StatelessWidget {
  final int initialTab;

  const PersonalScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: CustomAppBar(
          title: Text(l10n.appShellTabPersonal),
          defaultActions: true,
          bottom: TabBar(
            tabs: [
              Tab(
                text: l10n.goalsTitle,
                // icon: Icon(Icons.flag_outlined)
              ),
              Tab(text: l10n.calendarTab),
            ],
          ),
        ),
        body: const TabBarView(children: [GoalsView(), CalendarView()]),
      ),
    );
  }
}
