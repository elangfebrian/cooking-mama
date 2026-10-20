import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';

import 'strings_en.dart';
import 'strings_es.dart';
import 'strings_id.dart';

/// Terjemahan aplikasi. Teks disimpan di file terpisah per bahasa
/// (`strings_id.dart`, `strings_en.dart`, `strings_es.dart`).
///
/// Cara memakai di widget:   `context.tr('nav.search')`
/// Dengan parameter:         `context.tr('search.count', args: {'n': 5})`
///
/// Menambah bahasa baru:
///  1. buat `strings_xx.dart` (salin `strings_en.dart`, terjemahkan nilainya),
///  2. daftarkan di [languages], [supportedLocales], [languageNames],
///     dan [_tables] di bawah ini.
/// Kunci yang belum diterjemahkan otomatis jatuh ke Inggris, lalu Indonesia.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const String defaultLanguage = 'id';
  static const List<String> languages = ['id', 'en', 'es'];
  static const List<Locale> supportedLocales = [
    Locale('id'),
    Locale('en'),
    Locale('es'),
  ];

  /// Nama bahasa ditulis dalam bahasanya sendiri (tidak ikut diterjemahkan).
  static const Map<String, String> languageNames = {
    'id': 'Bahasa Indonesia',
    'en': 'English',
    'es': 'Español',
  };

  static const Map<String, Map<String, String>> _tables = {
    'id': stringsId,
    'en': stringsEn,
    'es': stringsEs,
  };

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  /// Pencarian teks tanpa BuildContext (mis. dari lapisan data).
  static String lookup(
    String language,
    String key, {
    Map<String, Object> args = const {},
  }) {
    var text = _tables[language]?[key] ?? stringsEn[key] ?? stringsId[key] ?? key;
    args.forEach((name, value) {
      text = text.replaceAll('{$name}', '$value');
    });
    return text;
  }

  String t(String key, {Map<String, Object> args = const {}}) =>
      lookup(locale.languageCode, key, args: args);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.languages.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension TranslateContext on BuildContext {
  /// Teks terjemahan untuk [key] pada bahasa yang sedang aktif.
  String tr(String key, {Map<String, Object> args = const {}}) =>
      AppLocalizations.of(this).t(key, args: args);

  /// Nama kategori yang ditampilkan. Nilai kategori di data/URL tetap
  /// dalam bahasa Indonesia (mis. `?cat=Ayam`); hanya tampilannya yang
  /// diterjemahkan.
  String category(String value) {
    final key = 'cat.$value';
    final label = AppLocalizations.of(this).t(key);
    return label == key ? value : label;
  }
}
