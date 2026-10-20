import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'hover_builder.dart';

/// Chip kategori (Wrap, bukan list horizontal, supaya nyaman dengan mouse).
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in categories)
          _Chip(
            label: context.category(c),
            selected: c == selected,
            onTap: () => onSelected(c),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      builder: (context, hovered) {
        final Color background = selected
            ? (hovered ? AppTheme.orangeDark : AppTheme.orange)
            : Colors.white;
        final Color border = selected
            ? Colors.transparent
            : (hovered ? AppTheme.orange : AppTheme.line);
        final Color foreground = selected
            ? Colors.white
            : (hovered ? AppTheme.orange : AppTheme.ink);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: border),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }
}
