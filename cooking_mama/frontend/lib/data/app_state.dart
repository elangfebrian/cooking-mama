import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';
import '../services/api_client.dart';

/// State global sederhana (tanpa package state-management tambahan).
/// Seluruh data berasal dari REST API Cooking Mama (lihat ApiClient).
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  static const String _kToken = 'auth_token';
  static const String _kUser = 'auth_user';
  static const String _kUserId = 'auth_user_id';

  final ApiClient _api = ApiClient.instance;

  // Status autentikasi dipisah ke notifier tersendiri agar GoRouter hanya
  // mengevaluasi ulang guard saat login/logout, bukan setiap state berubah.
  final ValueNotifier<bool> _auth = ValueNotifier<bool>(false);
  Listenable get authChanges => _auth;
  bool get isLoggedIn => _auth.value;

  /// JWT dari /auth/login atau /auth/register.
  String? authToken;
  int? userId;
  String userName = 'Mama Rina';

  /// Resep yang ingin disimpan saat pengguna belum login; diproses otomatis
  /// setelah login berhasil.
  int? pendingFavoriteId;

  /// Daftar resep dari GET /api/recipes (terbaru dulu).
  final List<Recipe> recipes = [];

  List<Recipe> get favorites => recipes.where((r) => r.isFavorite).toList();
  List<Recipe> get myRecipes =>
      userId == null ? [] : recipes.where((r) => r.authorId == userId).toList();

  Recipe? findById(int id) {
    for (final r in recipes) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Memulihkan sesi, memvalidasinya ke server, lalu memuat resep.
  /// Panggil sebelum `runApp`.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_kToken);
      if (token != null && token.isNotEmpty) {
        authToken = token;
        _api.token = token;
        userName = prefs.getString(_kUser) ?? userName;
        userId = prefs.getInt(_kUserId);
        _auth.value = true;
      }
    } catch (_) {
      // Penyimpanan tidak tersedia (mis. mode privat): lanjut sebagai tamu.
    }

    if (authToken != null) await _verifySession();
    await loadRecipes();
  }

  /// Token kedaluwarsa/tidak valid -> keluar. Server tidak terjangkau ->
  /// sesi tetap dipertahankan (pengguna tidak ter-logout hanya karena offline).
  Future<void> _verifySession() async {
    try {
      final me = await _api.get('/auth/me') as Map<String, dynamic>;
      userName = me['name'] ?? userName;
      userId = me['id'];
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        authToken = null;
        userId = null;
        _api.token = null;
        _auth.value = false;
        await _clearSession();
      }
    }
  }

  /// GET /api/recipes -> mengisi [recipes]. Mengembalikan false bila gagal.
  Future<bool> loadRecipes() async {
    try {
      final list = await _api.get('/recipes', query: {'limit': '100'}) as List;
      recipes
        ..clear()
        ..addAll(list.map((j) => Recipe.fromJson(j as Map<String, dynamic>)));
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      debugPrint('Gagal memuat resep: ${e.message}');
      return false;
    }
  }

  /// POST /api/auth/login. Melempar [ApiException] bila gagal.
  Future<void> login(String email, String password) async {
    final data = await _api.post('/auth/login', {
      'email': email.trim(),
      'password': password,
    });
    await _startSession(data as Map<String, dynamic>);
  }

  /// POST /api/auth/register. Melempar [ApiException] bila gagal.
  Future<void> register(String name, String email, String password) async {
    final data = await _api.post('/auth/register', {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
    });
    await _startSession(data as Map<String, dynamic>);
  }

  Future<void> _startSession(Map<String, dynamic> data) async {
    final user = data['user'] as Map<String, dynamic>;
    authToken = data['token'] as String;
    _api.token = authToken;
    userId = user['id'];
    userName = user['name'] ?? userName;
    await _persistSession();
    await loadRecipes(); // muat ulang agar is_favorite sesuai akun ini
    _applyPendingFavorite();
    _auth.value = true; // memicu guard router
    notifyListeners();
  }

  void logout() {
    authToken = null;
    userId = null;
    _api.token = null;
    pendingFavoriteId = null;
    for (final r in recipes) {
      r.isFavorite = false;
    }
    unawaited(_clearSession());
    _auth.value = false;
    notifyListeners();
  }

  /// Optimistic update: ikon berubah langsung, lalu disinkronkan ke
  /// PUT/DELETE /api/recipes/:id/favorite. Dibatalkan bila server menolak.
  void toggleFavorite(Recipe r) {
    final next = !r.isFavorite;
    r.isFavorite = next;
    notifyListeners();
    unawaited(_syncFavorite(r, next));
  }

  Future<void> _syncFavorite(Recipe r, bool value) async {
    try {
      if (value) {
        await _api.put('/recipes/${r.id}/favorite');
      } else {
        await _api.delete('/recipes/${r.id}/favorite');
      }
    } on ApiException catch (e) {
      r.isFavorite = !value;
      notifyListeners();
      if (e.isUnauthorized) logout();
    }
  }

  /// POST /api/recipes (+ POST /api/uploads/image bila ada foto dari
  /// kamera/galeri). Mengembalikan resep yang sudah tersimpan di server.
  Future<Recipe> addRecipe(Recipe draft, {String? photoPath}) async {
    var imageUrl = draft.imageUrl;
    if (photoPath != null && photoPath.isNotEmpty) {
      imageUrl = await _api.uploadImage(photoPath);
    }
    final data = await _api.post('/recipes', {
      'title': draft.title,
      'description': draft.description,
      'category': draft.category,
      'cook_minutes': draft.cookMinutes,
      'servings': draft.servings,
      'image_url': imageUrl,
      'ingredients': draft.ingredients,
      'steps': draft.steps,
    });
    final created = Recipe.fromJson(data as Map<String, dynamic>);
    recipes.insert(0, created);
    notifyListeners();
    return created;
  }

  /// POST /api/recipes/:id/comments.
  Future<void> addComment(Recipe r, String text) async {
    final data = await _api.post('/recipes/${r.id}/comments', {'text': text});
    r.comments.insert(0, Comment.fromJson(data as Map<String, dynamic>));
    notifyListeners();
  }

  /// Hanya untuk widget test: mengisi daftar resep tanpa memanggil API.
  @visibleForTesting
  void setRecipesForTest(List<Recipe> items) {
    recipes
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  void _applyPendingFavorite() {
    final id = pendingFavoriteId;
    pendingFavoriteId = null;
    if (id == null) return;
    final recipe = findById(id);
    if (recipe != null && !recipe.isFavorite) toggleFavorite(recipe);
  }

  Future<void> _persistSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kToken, authToken ?? '');
      await prefs.setString(_kUser, userName);
      if (userId != null) await prefs.setInt(_kUserId, userId!);
    } catch (_) {}
  }

  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kToken);
      await prefs.remove(_kUser);
      await prefs.remove(_kUserId);
    } catch (_) {}
  }
}
