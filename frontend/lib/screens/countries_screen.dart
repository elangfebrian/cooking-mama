import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../router/routes.dart';
import '../theme/app_theme.dart';
import '../widgets/hover_builder.dart';
import '../widgets/page_layout.dart';

/// "Pilih Negara" — PUBLIK. Daftar dikelompokkan per bahasa seperti Cookpad.
class CountriesScreen extends StatelessWidget {
  const CountriesScreen({super.key});

  static const List<(String, List<String>)> _groups = [
    ('English', [
      'India', 'Kenya', 'Nigeria', 'Pakistan', 'South Africa',
      'United Kingdom', 'United States',
    ]),
    ('Español', [
      'Argentina', 'Bolivia', 'Chile', 'Colombia', 'Costa Rica', 'Cuba',
      'Ecuador', 'El Salvador', 'España', 'Estados Unidos', 'Guatemala',
      'Honduras', 'México', 'Nicaragua', 'Panamá', 'Paraguay', 'Perú',
      'Puerto Rico', 'República Dominicana', 'Uruguay', 'Venezuela',
    ]),
    ('Bahasa Indonesia', ['Indonesia']),
    ('ภาษาไทย', ['ไทย']),
    ('Tiếng Việt', ['Việt Nam']),
    ('Bahasa Melayu', ['Malaysia']),
    ('Português', ['Portugal']),
    ('Français', ['France']),
    ('Italiano', ['Italia']),
    ('Magyar', ['Magyarország']),
    ('Ελληνικά', ['Ελλάδα']),
    ('Українська', ['Україна']),
    ('日本語', ['日本']),
    ('繁體中文', ['臺灣']),
    ('العربية', ['السعودية']),
    ('فارسی', ['ایران']),
  ];

  void _select(BuildContext context, String country) {
    if (country == 'Indonesia') {
      context.go(AppRoutes.home);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr('ctry.unavailable', args: {'country': country}),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Title(
      title: context.tr('ctry.tab'),
      color: AppTheme.orange,
      child: PageScroll(
        children: [
          ContentBox(
            maxWidth: 1000,
            verticalPadding: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('ctry.title'),
                  style:
                      const TextStyle(fontSize: 38, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < _groups.length; i++) ...[
                        if (i > 0) const Divider(color: AppTheme.ink, height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _groups[i].$1,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 24),
                                child: Wrap(
                                  spacing: 20,
                                  runSpacing: 8,
                                  children: [
                                    for (final c in _groups[i].$2)
                                      _CountryLink(
                                        name: c,
                                        current: c == 'Indonesia',
                                        onTap: () => _select(context, c),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryLink extends StatelessWidget {
  const _CountryLink({
    required this.name,
    required this.current,
    required this.onTap,
  });

  final String name;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      builder: (context, hovered) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Text(
          name,
          style: TextStyle(
            fontSize: 17,
            fontWeight: current ? FontWeight.w700 : FontWeight.w400,
            color: (hovered || current) ? AppTheme.orange : AppTheme.grey,
            decoration: hovered ? TextDecoration.underline : TextDecoration.none,
            decorationColor: AppTheme.orange,
          ),
        ),
      ),
    );
  }
}
