import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/features/premium/promo_code_sheet.dart';
import 'package:kaku/features/premium/widgets/feature_tile.dart';
import 'package:kaku/features/premium/widgets/hero_section.dart';
import 'package:kaku/features/premium/widgets/price_card.dart';
import 'package:kaku/features/premium/widgets/section_label.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/premium_provider.dart';
import 'package:kaku/shared/services/billing_service.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _isPurchasing = false;
  String? _localizedPrice; // precio real de Google Play

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
    _loadPrice();
  }

  Future<void> _loadPrice() async {
    final price = await BillingService.getLocalizedPrice();
    if (mounted && price != null) {
      setState(() => _localizedPrice = price);
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Simulación de compra — en Paso 4 se conecta a Google Play ──
  Future<void> _onPurchase(AppLocalizations l10n) async {
    setState(() => _isPurchasing = true);

    final result = await BillingService.purchase();

    if (!mounted) return;
    setState(() => _isPurchasing = false);

    switch (result) {
      case BillingResult.success:
        // Premium activado — PremiumService ya lo guardó
        ref.read(premiumNotifierProvider.notifier).activate('purchase');
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.welcomeToPremium),
            behavior: SnackBarBehavior.floating,
          ),
        );

      case BillingResult.cancelled:
      // El usuario canceló — no hacer nada

      case BillingResult.pending:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.billingPending),
            behavior: SnackBarBehavior.floating,
          ),
        );

      case BillingResult.alreadyPurchased:
        // Ya lo compró — restaurar directamente
        await ref.read(premiumNotifierProvider.notifier).activate('restore');
        if (!mounted) return;
        Navigator.of(context).pop();

      case BillingResult.productNotFound:
        _showError(l10n, l10n.billingProductNotFound);

      case BillingResult.failed:
        _showError(l10n, l10n.billingFailed);

      default:
        break;
    }
  }

  void _openPromoCode() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PromoCodeSheet(
        onSuccess: () {
          ref.read(premiumNotifierProvider.notifier).activate('promo_code');
          Navigator.of(context).pop(); // cierra sheet
          Navigator.of(context).pop(); // cierra PremiumScreen
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            slivers: [
              // ── AppBar ──────────────────────────────────
              SliverAppBar(
                pinned: false,
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  // onTap: () => Navigator.of(context).pop(),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Hero ──────────────────────────────
                    HeroSection(),
                    const SizedBox(height: 36),

                    // ── Features ──────────────────────────
                    SectionLabel(label: l10n.labelUnlockTitle),
                    const SizedBox(height: 12),
                    ..._features(l10n, cs).map((f) => FeatureTile(feature: f)),

                    const SizedBox(height: 32),

                    // ── Precio y CTA ───────────────────────
                    PriceCard(
                      isPurchasing: _isPurchasing,
                      localizedPrice: _localizedPrice,
                      onPurchase: () => _onPurchase(l10n),
                    ),

                    const SizedBox(height: 16),

                    // ── Restaurar compra ───────────────────
                    Center(
                      child: TextButton(
                        onPressed: () => _onRestore(l10n),
                        child: Text(
                          l10n.billingRestorePurchase,
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),

                    // ── Código promo ───────────────────────
                    Center(
                      child: TextButton.icon(
                        onPressed: _openPromoCode,
                        icon: Icon(
                          Icons.card_giftcard_outlined,
                          size: 16,
                          color: cs.primary,
                        ),
                        label: Text(
                          l10n.billingCodePromo,
                          style: TextStyle(fontSize: 13, color: cs.primary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Nota legal ─────────────────────────
                    Text(
                      l10n.billingNoteLegal,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onRestore(AppLocalizations l10n) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(l10n.verifyingPurchase),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 10),
      ),
    );

    final result = await BillingService.restore();

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    switch (result) {
      case BillingResult.success:
        ref.read(premiumNotifierProvider.notifier).activate('restore');
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.verifyingPurchaseSuccess),
            behavior: SnackBarBehavior.floating,
          ),
        );

      case BillingResult.notFound:
        _showError(l10n, l10n.billingRestorePurchaseNotFound);

      default:
        _showError(l10n, l10n.billingRestorePurchaseError);
    }
  }

  void _showError(AppLocalizations l10n, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.error),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.btnUnderstood),
          ),
        ],
      ),
    );
  }

  List<Feature> _features(AppLocalizations l10n, ColorScheme cs) => [
    Feature(
      '☁️',
      l10n.premiumFeatureBackupDrive,
      l10n.premiumFeatureBackupDriveSubtitle,
    ),
    Feature(
      '📄',
      l10n.premiumFeatureExportPdf,
      l10n.premiumFeatureExportPdfSubtitle,
    ),
    Feature(
      '📅',
      l10n.premiumFeatureExportCustomRange,
      l10n.premiumFeatureExportCustomRangeSubtitle,
    ),
    Feature(
      '🎯',
      l10n.premiumFeatureUnlimitedGoals,
      l10n.premiumFeatureUnlimitedGoalsSubtitle,
    ),
    Feature(
      '📊',
      l10n.premiumFeatureUnlimitedBudgets,
      l10n.premiumFeatureUnlimitedBudgetsSubtitle,
    ),
    Feature(
      '🗂️',
      l10n.premiumFeatureUnlimitedCategories,
      l10n.premiumFeatureUnlimitedCategoriesSubtitle,
    ),
    Feature(
      '🔒',
      l10n.premiumFeaturePinLock,
      l10n.premiumFeaturePinLockSubtitle,
    ),
    Feature(
      '📈',
      l10n.premiumFeatureViewHistory,
      l10n.premiumFeatureViewHistorySubtitle,
    ),
  ];
}
