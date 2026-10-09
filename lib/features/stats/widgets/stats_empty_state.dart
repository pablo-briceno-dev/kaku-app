import 'package:flutter/material.dart';
import 'package:kaku/l10n/app_localizations.dart';

class StatsEmptyState extends StatelessWidget {
  final String? message;

  const StatsEmptyState({
    this.message,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🫙', style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            message ?? AppLocalizations.of(context)!.statsEmptyThisMonth,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.3),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
