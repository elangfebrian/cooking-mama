import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/recipe.dart';
import '../router/auth_guard.dart';
import '../router/routes.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/hover_link.dart';
import '../widgets/page_layout.dart';
import '../widgets/recipe_image.dart';
import 'not_found_screen.dart';

/// Detail resep — PUBLIK & mendukung deep link:
///   /recipe/3                      (id saja)
///   /recipe/3-rendang-daging-sapi  (id + slug, URL kanonis)
/// Id yang tidak valid / tidak ada -> halaman "tidak ditemukan".
/// Komentar dan tombol simpan adalah aksi privat: bila belum login,
/// pengguna diarahkan ke /login?from=<halaman ini>.
class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key, required this.recipeId});

  final int? recipeId;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _sendComment(Recipe r) async {
    if (!requireLogin(context)) return;
    final text = _comment.text.trim();
    if (text.isEmpty) return;
    try {
      // POST /api/recipes/:id/comments
      await AppState.instance.addComment(r, text);
      _comment.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  Future<void> _share() async {
    // Di web, Uri.base = URL halaman saat ini (sudah berisi id & slug).
    await Clipboard.setData(ClipboardData(text: Uri.base.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('detail.copied'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final id = widget.recipeId;
        final recipe = id == null ? null : AppState.instance.findById(id);

        if (recipe == null) {
          return NotFoundScreen(
            title: context.tr('search.empty.title'),
            message: context.tr('detail.notFound.msg'),
          );
        }

        return Title(
          title: '${recipe.title} - Cooking Mama',
          color: AppTheme.orange,
          child: PageScroll(
            children: [
              ContentBox(
                maxWidth: 1100,
                child: LayoutBuilder(
                  builder: (context, c) => _buildBody(recipe, c.maxWidth >= 860),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(Recipe r, bool wide) {
    final hero = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: RecipeImage(url: r.imageUrl, radius: 0),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        _breadcrumb(r),
        const SizedBox(height: 20),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: hero),
              const SizedBox(width: 40),
              Expanded(flex: 5, child: _infoPanel(r, wide)),
            ],
          )
        else ...[
          hero,
          const SizedBox(height: 20),
          _infoPanel(r, wide),
        ],
        const SizedBox(height: 36),
        const Divider(),
        const SizedBox(height: 32),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 4, child: _ingredients(r)),
              const SizedBox(width: 48),
              Expanded(flex: 7, child: _steps(r)),
            ],
          )
        else ...[
          _ingredients(r),
          const SizedBox(height: 32),
          _steps(r),
        ],
        const SizedBox(height: 40),
        const Divider(),
        const SizedBox(height: 32),
        _comments(r, wide),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _breadcrumb(Recipe r) {
    const sep = Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Icon(Icons.chevron_right, size: 18, color: AppTheme.grey),
    );
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        HoverLink(
          text: context.tr('detail.crumbHome'),
          onTap: () => context.go(AppRoutes.home),
        ),
        sep,
        HoverLink(
          text: context.category(r.category),
          onTap: () =>
              context.go(AppRoutes.searchLocation(category: r.category)),
        ),
        sep,
        Text(r.title, style: const TextStyle(color: AppTheme.ink)),
      ],
    );
  }

  Widget _infoPanel(Recipe r, bool wide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          r.title,
          style: TextStyle(
            fontSize: wide ? 34 : 26,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        if (r.description.trim().isNotEmpty)
          Text(
            r.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.grey,
              height: 1.5,
            ),
          ),
        const SizedBox(height: 18),
        Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.orangeSoft,
              child: Icon(Icons.person, size: 22, color: AppTheme.orange),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                r.author,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Fact(
              icon: Icons.schedule,
              label: context.tr('detail.minutes', args: {'n': r.cookMinutes}),
            ),
            _Fact(
              icon: Icons.people_outline,
              label: context.tr('detail.servings', args: {'n': r.servings}),
            ),
            _Fact(
              icon: Icons.category_outlined,
              label: context.category(r.category),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _saveButton(r),
            OutlinedButton.icon(
              onPressed: _share,
              icon: const Icon(Icons.link, size: 18),
              label: Text(context.tr('detail.share')),
            ),
          ],
        ),
      ],
    );
  }

  Widget _saveButton(Recipe r) {
    if (r.isFavorite) {
      return OutlinedButton.icon(
        onPressed: () => toggleFavoriteGuarded(context, r),
        icon: const Icon(Icons.bookmark),
        label: Text(context.tr('detail.saved')),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.orange,
          side: const BorderSide(color: AppTheme.orange),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: () => toggleFavoriteGuarded(context, r),
      icon: const Icon(Icons.bookmark_border),
      label: Text(context.tr('detail.save')),
    );
  }

  Widget _ingredients(Recipe r) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('detail.ingredients'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                context.tr('detail.servings', args: {'n': r.servings}),
                style: const TextStyle(color: AppTheme.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < r.ingredients.length; i++) ...[
            if (i > 0) const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Text(
                r.ingredients[i],
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _steps(Recipe r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.tr('detail.steps'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < r.steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppTheme.orange,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      r.steps[i],
                      style: const TextStyle(fontSize: 16, height: 1.55),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _comments(Recipe r, bool wide) {
    final loggedIn = AppState.instance.isLoggedIn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.tr('detail.comments', args: {'n': r.comments.length}),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        if (loggedIn)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _comment,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: context.tr('detail.commentHint'),
                  ),
                  onSubmitted: (_) => _sendComment(r),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _sendComment(r),
                child: Text(
                  wide
                      ? context.tr('detail.send')
                      : context.tr('detail.sendShort'),
                ),
              ),
            ],
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.orangeSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(context.tr('detail.loginToComment')),
                ElevatedButton(
                  onPressed: () => requireLogin(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text(context.tr('action.login')),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        if (r.comments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              context.tr('detail.firstComment'),
              style: const TextStyle(color: AppTheme.grey),
            ),
          ),
        for (final c in r.comments)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.orangeSoft,
                  child: Icon(Icons.person, size: 20, color: AppTheme.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            c.user,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            c.date,
                            style: const TextStyle(
                              color: AppTheme.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(c.text, style: const TextStyle(height: 1.45)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.orangeSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.orange),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
