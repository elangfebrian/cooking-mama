import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/info_pages.dart';
import '../l10n/app_localizations.dart';
import '../router/routes.dart';
import '../theme/app_theme.dart';
import '../widgets/page_layout.dart';
import 'not_found_screen.dart';

/// Halaman statis (/info/:slug) untuk Premium, Posting Bareng, FAQ, dll.
/// Slug yang tidak dikenal menampilkan halaman "tidak ditemukan".
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    if (!infoSlugs.contains(slug)) return const NotFoundScreen();

    final title = context.tr('info.$slug.title');
    final paragraphs = context.tr('info.$slug.body').split('\n\n');

    return Title(
      title: '$title - Cooking Mama',
      color: AppTheme.orange,
      child: PageScroll(
        children: [
          ContentBox(
            maxWidth: 800,
            verticalPadding: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                for (final p in paragraphs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      p,
                      style: const TextStyle(fontSize: 17, height: 1.7),
                    ),
                  ),
                if (slug == 'premium' || slug == 'posting-bareng') ...[
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.go(
                      slug == 'premium' ? AppRoutes.home : AppRoutes.create,
                    ),
                    child: Text(
                      slug == 'premium'
                          ? context.tr('info.explore')
                          : context.tr('action.write'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
