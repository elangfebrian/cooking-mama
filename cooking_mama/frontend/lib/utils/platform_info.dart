import 'package:flutter/foundation.dart';

/// Penanda platform. Semua perubahan khusus mobile dibungkus dengan
/// [AppPlatform.isMobileApp] supaya versi WEB tidak berubah sama sekali.
class AppPlatform {
  AppPlatform._();

  /// Khusus tes: isi `true`/`false` untuk memaksa mode. Biarkan null di produksi.
  /// (Di `flutter test`, defaultTargetPlatform = android, jadi tes tampilan web
  /// perlu `AppPlatform.debugOverride = false;`.)
  @visibleForTesting
  static bool? debugOverride;

  /// true hanya pada aplikasi native Android / iOS (bukan web, bukan desktop).
  static bool get isMobileApp {
    final forced = debugOverride;
    if (forced != null) return forced;
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
  }
}
