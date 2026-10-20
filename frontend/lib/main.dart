import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'data/app_state.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_controller.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/web_scroll_behavior.dart';
import 'utils/platform_info.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // URL bersih: /recipe/3-nasi-goreng (bukan /#/recipe/3-nasi-goreng).
  if (kIsWeb) usePathUrlStrategy();

  // Pulihkan sesi login (jika ada) SEBELUM router dibuat, supaya guard
  // langsung membaca status autentikasi yang benar saat halaman di-refresh.
  await AppState.instance.init();

  // Pulihkan bahasa pilihan terakhir (default: Indonesia).
  await LocaleController.instance.init();

  runApp(const CookingMamaApp());
}

class CookingMamaApp extends StatelessWidget {
  const CookingMamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Membangun ulang MaterialApp saat bahasa berganti, sehingga seluruh
    // teks (yang memakai context.tr) langsung berubah tanpa reload.
    return ListenableBuilder(
      listenable: LocaleController.instance,
      builder: (context, _) => MaterialApp.router(
        title: 'Cooking Mama',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        // Mobile: scroll native (bounce iOS / stretch Android). Web: tetap.
        scrollBehavior: AppPlatform.isMobileApp
            ? const MaterialScrollBehavior()
            : const WebScrollBehavior(),
        routerConfig: AppRouter.router,
        locale: LocaleController.instance.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
