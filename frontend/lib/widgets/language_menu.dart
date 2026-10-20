import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';
import '../theme/app_theme.dart';
import 'hover_builder.dart';

/// Tombol pilih bahasa di top bar (desktop/tablet): ikon bumi + kode bahasa,
/// membuka menu Bahasa Indonesia / English / Español.
class LanguageMenu extends StatelessWidget {
  const LanguageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleController.instance,
      builder: (context, _) {
        final current = LocaleController.instance.code;
        return PopupMenuButton<String>(
          tooltip: context.tr('lang.tooltip'),
          offset: const Offset(0, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (code) => LocaleController.instance.setLanguage(code),
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            for (final code in AppLocalizations.languages)
              PopupMenuItem<String>(
                value: code,
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: code == current
                          ? const Icon(Icons.check,
                              size: 18, color: AppTheme.orange)
                          : null,
                    ),
                    Text(
                      AppLocalizations.languageNames[code] ?? code,
                      style: TextStyle(
                        fontWeight:
                            code == current ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          child: HoverBuilder(
            builder: (context, hovered) => AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: hovered ? AppTheme.hoverFill : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.outline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    current.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 20, color: AppTheme.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Pilihan bahasa berupa chip (dipakai di dalam Drawer pada layar mobile).
class LanguageChips extends StatelessWidget {
  const LanguageChips({super.key, this.onSelected});

  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleController.instance,
      builder: (context, _) {
        final current = LocaleController.instance.code;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final code in AppLocalizations.languages)
              HoverBuilder(
                builder: (context, hovered) {
                  final selected = code == current;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      LocaleController.instance.setLanguage(code);
                      onSelected?.call();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.orange : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? Colors.transparent
                              : (hovered ? AppTheme.orange : AppTheme.line),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.languageNames[code] ?? code,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : (hovered ? AppTheme.orange : AppTheme.ink),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
