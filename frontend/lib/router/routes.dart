import '../models/recipe.dart';

/// Daftar path, pembuat URL, dan aturan akses.
///
/// File ini sengaja TIDAK meng-import widget/screen apa pun supaya bisa dipakai
/// di mana saja (guard, navbar, kartu resep) tanpa circular import.
class AppRoutes {
  AppRoutes._();

  // ---- Publik (tanpa login) ----
  static const String home = '/';
  static const String search = '/search';
  static const String recipe = '/recipe'; // /recipe/:id  atau  /recipe/:id-slug
  static const String login = '/login';
  static const String register = '/register';
  static const String countries = '/countries';
  static const String info = '/info'; // /info/:slug

  // ---- Privat (wajib login) ----
  static const String saved = '/saved';
  static const String create = '/create';
  static const String profile = '/profile';

  static const List<String> privatePaths = [saved, create, profile];

  static String _pathOf(String location) => Uri.parse(location).path;

  static bool isPrivate(String location) {
    final path = _pathOf(location);
    return privatePaths.any((p) => path == p || path.startsWith('$p/'));
  }

  static bool isAuthPage(String location) {
    final path = _pathOf(location);
    return path == login || path == register;
  }

  // ---- Pembuat lokasi ----

  static String homeLocation({String category = 'Semua'}) {
    if (category == 'Semua') return home;
    return Uri(path: home, queryParameters: {'cat': category}).toString();
  }

  static String searchLocation({String query = '', String category = 'Semua'}) {
    final params = <String, String>{
      if (query.trim().isNotEmpty) 'q': query.trim(),
      if (category != 'Semua') 'cat': category,
    };
    return Uri(
      path: search,
      queryParameters: params.isEmpty ? null : params,
    ).toString();
  }

  /// URL kanonis detail resep, mis. `/recipe/1-nasi-goreng-kampung-spesial`.
  static String recipeLocation(Recipe r) => '$recipe/${r.id}-${slugify(r.title)}';

  /// Mengambil id dari parameter `:id`. Mendukung `3` maupun `3-rendang-daging`.
  static int? parseRecipeId(String? raw) {
    if (raw == null) return null;
    final match = RegExp(r'^\d+').firstMatch(raw);
    if (match == null) return null;
    return int.tryParse(match.group(0)!);
  }

  static String infoLocation(String slug) => '$info/$slug';

  static String loginLocation({String? from}) => _authLocation(login, from);

  static String registerLocation({String? from}) =>
      _authLocation(register, from);

  static String _authLocation(String path, String? from) {
    final safe = sanitizeRedirect(from);
    return Uri(
      path: path,
      queryParameters: safe == null ? null : {'from': safe},
    ).toString();
  }

  /// Mencegah open-redirect: hanya path internal (diawali satu '/') yang
  /// diterima, dan bukan halaman login/register itu sendiri.
  static String? sanitizeRedirect(String? from) {
    if (from == null || from.isEmpty) return null;
    if (!from.startsWith('/') || from.startsWith('//')) return null;
    if (from.contains(r'\')) return null;
    if (isAuthPage(from)) return null;
    return from;
  }

  static String slugify(String text) {
    final slug = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'resep' : slug;
  }
}
