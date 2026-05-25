import 'package:flutter/material.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: Text('Transacciones')),
      body: Center(child: Text('TransactionsScreen')),
    );
  }
}
