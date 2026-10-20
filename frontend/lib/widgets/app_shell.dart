import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../utils/platform_info.dart';
import 'app_sidebar.dart';
import 'app_top_bar.dart';
import 'mobile_shell.dart';
import 'promo_bar.dart';

/// Kerangka semua halaman, meniru Cookpad Web:
///
///  ┌─────────┬─────────────────────────────┐
///  │ sidebar │  top bar (Masuk / Tulis)    │
///  │ (logo,  ├─────────────────────────────┤
///  │  menu)  │  halaman aktif (scroll)     │
///  └─────────┴─────────────────────────────┘
///  [ banner premium di dasar layar            ]
///
///  * lebar >= 900 : sidebar tetap; otomatis minimize di bawah 1180,
///    dan bisa di-toggle manual dengan tombol « / ».
///  * lebar <  900 : sidebar menjadi Drawer yang dibuka dari hamburger.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.location, required this.child});

  final Uri location;
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Pilihan manual pengguna; null = ikuti lebar layar.
  bool? _userCollapsed;

  @override
  Widget build(BuildContext context) {
    // Aplikasi Android/iOS: bottom navigation. Web tidak melewati cabang ini.
    if (AppPlatform.isMobileApp) {
      return MobileShell(location: widget.location, child: widget.child);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final useDrawer = width < Breakpoints.sidebarMin;
        final collapsed = _userCollapsed ?? width < Breakpoints.sidebarAutoCollapse;
        final gap = useDrawer ? 0.0 : 12.0;

        final panel = Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(useDrawer ? 0 : 16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTopBar(
                location: widget.location,
                showMenuButton: useDrawer,
                onMenu: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              Expanded(child: widget.child),
            ],
          ),
        );

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppTheme.shellBackground,
          drawer: useDrawer
              ? Drawer(
                  width: 290,
                  backgroundColor: Colors.white,
                  child: SafeArea(
                    child: SidebarContent(
                      location: widget.location,
                      showLanguage: true,
                      onNavigate: () => _scaffoldKey.currentState?.closeDrawer(),
                    ),
                  ),
                )
              : null,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(gap),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!useDrawer) ...[
                        AppSidebar(
                          location: widget.location,
                          collapsed: collapsed,
                          onToggle: () => setState(() => _userCollapsed = !collapsed),
                        ),
                        SizedBox(width: gap),
                      ],
                      Expanded(child: panel),
                    ],
                  ),
                ),
              ),
              PromoBar(compact: useDrawer),
            ],
          ),
        );
      },
    );
  }
}
