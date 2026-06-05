import 'package:flutter/material.dart';

class Feature {
  final String emoji;
  final String title;
  final String desc;

  const Feature(this.emoji, this.title, this.desc);
}

class FeatureTile extends StatelessWidget {
  final Feature feature;

  const FeatureTile({super.key, required this.feature});
 
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
 
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono con fondo
          Container(
            width:  44,
            height: 44,
            decoration: BoxDecoration(
              color:        cs.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(feature.emoji,
                style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 14),
 
          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontSize:   13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  feature.desc,
                  style: TextStyle(
                    fontSize: 12,
                    color:    cs.onSurfaceVariant,
                    height:   1.4,
                  ),
                ),
              ],
            ),
          ),
 
          // Check
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_circle_rounded,
              size:  18,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}