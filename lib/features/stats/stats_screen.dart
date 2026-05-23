import 'package:flutter/material.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: Text('Estadísticas'), defaultActions: true),
      body: Center(child: Text('StatsScreen')),
    );
  }
}
