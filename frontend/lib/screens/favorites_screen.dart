import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../router/routes.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/page_layout.dart';
import '../widgets/recipe_grid.dart';

/// Resep tersimpan — PRIVAT (dijaga guard di app_router.dart).
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Title(
      title: context.tr('fav.tab'),
      color: AppTheme.orange,
      child: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final favs = AppState.instance.favorites;
          return PageScroll(
            children: [
              ContentBox(
                verticalPadding: 32,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.tr('fav.title'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tr('fav.count', args: {'n': favs.length}),
                      style: const TextStyle(color: AppTheme.grey),
                    ),
                    const SizedBox(height: 28),
                    if (favs.isEmpty)
                      EmptyState(
                        icon: Icons.bookmark_border,
                        title: context.tr('fav.empty.title'),
                        message: context.tr('fav.empty.msg'),
                        actionLabel: context.tr('fav.empty.cta'),
                        onAction: () => context.go(AppRoutes.home),
                      )
                    else
                      RecipeGrid(recipes: favs),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
