import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/router/app_router.dart';

class KakuApp extends ConsumerWidget {
  const KakuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Kaku',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7CFFD4),
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}
