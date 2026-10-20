import 'package:cooking_mama/data/app_state.dart';
import 'package:cooking_mama/l10n/locale_controller.dart';
import 'package:cooking_mama/main.dart';
import 'package:cooking_mama/models/recipe.dart';
import 'package:cooking_mama/router/app_router.dart';
import 'package:cooking_mama/screens/home_screen.dart';
import 'package:cooking_mama/theme/app_theme.dart';
import 'package:cooking_mama/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppPlatform.debugOverride = false; // tes lama = tampilan web/desktop
    AppTheme.useWebFonts = false; // jangan mengunduh font saat tes
    kBannerAutoplay = false; // tanpa Timer saat tes
    LocaleController.instance.setLanguage('id'); // selalu mulai dari default
  });

  Future<void> useViewport(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('Beranda bisa dibuka tanpa login (desktop)', (tester) async {
    await useViewport(tester, const Size(1400, 900));
    AppState.instance.logout();

    await tester.pumpWidget(const CookingMamaApp());
    AppRouter.router.go('/');
    await tester.pumpAndSettle();

    expect(find.text('Bingung masak apa minggu ini?'), findsOneWidget);
    expect(find.text('Cari'), findsWidgets);
    expect(find.text('Masuk'), findsWidgets);
    expect(find.text('Tulis Resep'), findsWidgets);
  });

  testWidgets('Sidebar bisa di-minimize dan diperluas', (tester) async {
    await useViewport(tester, const Size(1400, 900));
    AppState.instance.logout();

    await tester.pumpWidget(const CookingMamaApp());
    AppRouter.router.go('/');
    await tester.pumpAndSettle();

    // Lebar 1400 -> sidebar penuh; ketuk tombol "Ciutkan menu".
    await tester.tap(find.byIcon(Icons.keyboard_double_arrow_left));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.keyboard_double_arrow_right), findsOneWidget);

    await tester.tap(find.byIcon(Icons.keyboard_double_arrow_right));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.keyboard_double_arrow_left), findsOneWidget);
  });

  testWidgets('Halaman privat mengarahkan ke login', (tester) async {
    await useViewport(tester, const Size(1400, 900));
    AppState.instance.logout();

    await tester.pumpWidget(const CookingMamaApp());
    AppRouter.router.go('/profile');
    await tester.pumpAndSettle();

    expect(find.text('Masuk ke Cooking Mama'), findsOneWidget);
  });

  testWidgets('Deep link detail resep dapat dibuka tanpa login', (tester) async {
    await useViewport(tester, const Size(1400, 900));
    AppState.instance.logout();
    // Data resep kini dari REST API; tes memakai fixture lokal (tanpa jaringan).
    AppState.instance.setRecipesForTest([
      Recipe(
        id: 1,
        title: 'Nasi Goreng Kampung Spesial',
        description: 'Nasi goreng sederhana.',
        imageUrl: '',
        author: 'Bunda Sari',
        category: 'Nasi',
        cookMinutes: 20,
        servings: 2,
        ingredients: ['2 piring nasi putih dingin'],
        steps: ['Tumis bumbu halus hingga harum.'],
      ),
    ]);

    await tester.pumpWidget(const CookingMamaApp());
    AppRouter.router.go('/recipe/1-nasi-goreng-kampung-spesial');
    await tester.pumpAndSettle();

    expect(find.text('Bahan-bahan'), findsOneWidget);
    expect(find.text('Langkah memasak'), findsOneWidget);
  });

  testWidgets('Mobile memakai drawer, bukan sidebar tetap', (tester) async {
    await useViewport(tester, const Size(390, 800));
    AppState.instance.logout();

    await tester.pumpWidget(const CookingMamaApp());
    AppRouter.router.go('/');
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.menu), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text('Koleksi Resep'), findsOneWidget);
  });

  testWidgets('Bahasa bisa diganti ke Inggris dan Spanyol', (tester) async {
    await useViewport(tester, const Size(1400, 900));
    AppState.instance.logout();

    await tester.pumpWidget(const CookingMamaApp());
    AppRouter.router.go('/');
    await tester.pumpAndSettle();
    expect(find.text('Bingung masak apa minggu ini?'), findsOneWidget);

    LocaleController.instance.setLanguage('en');
    await tester.pumpAndSettle();
    expect(find.text('Not sure what to cook this week?'), findsOneWidget);
    expect(find.text('Log in'), findsWidgets);

    LocaleController.instance.setLanguage('es');
    await tester.pumpAndSettle();
    expect(find.text('¿No sabes qué cocinar esta semana?'), findsOneWidget);
  });

  testWidgets('Banner berganti otomatis tiap ±5,5 detik', (tester) async {
    await useViewport(tester, const Size(1400, 900));
    AppState.instance.logout();
    kBannerAutoplay = true;

    await tester.pumpWidget(const CookingMamaApp());
    AppRouter.router.go('/');
    await tester.pumpAndSettle();
    expect(find.text('Bingung masak apa minggu ini?'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(find.text('Punya resep andalan?'), findsOneWidget);

    // Pindah halaman agar carousel (dan Timer-nya) dibuang sebelum tes selesai.
    AppRouter.router.go('/countries');
    await tester.pumpAndSettle();
    kBannerAutoplay = false;
  });
}
