import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/features/premium/promo_code_sheet.dart';
import 'package:kaku/features/premium/widgets/feature_tile.dart';
import 'package:kaku/features/premium/widgets/hero_section.dart';
import 'package:kaku/features/premium/widgets/price_card.dart';
import 'package:kaku/features/premium/widgets/section_label.dart';
import 'package:kaku/shared/providers/premium_provider.dart';

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
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Simulación de compra — en Paso 4 se conecta a Google Play ──
  Future<void> _onPurchase() async {
    setState(() => _isPurchasing = true);

    // TODO Paso 4: reemplazar con llamada real a Google Play Billing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    await ref.read(premiumNotifierProvider.notifier).activate('purchase');

    setState(() => _isPurchasing = false);
    if (mounted) Navigator.of(context).pop();
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
                    SectionLabel(label: 'TODO LO QUE DESBLOQUEAS'),
                    const SizedBox(height: 12),
                    ..._features(cs).map((f) => FeatureTile(feature: f)),

                    const SizedBox(height: 32),

                    // ── Precio y CTA ───────────────────────
                    PriceCard(
                      isPurchasing: _isPurchasing,
                      onPurchase: _onPurchase,
                    ),

                    const SizedBox(height: 16),

                    // ── Restaurar compra ───────────────────
                    Center(
                      child: TextButton(
                        onPressed: _onRestore,
                        child: Text(
                          'Restaurar compra',
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
                          '¿Tienes un código de descuento?',
                          style: TextStyle(fontSize: 13, color: cs.primary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Nota legal ─────────────────────────
                    Text(
                      'Pago único · Sin suscripción · Sin cobros recurrentes',
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

  Future<void> _onRestore() async {
    // TODO Paso 4: restaurar compra desde Google Play
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verificando compra...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Feature> _features(ColorScheme cs) => [
    Feature(
      '☁️',
      'Backup automático a Google Drive',
      'Sincroniza tu base de datos y recibos en la nube con un toque',
    ),
    Feature(
      '📄',
      'PDF con fotos de recibos',
      'Exporta reportes completos con las imágenes adjuntas de cada compra',
    ),
    Feature(
      '📅',
      'Rango de fechas personalizado',
      'Exporta cualquier período de tiempo, no solo el mes actual',
    ),
    Feature(
      '🎯',
      'Metas ilimitadas',
      'Crea todas las metas de ahorro que necesites sin restricciones',
    ),
    Feature(
      '📊',
      'Presupuestos ilimitados',
      'Asigna límites a todas tus categorías, no solo 3',
    ),
    Feature(
      '🗂️',
      'Categorías personalizadas ilimitadas',
      'Organiza tus gastos con todas las categorías que quieras',
    ),
    Feature(
      '🔒',
      'Bloqueo con PIN o biometría',
      'Protege tu información financiera con huella, Face ID o PIN propio',
    ),
    Feature(
      '📈',
      'Historial completo de estadísticas',
      'Analiza tus patrones de gasto en cualquier período pasado',
    ),
  ];
}
