import 'package:flutter/material.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: Text('Configuración'), defaultActions: false),
      body: Center(child: Text('SettingsScreen')),
    );
  }
}
