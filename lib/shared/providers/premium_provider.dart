import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/shared/services/premium_service.dart';
import 'package:riverpod/legacy.dart';

final isPremiumProvider = FutureProvider<bool>(
  (ref) => PremiumService.isPremium(),
);

// StateNotifier para invalidar el provider cuando cambia
final premiumNotifierProvider =
    StateNotifierProvider<PremiumNotifier, AsyncValue<bool>>(
      (ref) => PremiumNotifier(),
    );

class PremiumNotifier extends StateNotifier<AsyncValue<bool>> {
  PremiumNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = AsyncValue.data(await PremiumService.isPremium());
  }

  Future<void> activate(String source) async {
    await PremiumService.activate(source: source);
    state = const AsyncValue.data(true);
  }

  Future<void> revoke() async {
    await PremiumService.revoke();
    state = const AsyncValue.data(false);
  }
}
