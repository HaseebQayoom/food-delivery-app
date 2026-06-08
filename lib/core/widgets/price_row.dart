import 'package:flutter/material.dart';

class PriceRow extends StatelessWidget {
  final String label;
  final int amount;
  final bool isBold;
  final String currency;

  const PriceRow({
    super.key,
    required this.label,
    required this.amount,
    this.isBold = false,
    this.currency = 'Rs',
  });

  @override
  Widget build(BuildContext context) {
    final base = isBold
        ? Theme.of(context).textTheme.titleSmall
        : Theme.of(context).textTheme.bodyMedium;

    return Row(
      children: [
        Text(label, style: base),
        const Spacer(),
        Text(
          '$currency ${_format(amount)}',
          style: base!.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _format(int n) {
    if (n >= 1000) {
      return n.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]},',
      );
    }
    return n.toString();
  }
}
