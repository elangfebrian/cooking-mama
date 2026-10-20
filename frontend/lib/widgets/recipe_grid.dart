import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../utils/responsive.dart';
import 'recipe_card.dart';

/// Grid resep responsif: 2-5 kolom mengikuti lebar area konten.
/// [maxRows] membatasi jumlah baris (mis. 1 untuk "Resep populer").
class RecipeGrid extends StatelessWidget {
  const RecipeGrid({
    super.key,
    required this.recipes,
    this.maxRows,
    this.itemBuilder,
  });

  final List<Recipe> recipes;
  final int? maxRows;

  /// Bentuk item kustom (mis. tile "Pencarian Populer"); default RecipeCard.
  final Widget Function(Recipe recipe)? itemBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = Breakpoints.gridColumns(width);
        final gap = Breakpoints.gridGap(width);
        final items = maxRows == null
            ? recipes
            : recipes.take(columns * maxRows!).toList();

        final rows = <Widget>[];
        for (var i = 0; i < items.length; i += columns) {
          final chunk = items.skip(i).take(columns).toList();
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var j = 0; j < columns; j++) ...[
                  if (j > 0) SizedBox(width: gap),
                  Expanded(
                    child: j < chunk.length
                        ? (itemBuilder?.call(chunk[j]) ??
                            RecipeCard(recipe: chunk[j]))
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          );
          if (i + columns < items.length) rows.add(SizedBox(height: gap + 8));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}
