import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';

/// Menyimpan bahasa yang dipilih (default Indonesia) dan mengingatnya di
/// penyimpanan browser. `MaterialApp` mendengarkan controller ini.
class LocaleController extends ChangeNotifier {
  LocaleController._();
  static final LocaleController instance = LocaleController._();

  static const String _key = 'app_language';

  String _code = AppLocalizations.defaultLanguage;

  String get code => _code;
  Locale get locale => Locale(_code);

  /// Panggil sebelum `runApp` agar bahasa pilihan terakhir langsung dipakai.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      if (saved != null && AppLocalizations.languages.contains(saved)) {
        _code = saved;
      }
    } catch (_) {
      // Penyimpanan tidak tersedia: tetap pakai bahasa default.
    }
  }

  Future<void> setLanguage(String code) async {
    if (!AppLocalizations.languages.contains(code) || code == _code) return;
    _code = code;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, code);
    } catch (_) {}
  }
}
