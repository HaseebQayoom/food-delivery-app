import 'package:flutter/material.dart';
import 'package:food_delivery/theme/app_theme.dart';

// Usage in any widget:
//   final cs = context.cs;        → Theme.of(context).colorScheme
//   final tt = context.tt;        → Theme.of(context).textTheme
//   final ac = context.appColors; → custom AppThemeColors extension
extension ContextTheme on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get cs => Theme.of(this).colorScheme;
  TextTheme get tt => Theme.of(this).textTheme;
  AppThemeColors get appColors => Theme.of(this).extension<AppThemeColors>()!;
}

extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}

extension IntExtension on int {
  // Formats an integer as Pakistani Rupees: 1200 → "Rs 1,200"
  String toRs() {
    if (this >= 1000) {
      final formatted = toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]},',
      );
      return 'Rs $formatted';
    }
    return 'Rs $this';
  }
}

extension DateTimeExtension on DateTime {
  String toOrderDate() {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '$day ${months[month - 1]} $year';
  }

  String toTimeAgo() {
    final diff = DateTime.now().difference(this);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
