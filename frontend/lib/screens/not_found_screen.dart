import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../router/routes.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/page_layout.dart';

/// Dipakai untuk URL yang tidak dikenal dan resep yang tidak ada.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, this.title, this.message});

  /// Bila null, dipakai teks bawaan "halaman tidak ditemukan".
  final String? title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Title(
      title: context.tr('nf.tab'),
      color: AppTheme.orange,
      child: PageScroll(
        children: [
          ContentBox(
            verticalPadding: 40,
            child: EmptyState(
              icon: Icons.search_off,
              title: title ?? context.tr('nf.title'),
              message: message ?? context.tr('nf.msg'),
              actionLabel: context.tr('nf.cta'),
              onAction: () => context.go(AppRoutes.home),
            ),
          ),
        ],
      ),
    );
  }
}
