import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/recipe.dart';
import '../router/auth_guard.dart';
import '../router/routes.dart';
import '../theme/app_theme.dart';
import 'hover_builder.dart';
import 'recipe_image.dart';

/// Kartu resep ala Cookpad:
///  * gambar rasio 4:3 dengan sudut membulat 12px,
///  * judul tebal (maks 2 baris), ringkasan abu-abu, baris penulis + waktu,
///  * hover: kartu terangkat 3px, bayangan menebal, gambar zoom halus,
///    judul berubah oranye, kursor pointer,
///  * tombol simpan di pojok gambar (aksi privat -> dijaga guard login).
class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe});

  final Recipe recipe;

  static const double imageRatio = 4 / 3;
  static const double radius = 12;

  @override
  Widget build(BuildContext context) {
    final summary = recipe.description.trim().isNotEmpty
        ? recipe.description.trim()
        : recipe.ingredients.join(', ');

    return HoverBuilder(
      builder: (context, hovered) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.go(AppRoutes.recipeLocation(recipe)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(0, hovered ? -3.0 : 0.0, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  boxShadow: [
                    BoxShadow(
                      color: Color(hovered ? 0x2E000000 : 0x0F000000),
                      blurRadius: hovered ? 18 : 4,
                      offset: Offset(0, hovered ? 8 : 1),
                    ),
                  ],
                ),
                child: AspectRatio(
                  aspectRatio: imageRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(radius),
                        clipBehavior: Clip.antiAlias,
                        child: AnimatedScale(
                          scale: hovered ? 1.06 : 1.0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          child: RecipeImage(url: recipe.imageUrl, radius: 0),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _SaveButton(recipe: recipe),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: hovered ? AppTheme.orange : AppTheme.ink,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                child: Text(recipe.title),
              ),
              const SizedBox(height: 4),
              Text(
                summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: AppTheme.grey,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 11,
                    backgroundColor: AppTheme.orangeSoft,
                    child: Icon(Icons.person, size: 14, color: AppTheme.orange),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      recipe.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.schedule, size: 15, color: AppTheme.grey),
                  const SizedBox(width: 3),
                  Text(
                    context.tr('card.minutes', args: {'n': recipe.cookMinutes}),
                    style: const TextStyle(fontSize: 13, color: AppTheme.grey),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final saved = recipe.isFavorite;
        return Tooltip(
          message: saved
              ? context.tr('card.unsave')
              : context.tr('detail.save'),
          child: HoverBuilder(
            builder: (context, hovered) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => toggleFavoriteGuarded(context, recipe),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hovered ? AppTheme.orange : Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  saved ? Icons.bookmark : Icons.bookmark_border,
                  size: 20,
                  color: hovered ? Colors.white : AppTheme.orange,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
