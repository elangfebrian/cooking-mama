import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/recipe.dart';
import '../router/routes.dart';
import 'hover_builder.dart';
import 'recipe_card.dart';
import 'recipe_image.dart';

/// Tile "Pencarian Populer": foto 4:3 dengan judul di atas gradasi gelap.
/// Mengetuk tile mencari resep dengan kata kunci tersebut.
class PopularTile extends StatelessWidget {
  const PopularTile({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      builder: (context, hovered) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            context.go(AppRoutes.searchLocation(query: recipe.title)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(RecipeCard.radius),
          child: AspectRatio(
            aspectRatio: RecipeCard.imageRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedScale(
                  scale: hovered ? 1.06 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: RecipeImage(url: recipe.imageUrl, radius: 0),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0xB3000000)],
                      stops: [0.45, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 10,
                  child: Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
