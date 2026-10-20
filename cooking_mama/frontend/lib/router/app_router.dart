import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/app_state.dart';
import '../screens/countries_screen.dart';
import '../screens/create_recipe_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/home_screen.dart';
import '../screens/info_screen.dart';
import '../screens/login_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/recipe_detail_screen.dart';
import '../screens/register_screen.dart';
import '../screens/search_screen.dart';
import '../utils/platform_info.dart';
import '../widgets/app_shell.dart';
import 'routes.dart';

/// Konfigurasi GoRouter.
///
/// Aturan akses:
///  * PUBLIK  : /, /search, /recipe/:id, /countries, /info/:slug,
///              /login, /register
///  * PRIVAT  : /saved, /create, /profile  -> redirect ke
///              /login?from=<tujuan> bila belum login
///  * Setelah login, pengguna dikembalikan ke `from` (atau ke `/`).
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.home,
    // Hanya login/logout yang memicu evaluasi ulang guard (bukan setiap
    // perubahan state seperti menyimpan resep atau menulis komentar).
    refreshListenable: AppState.instance.authChanges,
    redirect: _guard,
    errorBuilder: (context, state) => AppShell(
      location: state.uri,
      child: const NotFoundScreen(),
    ),
    routes: [
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) =>
            AppShell(location: state.uri, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => _page(
              state,
              HomeScreen(category: state.uri.queryParameters['cat'] ?? 'Semua'),
            ),
          ),
          GoRoute(
            path: AppRoutes.search,
            pageBuilder: (context, state) => _page(
              state,
              SearchScreen(
                query: state.uri.queryParameters['q'] ?? '',
                category: state.uri.queryParameters['cat'] ?? 'Semua',
              ),
            ),
          ),
          // Deep link detail resep: /recipe/3  atau  /recipe/3-rendang-daging
          GoRoute(
            path: '${AppRoutes.recipe}/:id',
            pageBuilder: (context, state) => _page(
              state,
              RecipeDetailScreen(
                recipeId: AppRoutes.parseRecipeId(state.pathParameters['id']),
              ),
              // Key unik per URL agar posisi scroll direset saat pindah resep.
              key: ValueKey<String>(state.uri.toString()),
            ),
          ),
          GoRoute(
            path: AppRoutes.countries,
            pageBuilder: (context, state) =>
                _page(state, const CountriesScreen()),
          ),
          // Halaman statis: /info/premium, /info/faq, dst.
          GoRoute(
            path: '${AppRoutes.info}/:slug',
            pageBuilder: (context, state) => _page(
              state,
              InfoScreen(slug: state.pathParameters['slug'] ?? ''),
              key: ValueKey<String>(state.uri.toString()),
            ),
          ),
          GoRoute(
            path: AppRoutes.login,
            pageBuilder: (context, state) => _page(
              state,
              LoginScreen(
                redirectTo: AppRoutes.sanitizeRedirect(
                    state.uri.queryParameters['from']),
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.register,
            pageBuilder: (context, state) => _page(
              state,
              RegisterScreen(
                redirectTo: AppRoutes.sanitizeRedirect(
                    state.uri.queryParameters['from']),
              ),
            ),
          ),
          // ---- Rute privat ----
          GoRoute(
            path: AppRoutes.saved,
            pageBuilder: (context, state) =>
                _page(state, const FavoritesScreen()),
          ),
          GoRoute(
            path: AppRoutes.create,
            pageBuilder: (context, state) =>
                _page(state, const CreateRecipeScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) =>
                _page(state, const ProfileScreen()),
          ),
        ],
      ),
    ],
  );

  /// Guard berbasis status autentikasi.
  static String? _guard(BuildContext context, GoRouterState state) {
    final loggedIn = AppState.instance.isLoggedIn;
    final location = state.uri.toString();

    // Belum login membuka halaman privat -> ke login, ingat tujuan.
    if (!loggedIn && AppRoutes.isPrivate(location)) {
      return AppRoutes.loginLocation(from: location);
    }

    // Sudah login membuka login/register -> kembalikan ke tujuan awal.
    if (loggedIn && AppRoutes.isAuthPage(location)) {
      return AppRoutes.sanitizeRedirect(state.uri.queryParameters['from']) ??
          AppRoutes.home;
    }

    return null; // lanjut
  }

  /// Halaman tanpa animasi transisi: perilaku khas website (bukan app mobile).
  static Page<void> _page(GoRouterState state, Widget child, {LocalKey? key}) {
    // Mobile: transisi fade singkat antar tab/halaman.
    if (AppPlatform.isMobileApp) {
      return CustomTransitionPage<void>(
        key: key ?? state.pageKey,
        child: child,
        transitionDuration: const Duration(milliseconds: 180),
        transitionsBuilder: (context, animation, secondary, child) =>
            FadeTransition(opacity: animation, child: child),
      );
    }
    return NoTransitionPage<void>(key: key ?? state.pageKey, child: child);
  }
}
