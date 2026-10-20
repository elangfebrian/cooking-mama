import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../router/routes.dart';
import '../theme/app_theme.dart';
import 'brand_logo.dart';
import 'hover_builder.dart';
import 'language_menu.dart';

/// Bilah atas di dalam panel utama: tombol kembali / hamburger di kiri,
/// "Masuk" + "Tulis Resep" (atau menu profil) di kanan, seperti Cookpad.
/// Isi halaman men-scroll di BAWAH bilah ini.
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.location,
    required this.showMenuButton,
    this.onMenu,
  });

  final Uri location;
  final bool showMenuButton;
  final VoidCallback? onMenu;

  bool get _showBack =>
      !showMenuButton &&
      location.path != AppRoutes.home &&
      location.path != AppRoutes.search;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;

        return Padding(
          padding:
              EdgeInsets.fromLTRB(compact ? 12 : 24, 12, compact ? 12 : 24, 12),
          child: SizedBox(
            height: 48,
            child: Row(
              children: [
                if (showMenuButton) ...[
                  IconButton(
                    tooltip: context.tr('nav.menu'),
                    icon: const Icon(Icons.menu),
                    onPressed: onMenu,
                  ),
                  const SizedBox(width: 4),
                  const Flexible(child: BrandLogo(size: 32)),
                ] else if (_showBack)
                  const _BackButton(),
                const Spacer(),
                _Actions(location: location, compact: compact),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.tr('nav.back'),
      child: HoverBuilder(
        builder: (context, hovered) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: hovered ? const Color(0xFFEAEAEA) : AppTheme.hoverFill,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chevron_left, size: 28),
          ),
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.location, required this.compact});

  final Uri location;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final loggedIn = AppState.instance.isLoggedIn;

        final writeButton = compact
            ? ElevatedButton(
                onPressed: () => context.go(AppRoutes.create),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(Icons.add),
              )
            : ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.create),
                icon: const Icon(Icons.add, size: 22),
                label: Text(context.tr('action.write')),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pada layar sempit, pilihan bahasa ada di dalam Drawer.
            if (!compact) ...[
              const LanguageMenu(),
              const SizedBox(width: 12),
            ],
            if (!loggedIn) ...[
              OutlinedButton(
                onPressed: () => context.go(
                  AppRoutes.loginLocation(from: location.toString()),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(0, compact ? 44 : 48),
                  padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24),
                  side: const BorderSide(color: AppTheme.outline),
                  textStyle: TextStyle(
                    fontSize: compact ? 15 : 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Text(context.tr('action.login')),
              ),
              SizedBox(width: compact ? 8 : 12),
            ],
            writeButton,
            if (loggedIn) ...[
              SizedBox(width: compact ? 8 : 12),
              _ProfileMenu(compact: compact),
            ],
          ],
        );
      },
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final name = AppState.instance.userName;
    final initial = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();

    return PopupMenuButton<String>(
      tooltip: context.tr('account.tooltip'),
      offset: const Offset(0, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        switch (value) {
          case 'profile':
            context.go(AppRoutes.profile);
            break;
          case 'saved':
            context.go(AppRoutes.saved);
            break;
          case 'logout':
            // Pindah ke beranda DULU, baru logout, supaya guard tidak
            // sempat melempar pengguna ke halaman login.
            context.go(AppRoutes.home);
            AppState.instance.logout();
            break;
        }
      },
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'profile',
          child: _MenuRow(
            icon: Icons.person_outline,
            label: context.tr('account.profile'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'saved',
          child: _MenuRow(
            icon: Icons.bookmark_border,
            label: context.tr('account.saved'),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: _MenuRow(
            icon: Icons.logout,
            label: context.tr('account.logout'),
          ),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.orangeSoft,
            child: Text(
              initial,
              style: const TextStyle(
                color: AppTheme.orange,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
          const Icon(Icons.keyboard_arrow_down, color: AppTheme.grey),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.grey),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}
