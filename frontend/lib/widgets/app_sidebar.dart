import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/app_state.dart';
import '../router/routes.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'brand_logo.dart';
import 'hover_builder.dart';
import 'language_menu.dart';

/// Sidebar kiri ala Cookpad (desktop/tablet).
///
/// Lebar beranimasi halus antara mode penuh (260) dan minimize (80).
/// Isi sidebar SELALU dilayout selebar 260 lalu dipotong (ClipRRect), jadi
/// saat menyempit tidak ada overflow dan ikon tetap diam di tempatnya;
/// hanya label yang memudar.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.location,
    required this.collapsed,
    required this.onToggle,
  });

  static const double expandedWidth = 260;
  static const double collapsedWidth = 80;

  final Uri location;
  final bool collapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOutCubic,
      width: collapsed ? collapsedWidth : expandedWidth,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: OverflowBox(
        alignment: Alignment.topLeft,
        minWidth: expandedWidth,
        maxWidth: expandedWidth,
        child: SidebarContent(
          location: location,
          collapsed: collapsed,
          onToggle: onToggle,
        ),
      ),
    );
  }
}

/// Isi sidebar. Dipakai juga di dalam Drawer pada layar mobile.
class SidebarContent extends StatelessWidget {
  const SidebarContent({
    super.key,
    required this.location,
    this.collapsed = false,
    this.onToggle,
    this.onNavigate,
    this.showLanguage = false,
  });

  final Uri location;
  final bool collapsed;
  final VoidCallback? onToggle;

  /// Tampilkan pilihan bahasa di bagian bawah (dipakai di Drawer mobile).
  final bool showLanguage;

  /// Dipanggil setelah item dipilih (mis. menutup drawer).
  final VoidCallback? onNavigate;

  void _go(BuildContext context, String target) {
    context.go(target);
    onNavigate?.call();
  }

  @override
  Widget build(BuildContext context) {
    final path = location.path;
    const duration = Duration(milliseconds: 200);

    return SingleChildScrollView(
      primary: false, // jangan berebut PrimaryScrollController dengan halaman
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- Header: logo + tombol minimize ----
          SizedBox(
            height: 56,
            child: Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: HoverBuilder(
                      builder: (context, _) => GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _go(context, AppRoutes.home),
                        child: BrandLogo(
                            size: 36, labelOpacity: collapsed ? 0 : 1),
                      ),
                    ),
                  ),
                ),
                if (onToggle != null)
                  AnimatedOpacity(
                    duration: duration,
                    opacity: collapsed ? 0 : 1,
                    child: IgnorePointer(
                      ignoring: collapsed,
                      child: _ToggleButton(collapsed: false, onTap: onToggle!),
                    ),
                  ),
              ],
            ),
          ),
          // Tombol "perluas" muncul di bawah logo saat sidebar diminimize.
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: (collapsed && onToggle != null)
                ? Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _ToggleButton(collapsed: true, onTap: onToggle!),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: 20),

          // ---- Menu utama ----
          _NavItem(
            icon: Icons.search,
            label: context.tr('nav.search'),
            collapsed: collapsed,
            selected: path == AppRoutes.home || path == AppRoutes.search,
            onTap: () => _go(context, AppRoutes.home),
          ),
          _NavItem(
            icon: Icons.workspace_premium_outlined,
            label: context.tr('nav.premium'),
            collapsed: collapsed,
            selected: path == AppRoutes.infoLocation('premium'),
            onTap: () => _go(context, AppRoutes.infoLocation('premium')),
          ),
          _NavItem(
            icon: Icons.military_tech_outlined,
            label: context.tr('nav.cookTogether'),
            collapsed: collapsed,
            selected: path == AppRoutes.infoLocation('posting-bareng'),
            onTap: () => _go(context, AppRoutes.infoLocation('posting-bareng')),
          ),
          _NavItem(
            icon: Icons.public,
            label: context.tr('nav.countries'),
            collapsed: collapsed,
            selected: path == AppRoutes.countries,
            onTap: () => _go(context, AppRoutes.countries),
          ),
          const SizedBox(height: 16),

          // ---- Koleksi resep ----
          _NavItem(
            icon: Icons.collections_bookmark_outlined,
            label: context.tr('nav.collection'),
            collapsed: collapsed,
            strong: true,
            selected: path == AppRoutes.saved,
            onTap: () => _go(context, AppRoutes.saved),
          ),
          AnimatedOpacity(
            duration: duration,
            opacity: collapsed ? 0 : 1,
            child: IgnorePointer(
              ignoring: collapsed,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: _CollectionHint(onNavigate: onNavigate),
              ),
            ),
          ),
          if (showLanguage) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                context.tr('lang.label'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LanguageChips(onSelected: onNavigate),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({required this.collapsed, required this.onTap});

  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message:
          collapsed ? context.tr('nav.expand') : context.tr('nav.collapse'),
      child: HoverBuilder(
        builder: (context, hovered) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: hovered ? AppTheme.hoverFill : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              collapsed
                  ? Icons.keyboard_double_arrow_right
                  : Icons.keyboard_double_arrow_left,
              color: AppTheme.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.collapsed,
    required this.selected,
    required this.onTap,
    this.strong = false,
  });

  final IconData icon;
  final String label;
  final bool collapsed;
  final bool selected;
  final bool strong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final item = HoverBuilder(
      builder: (context, hovered) {
        final Color color = selected
            ? AppTheme.orange
            : (strong ? AppTheme.ink : AppTheme.grey);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: hovered ? AppTheme.hoverFill : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(width: 16),
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: collapsed ? 0 : 1,
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!collapsed) return item;
    return Tooltip(
      message: label,
      waitDuration: const Duration(milliseconds: 300),
      child: item,
    );
  }
}

/// Teks di bawah "Koleksi Resep": ajakan masuk untuk tamu, ringkasan untuk
/// pengguna yang sudah login.
class _CollectionHint extends StatefulWidget {
  const _CollectionHint({this.onNavigate});

  final VoidCallback? onNavigate;

  @override
  State<_CollectionHint> createState() => _CollectionHintState();
}

class _CollectionHintState extends State<_CollectionHint> {
  late final TapGestureRecognizer _tap = TapGestureRecognizer()..onTap = _open;

  void _open() {
    final loggedIn = AppState.instance.isLoggedIn;
    context.go(
      loggedIn
          ? AppRoutes.saved
          : AppRoutes.loginLocation(from: AppRoutes.saved),
    );
    widget.onNavigate?.call();
  }

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(fontSize: 15, height: 1.45, color: AppTheme.ink);
    final link = base.copyWith(decoration: TextDecoration.underline);

    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final loggedIn = AppState.instance.isLoggedIn;
        final count = AppState.instance.favorites.length;
        return Text.rich(
          TextSpan(
            style: base,
            children: loggedIn
                ? [
                    TextSpan(
                      text: context.tr('hint.user', args: {'n': count}),
                    ),
                    TextSpan(
                      text: context.tr('hint.user.link'),
                      style: link,
                      recognizer: _tap,
                      mouseCursor: SystemMouseCursors.click,
                    ),
                  ]
                : [
                    TextSpan(text: context.tr('hint.guest.before')),
                    TextSpan(
                      text: context.tr('hint.guest.link'),
                      style: link,
                      recognizer: _tap,
                      mouseCursor: SystemMouseCursors.click,
                    ),
                    TextSpan(text: context.tr('hint.guest.after')),
                  ],
          ),
        );
      },
    );
  }
}
