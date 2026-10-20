import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan lokal (offline) untuk id resep favorit.
///
/// Memakai shared_preferences (sudah ada di pubspec) karena datanya kecil:
/// hanya daftar id. Bila nanti perlu menyimpan resep lengkap + foto untuk
/// dibaca offline, pindahkan ke Hive/Isar dengan antarmuka yang sama.
class FavoritesStore {
  FavoritesStore._();

  static const String _key = 'favorite_recipe_ids';

  static Future<Set<int>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? const <String>[];
      return raw.map(int.tryParse).whereType<int>().toSet();
    } catch (_) {
      return <int>{};
    }
  }

  static Future<void> save(Iterable<int> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, ids.map((e) => '$e').toList());
    } catch (_) {
      // Gagal menyimpan tidak boleh membuat aplikasi crash.
    }
  }
}
