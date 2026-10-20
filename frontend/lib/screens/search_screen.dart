import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../router/routes.dart';
import '../theme/app_theme.dart';
import '../widgets/category_chips.dart';
import '../widgets/empty_state.dart';
import '../widgets/page_layout.dart';
import '../widgets/recipe_grid.dart';
import '../widgets/search_box.dart';

/// Pencarian — PUBLIK. Kata kunci & kategori ada di URL:
/// `/search?q=ayam&cat=Ayam`. Kolom pencarian berada di navbar.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key, this.query = '', this.category = 'Semua'});

  final String query;
  final String category;

  @override
  Widget build(BuildContext context) {
    final q = query.trim().toLowerCase();

    return Title(
      title: q.isEmpty
          ? context.tr('search.tab')
          : context.tr('search.tabQuery', args: {'q': query}),
      color: AppTheme.orange,
      child: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final results = AppState.instance.recipes.where((r) {
            final matchCategory = category == 'Semua' || r.category == category;
            final matchQuery = q.isEmpty ||
                r.title.toLowerCase().contains(q) ||
                r.ingredients.any((i) => i.toLowerCase().contains(q));
            return matchCategory && matchQuery;
          }).toList();

          return PageScroll(
            children: [
              ContentBox(
                verticalPadding: 32,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: SearchBox(initialQuery: query),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      q.isEmpty
                          ? context.tr('search.all')
                          : context.tr('search.resultsFor', args: {'q': query}),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tr('search.count', args: {'n': results.length}),
                      style: const TextStyle(color: AppTheme.grey),
                    ),
                    const SizedBox(height: 20),
                    CategoryChips(
                      selected: category,
                      onSelected: (c) => context.go(
                        AppRoutes.searchLocation(query: query, category: c),
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (results.isEmpty)
                      EmptyState(
                        icon: Icons.search_off,
                        title: context.tr('search.empty.title'),
                        message: context.tr('search.empty.msg'),
                        actionLabel: context.tr('search.empty.cta'),
                        onAction: () => context.go(AppRoutes.search),
                      )
                    else
                      RecipeGrid(recipes: results),
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
