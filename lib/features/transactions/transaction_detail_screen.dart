import 'package:flutter/material.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class TransactionDetailScreen extends StatelessWidget {
  final int id;

  const TransactionDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: Text('Transacción')),
      body: Center(child: Text('TransactionDetailScreen')),
    );
  }
}
