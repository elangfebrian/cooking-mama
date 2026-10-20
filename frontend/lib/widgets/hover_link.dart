import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'hover_builder.dart';

/// Teks tautan: berubah warna + garis bawah saat di-hover, kursor pointer.
class HoverLink extends StatelessWidget {
  const HoverLink({
    super.key,
    required this.text,
    required this.onTap,
    this.style,
    this.color = AppTheme.grey,
    this.hoverColor = AppTheme.orange,
    this.underlined = false,
  });

  final String text;
  final VoidCallback onTap;
  final TextStyle? style;
  final Color color;
  final Color hoverColor;
  final bool underlined;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      builder: (context, hovered) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Text(
          text,
          style: (style ?? const TextStyle()).copyWith(
            color: hovered ? hoverColor : color,
            decoration: (hovered || underlined)
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationColor: hoverColor,
          ),
        ),
      ),
    );
  }
}
