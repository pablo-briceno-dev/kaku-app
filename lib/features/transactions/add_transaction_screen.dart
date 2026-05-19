import 'package:flutter/material.dart';

class AddTransactionScreen extends StatelessWidget {
  final int? accountId;

  const AddTransactionScreen({super.key, this.accountId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('AddTransactionScreen')));
  }
}