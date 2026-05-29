import 'package:flutter/material.dart';

class ContentWidgetEmpty extends StatelessWidget {
  final String title;
  final String message;

  const ContentWidgetEmpty({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 36)),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
