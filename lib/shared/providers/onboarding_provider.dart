import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/shared/services/onboarding_service.dart';

class OnboardingNotifier extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() => OnboardingService.isCompleted();

  Future<void> complete() async {
    await OnboardingService.completed();
    state = const AsyncData(true);
  }

  Future<void> reset() async {
    await OnboardingService.reset();
    state = const AsyncData(false);
  }
}

final onboardingProvider = AsyncNotifierProvider<OnboardingNotifier, bool>(
  OnboardingNotifier.new,
);
