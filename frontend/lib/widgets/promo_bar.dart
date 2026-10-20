import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../router/routes.dart';
import '../theme/app_theme.dart';

/// Banner krem di dasar layar (seperti "Cookpad Premium - Mulai").
class PromoBar extends StatelessWidget {
  const PromoBar({super.key, required this.compact});

  /// true pada layar mobile: tanpa margin/radius, ukuran lebih kecil.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: compact ? EdgeInsets.zero : const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 24,
        vertical: compact ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: AppTheme.promoBackground,
        borderRadius: BorderRadius.circular(compact ? 0 : 12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cooking Mama Premium',
                  style: TextStyle(
                    fontSize: compact ? 15 : 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr('promo.subtitle'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: compact ? 13 : 17),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.infoLocation('premium')),
            style: ElevatedButton.styleFrom(
              foregroundColor: AppTheme.ink,
              minimumSize: Size(0, compact ? 40 : 50),
              padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 32),
              textStyle: TextStyle(
                fontSize: compact ? 15 : 18,
                fontWeight: FontWeight.w500,
              ),
            ).copyWith(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                (states) => states.contains(WidgetState.hovered) ||
                        states.contains(WidgetState.pressed)
                    ? AppTheme.goldDark
                    : AppTheme.gold,
              ),
            ),
            child: Text(context.tr('promo.cta')),
          ),
        ],
      ),
    );
  }
}
