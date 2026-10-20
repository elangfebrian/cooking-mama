import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/app_state.dart';
import '../models/recipe.dart';
import 'routes.dart';

/// URL halaman yang sedang dibuka (termasuk query string).
String currentLocation(BuildContext context) =>
    GoRouter.of(context).routeInformationProvider.value.uri.toString();

/// Dipakai oleh aksi privat di halaman publik (komentar, dll).
/// Mengembalikan `true` bila sudah login. Bila belum, pengguna dibawa ke
/// /login?from=<halaman ini> dan fungsi mengembalikan `false`.
bool requireLogin(BuildContext context) {
  if (AppState.instance.isLoggedIn) return true;
  context.go(AppRoutes.loginLocation(from: currentLocation(context)));
  return false;
}

/// Simpan / hapus dari tersimpan.
/// Bila belum login: ingat resepnya, arahkan ke login, lalu setelah login
/// resep otomatis tersimpan dan pengguna kembali ke halaman semula.
void toggleFavoriteGuarded(BuildContext context, Recipe recipe) {
  if (!AppState.instance.isLoggedIn) {
    AppState.instance.pendingFavoriteId = recipe.id;
    context.go(AppRoutes.loginLocation(from: currentLocation(context)));
    return;
  }
  AppState.instance.toggleFavorite(recipe);
}
