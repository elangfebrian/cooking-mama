import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../router/routes.dart';
import '../theme/app_theme.dart';
import 'app_sidebar.dart';
import 'brand_logo.dart';
import 'language_menu.dart';

/// Kerangka halaman KHUSUS aplikasi Android/iOS (dipakai AppShell bila
/// AppPlatform.isMobileApp). Pengganti sidebar + top bar + banner premium:
///
///  +-----------------------------------+
///  | [menu/back]  logo     [bhs][Masuk]|  header ramping
///  +-----------------------------------+
///  |        halaman aktif (scroll)     |
///  +-----------------------------------+
///  | Beranda | Cari | Buat Resep | Profil |  BottomNavigationBar
///  +-----------------------------------+
///
/// Menu sekunder (Negara, Premium, Koleksi, Tersimpan, FAQ...) tetap ada di
/// Drawer yang dibuka dari ikon menu, memakai SidebarContent yang sama
/// dengan versi web.
class MobileShell extends StatefulWidget {
  const MobileShell({super.key, required this.location, required this.child});

  final Uri location;
  final Widget child;

  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Tab terakhir yang aktif; dipakai menyorot tab saat membuka halaman
  /// non-tab (detail resep, login, dst).
  int _lastTab = 0;

  static const List<String> _tabs = [
    AppRoutes.home,
    AppRoutes.search,
    AppRoutes.create,
    AppRoutes.profile,
  ];

  int? _tabIndexOf(String path) {
    final i = _tabs.indexOf(path);
    return i < 0 ? null : i;
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(_tabs[_lastTab]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.location.path;
    final tab = _tabIndexOf(path);
    if (tab != null) _lastTab = tab;
    final isRoot = tab != null;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return PopScope(
      // Tombol back Android: dari tab/halaman lain kembali dulu ke Beranda;
      // baru dari Beranda aplikasi ditutup.
      canPop: path == AppRoutes.home,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: Drawer(
          width: 290,
          backgroundColor: Colors.white,
          child: SafeArea(
            child: SidebarContent(
              location: widget.location,
              showLanguage: true,
              onNavigate: () => _scaffoldKey.currentState?.closeDrawer(),
            ),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: GestureDetector(
            // Ketuk area kosong -> keyboard tertutup.
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  location: widget.location,
                  isRoot: isRoot,
                  onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                  onBack: _goBack,
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ),
        // Disembunyikan saat keyboard terbuka agar tidak menyita ruang form.
        bottomNavigationBar: keyboardOpen
            ? null
            : DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppTheme.line)),
                ),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  currentIndex: _lastTab,
                  selectedItemColor: AppTheme.orange,
                  unselectedItemColor: AppTheme.grey,
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  onTap: (i) => context.go(_tabs[i]),
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.home_outlined),
                      activeIcon: const Icon(Icons.home),
                      label: context.tr('mnav.home'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.search),
                      label: context.tr('mnav.search'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.add_circle_outline),
                      activeIcon: const Icon(Icons.add_circle),
                      label: context.tr('mnav.create'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.person_outline),
                      activeIcon: const Icon(Icons.person),
                      label: context.tr('mnav.profile'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.location,
    required this.isRoot,
    required this.onMenu,
    required this.onBack,
  });

  final Uri location;
  final bool isRoot;
  final VoidCallback onMenu;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final loggedIn = AppState.instance.isLoggedIn;
        return Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
          child: SizedBox(
            height: 48,
            child: Row(
              children: [
                if (isRoot)
                  IconButton(
                    tooltip: context.tr('nav.menu'),
                    icon: const Icon(Icons.menu),
                    onPressed: onMenu,
                  )
                else
                  IconButton(
                    tooltip: context.tr('nav.back'),
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBack,
                  ),
                const Flexible(child: BrandLogo(size: 30)),
                const Spacer(),
                const LanguageMenu(),
                const SizedBox(width: 4),
                if (!loggedIn)
                  OutlinedButton(
                    onPressed: () => context.go(
                      AppRoutes.loginLocation(from: location.toString()),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: Text(context.tr('action.login')),
                  )
                else
                  IconButton(
                    tooltip: context.tr('account.saved'),
                    icon: const Icon(Icons.bookmark_border),
                    onPressed: () => context.go(AppRoutes.saved),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
