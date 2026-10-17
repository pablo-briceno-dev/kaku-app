import 'package:flutter/material.dart';
import 'package:kaku/features/personal/calendar/widgets/month_grid.dart';

class DayCell extends StatelessWidget {
  final DateTime date;
  final bool isToday, isSelected;
  final DayMarkers markers;
  final VoidCallback onTap;

  const DayCell({
    super.key,
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.markers,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? cs.primary : null,
                border: isToday && !isSelected
                    ? Border.all(color: cs.primary)
                    : null,
              ),
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: isSelected ? cs.onPrimary : cs.onSurface,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 3),
            SizedBox(
              height: 5,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (markers.spent) _Dot(cs.error),
                  if (markers.planned) _Dot(cs.primary),
                  if (markers.note) _Dot(cs.tertiary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot(this.color);

  @override
  Widget build(BuildContext context) => Container(
    width: 5,
    height: 5,
    margin: const EdgeInsets.symmetric(horizontal: 1.5),
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}
