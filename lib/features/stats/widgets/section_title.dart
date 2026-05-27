import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title, subtitle;
  
  const SectionTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.35)),
        ),
      ],
    ),
  );
}
