import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Logo "cooking mama": lingkaran oranye + wordmark huruf kecil cokelat tua,
/// meniru gaya logo Cookpad. [size] = diameter lingkaran.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 40,
    this.iconOnly = false,
    this.labelOpacity = 1.0,
  });

  final double size;
  final bool iconOnly;

  /// Opasitas wordmark (0 saat sidebar diminimize, dianimasikan halus).
  final double labelOpacity;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppTheme.orange,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.soup_kitchen, color: Colors.white, size: size * 0.58),
    );
    if (iconOnly) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.18),
        Flexible(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: labelOpacity,
            child: Text(
              'cooking mama',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontSize: size * 0.6,
                fontWeight: FontWeight.w800,
                color: AppTheme.brandBrown,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
