import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../router/routes.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/page_layout.dart';
import '../widgets/recipe_grid.dart';

/// Profil — PRIVAT (dijaga guard di app_router.dart).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _logout(BuildContext context) {
    // Pindah ke beranda DULU, baru logout, supaya guard tidak sempat
    // mengarahkan pengguna ke halaman login.
    context.go(AppRoutes.home);
    AppState.instance.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Title(
      title: context.tr('prof.tab'),
      color: AppTheme.orange,
      child: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final s = AppState.instance;
          final mine = s.myRecipes;

          final stats = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Stat(value: '${mine.length}', label: context.tr('prof.recipes')),
              const SizedBox(width: 32),
              _Stat(
                value: '${s.favorites.length}',
                label: context.tr('prof.saved'),
              ),
              const SizedBox(width: 32),
              _Stat(value: '0', label: context.tr('prof.followers')),
            ],
          );

          final logoutButton = OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, size: 18),
            label: Text(context.tr('account.logout')),
          );

          return PageScroll(
            children: [
              ContentBox(
                maxWidth: 1000,
                verticalPadding: 32,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LayoutBuilder(
                      builder: (context, c) {
                        final avatar = CircleAvatar(
                          radius: 44,
                          backgroundColor: AppTheme.orangeSoft,
                          child: Text(
                            s.userName.isEmpty
                                ? '?'
                                : s.userName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.orange,
                            ),
                          ),
                        );
                        final name = Text(
                          s.userName,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        );

                        if (c.maxWidth >= 600) {
                          return Row(
                            children: [
                              avatar,
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    name,
                                    const SizedBox(height: 12),
                                    stats,
                                  ],
                                ),
                              ),
                              logoutButton,
                            ],
                          );
                        }
                        return Column(
                          children: [
                            avatar,
                            const SizedBox(height: 12),
                            name,
                            const SizedBox(height: 16),
                            stats,
                            const SizedBox(height: 16),
                            logoutButton,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(top: 28, bottom: 20),
                      child: Text(
                        context.tr('prof.mine'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (mine.isEmpty)
                      EmptyState(
                        icon: Icons.edit_note,
                        title: context.tr('prof.empty.title'),
                        message: context.tr('prof.empty.msg'),
                        actionLabel: context.tr('action.write'),
                        onAction: () => context.go(AppRoutes.create),
                      )
                    else
                      RecipeGrid(recipes: mine),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          Text(label, style: const TextStyle(color: AppTheme.grey)),
        ],
      );
}
