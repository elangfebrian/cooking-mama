import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../router/routes.dart';
import '../theme/app_theme.dart';

/// Kolom pencarian besar + tombol "Cari" oranye (seperti beranda Cookpad).
/// Kata kunci disinkronkan dengan URL (`/search?q=...`).
class SearchBox extends StatefulWidget {
  const SearchBox({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialQuery);
  final FocusNode _focus = FocusNode();
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant SearchBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery &&
        !_focus.hasFocus &&
        _controller.text != widget.initialQuery) {
      _controller.text = widget.initialQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit([String? _]) {
    context.go(AppRoutes.searchLocation(query: _controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    final Color border = focused
        ? AppTheme.orange
        : (_hovered ? AppTheme.grey : AppTheme.outline);

    return Row(
      children: [
        Expanded(
          child: MouseRegion(
            cursor: SystemMouseCursors.text,
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: border, width: focused ? 1.5 : 1),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 14),
                    child: Icon(Icons.search, size: 24, color: AppTheme.ink),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _submit,
                      style: const TextStyle(fontSize: 17),
                      decoration: InputDecoration(
                        hintText: context.tr('search.hint'),
                        filled: false,
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 52),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          child: Text(context.tr('nav.search')),
        ),
      ],
    );
  }
}
