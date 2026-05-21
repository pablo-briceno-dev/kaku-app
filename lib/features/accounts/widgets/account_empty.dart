import 'package:flutter/material.dart';

class AccountEmpty extends StatelessWidget {
  const AccountEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Text('💸​', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 10),
          Text(
            'Sin cuentas creadas',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
