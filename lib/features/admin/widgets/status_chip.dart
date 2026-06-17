import 'package:flutter/material.dart';
import 'package:food_delivery/models/order_model.dart';

class StatusChip extends StatelessWidget {
  final OrderStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color color;
    switch (status) {
      case OrderStatus.newOrder:
        color = cs.primary;
      case OrderStatus.preparing:
        color = const Color(0xFFFFB400);
      case OrderStatus.onTheWay:
        color = cs.tertiary;
      case OrderStatus.delivered:
        color = const Color(0xFF2DBE60);
      case OrderStatus.cancelled:
        color = cs.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall!.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
