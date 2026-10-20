import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet & tema ala Cookpad Web.
///
/// Nilai hex yang dipakai:
///  * Primer (oranye)   : #F5711F
///  * Primer hover/dark : #D95B0E
///  * Oranye lembut     : #FFF1E6  (latar chip/hero/ikon)
///  * Background halaman: #FFFFFF, section abu sangat terang #F7F7F7
///  * Teks utama        : #333333, teks sekunder #757575
///  * Garis/border      : #E6E6E6, isi kolom input #F3F3F3
///  * Latar halaman     : #F6F5F2 (panel putih bulat di atasnya, gaya Cookpad)
///  * Banner premium    : latar #FDF3DD, tombol emas #E9B93A
///  * Font              : Noto Sans (via google_fonts)
class AppTheme {
  AppTheme._();

  static const Color orange = Color(0xFFF5711F);
  static const Color orangeDark = Color(0xFFD95B0E);
  static const Color orangeSoft = Color(0xFFFFF1E6);
  static const Color background = Color(0xFFF7F7F7);
  static const Color ink = Color(0xFF333333);
  static const Color grey = Color(0xFF757575);
  static const Color line = Color(0xFFE6E6E6);
  static const Color fieldFill = Color(0xFFF3F3F3);
  static const Color shellBackground = Color(0xFFF6F5F2);
  static const Color hoverFill = Color(0xFFF3F3F3);
  static const Color promoBackground = Color(0xFFFDF3DD);
  static const Color gold = Color(0xFFE9B93A);
  static const Color goldDark = Color(0xFFD9A82B);
  static const Color brandBrown = Color(0xFF3B1F0E);
  static const Color outline = Color(0xFFD0D0D0);

  /// Tes widget mematikan font web agar tidak mengunduh dari jaringan.
  static bool useWebFonts = true;

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: orange,
      primary: orange,
      onPrimary: Colors.white,
      onSurface: ink,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: useWebFonts
          ? GoogleFonts.notoSansTextTheme().apply(
              bodyColor: ink,
              displayColor: ink,
            )
          : null,
      scaffoldBackgroundColor: Colors.white,
      dividerTheme: const DividerThemeData(color: line, space: 1, thickness: 1),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(const Color(0xFFBDBDBD)),
        thickness: WidgetStateProperty.all(8),
        radius: const Radius.circular(8),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.disabled)) return line;
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.pressed)) {
              return orangeDark;
            }
            return orange;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(64, 48),
          side: const BorderSide(color: line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        hintStyle: const TextStyle(color: grey),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: orange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
