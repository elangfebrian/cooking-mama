import 'package:flutter/material.dart';

import '../utils/platform_info.dart';
import '../utils/responsive.dart';
import 'app_footer.dart';

/// Membatasi lebar konten (default 1200px), memusatkannya, dan memberi padding
/// horizontal responsif. Latar penuh (mis. hero) ditaruh DI LUAR ContentBox.
class ContentBox extends StatelessWidget {
  const ContentBox({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
    this.verticalPadding = 0,
  });

  final Widget child;
  final double maxWidth;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pad = Breakpoints.pagePadding(constraints.maxWidth);
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: pad,
                vertical: verticalPadding,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Kerangka halaman: satu area scroll vertikal untuk seluruh halaman
/// (seperti website), dengan footer yang menempel di dasar layar bila
/// konten pendek.
class PageScroll extends StatelessWidget {
  const PageScroll({
    super.key,
    required this.children,
    this.showFooter = true,
  });

  final List<Widget> children;
  final bool showFooter;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, viewport) {
        final mobile = AppPlatform.isMobileApp;
        return SingleChildScrollView(
          // Mobile: keyboard menutup sendiri saat daftar digeser.
          keyboardDismissBehavior: mobile
              ? ScrollViewKeyboardDismissBehavior.onDrag
              : ScrollViewKeyboardDismissBehavior.manual,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: viewport.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
                // Footer web (tautan panjang) disembunyikan di app mobile.
                if (showFooter && !mobile) const AppFooter(),
              ],
            ),
          ),
        );
      },
    );
  }
}
