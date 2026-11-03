import 'package:flutter/material.dart';
import 'package:kaku/l10n/app_localizations.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32,),

          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Text('👛', style: TextStyle(fontSize: 64)),
            )
          ),
          const SizedBox(height: 28),

          // ── Título principal ──
          Text(
            l10n.welcomeTitle,
            textAlign: TextAlign.center,
            style: ts.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          // ── Subtítulo ──
          Text(
            l10n.welcomeSubtitle,
            textAlign: TextAlign.center,
            style: ts.titleMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),

          // ── Descripción ──
          Text(
            l10n.welcomeDescription,
            textAlign: TextAlign.center,
            style: ts.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // ── Features destacadas ──
          _FeatureItem(
            emoji: '💰',
            title: l10n.welcomeFeature1Title,
            description: l10n.welcomeFeature1Desc,
          ),
          const SizedBox(height: 14),
          _FeatureItem(
            emoji: '📊',
            title: l10n.welcomeFeature2Title,
            description: l10n.welcomeFeature2Desc,
          ),
          const SizedBox(height: 14),
          _FeatureItem(
            emoji: '🔒',
            title: l10n.welcomeFeature3Title,
            description: l10n.welcomeFeature3Desc,
          ),
          const SizedBox(height: 24),

          // ── Nota sobre privacidad ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: cs.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.welcomePrivacyNote,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.primary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;

  const _FeatureItem({
    required this.emoji,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

