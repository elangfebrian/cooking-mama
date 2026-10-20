/// Breakpoint & ukuran layout responsif.
///
///  * mobile  : lebar < 600
///  * tablet  : 600 <= lebar < 960
///  * desktop : lebar >= 960
///
/// Konten dibatasi [maxContentWidth] agar tidak terasa seperti aplikasi mobile
/// yang direntangkan di monitor lebar.
class Breakpoints {
  Breakpoints._();

  static const double mobile = 600;
  static const double desktop = 960;
  static const double maxContentWidth = 1200;

  /// Di bawah lebar ini sidebar menjadi drawer (hamburger).
  static const double sidebarMin = 900;

  /// Di bawah lebar ini sidebar otomatis dalam mode minimize.
  static const double sidebarAutoCollapse = 1180;

  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < desktop;
  static bool isDesktop(double width) => width >= desktop;

  /// Padding horizontal halaman.
  static double pagePadding(double width) {
    if (width < mobile) return 16;
    if (width < desktop) return 24;
    return 32;
  }

  /// Jumlah kolom grid resep (2-5) menurut lebar area konten.
  static int gridColumns(double contentWidth) {
    if (contentWidth < 520) return 2;
    if (contentWidth < 800) return 3;
    if (contentWidth < 1080) return 4;
    return 5;
  }

  /// Jarak antar kartu pada grid.
  static double gridGap(double contentWidth) => contentWidth < 520 ? 12 : 20;
}
