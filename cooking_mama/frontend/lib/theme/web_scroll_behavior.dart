import 'package:flutter/material.dart';

/// Perilaku scroll ala website:
///  * scroll wheel / trackpad bekerja normal,
///  * scrollbar vertikal selalu tersedia (bukan hanya di desktop native),
///  * tanpa efek overscroll glow/stretch/bounce khas mobile,
///  * mouse TIDAK men-drag konten (seperti website biasa; drag hanya untuk
///    layar sentuh, stylus, dan trackpad).
class WebScrollBehavior extends MaterialScrollBehavior {
  const WebScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    final vertical = details.direction == AxisDirection.down ||
        details.direction == AxisDirection.up;
    if (!vertical) return child;
    return Scrollbar(
      controller: details.controller,
      interactive: true,
      child: child,
    );
  }
}
