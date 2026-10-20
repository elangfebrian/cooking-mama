import 'package:flutter/material.dart';

/// Membungkus widget dengan MouseRegion dan memberi tahu builder apakah
/// kursor sedang berada di atasnya (hover). Kursor otomatis jadi pointer.
class HoverBuilder extends StatefulWidget {
  const HoverBuilder({
    super.key,
    required this.builder,
    this.cursor = SystemMouseCursors.click,
  });

  final Widget Function(BuildContext context, bool hovered) builder;
  final MouseCursor cursor;

  @override
  State<HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool _hovered = false;

  void _set(bool value) {
    if (_hovered != value) setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.cursor,
      onEnter: (_) => _set(true),
      onExit: (_) => _set(false),
      child: widget.builder(context, _hovered),
    );
  }
}
