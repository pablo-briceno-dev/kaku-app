import 'package:flutter/material.dart';

class HorizontalPager extends StatelessWidget {
  final List<Widget> children;

  const HorizontalPager({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: PageController(viewportFraction: 0.9),
      itemCount: children.length,
      itemBuilder: (_, index) => Padding(
        padding: const EdgeInsets.only(right: 12),
        child: children[index],
      ),
    );
  }
}
