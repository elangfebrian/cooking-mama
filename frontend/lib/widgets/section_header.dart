import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'hover_link.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Teks abu-abu di kanan (mis. "Diperbarui 04.22").
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 36, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(color: AppTheme.grey, fontSize: 14),
            ),
          if (actionLabel != null && onAction != null)
            HoverLink(
              text: actionLabel!,
              onTap: onAction!,
              color: AppTheme.orange,
              hoverColor: AppTheme.orangeDark,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
        ],
      ),
    );
  }
}
