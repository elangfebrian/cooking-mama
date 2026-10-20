import 'package:cooking_mama/data/app_state.dart';
import 'package:cooking_mama/l10n/locale_controller.dart';
import 'package:cooking_mama/main.dart';
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
    AppTheme.useWebFonts = false;
    kBannerAutoplay = false;
    LocaleController.instance.setLanguage('id');
    AppPlatform.debugOverride = true;
  });
  tearDown(() => AppPlatform.debugOverride = null);

  testWidgets('App mobile menampilkan BottomNavigationBar 4 menu', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    AppState.instance.logout();

    await tester.pumpWidget(const CookingMamaApp());
    AppRouter.router.go('/');
    await tester.pumpAndSettle();

    final bar = find.byType(BottomNavigationBar);
    expect(bar, findsOneWidget);
    for (final label in ['Beranda', 'Cari', 'Buat Resep', 'Profil']) {
      expect(find.descendant(of: bar, matching: find.text(label)), findsOneWidget);
    }
  });
}
