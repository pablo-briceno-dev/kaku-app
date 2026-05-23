import 'package:flutter/material.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: Text('Metas'), defaultActions: true),
      body: Center(child: Text('GoalsScreen')),
    );
  }
}
