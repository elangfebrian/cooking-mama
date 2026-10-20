import 'package:flutter/material.dart';

/// Deretan logo media sosial di footer, digambar dengan CustomPainter
/// (tanpa file gambar/paket tambahan).
class SocialIcons extends StatelessWidget {
  const SocialIcons({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final Color mono = dark ? Colors.white : Colors.black;

    Widget slot(Widget child) => Padding(
          padding: const EdgeInsets.only(right: 14),
          child: SizedBox(width: 32, height: 32, child: Center(child: child)),
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        slot(Icon(Icons.facebook, size: 30, color: mono)), // sudah benar
        slot(const _Logo(painter: _InstagramPainter(), size: 28)),
        slot(_Logo(painter: _XPainter(mono), size: 24)),
        slot(const _Logo(painter: _YouTubePainter(), size: 32, aspect: 0.72)),
        slot(_Logo(painter: _TikTokPainter(mono), size: 28)),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.painter, required this.size, this.aspect = 1});

  final CustomPainter painter;
  final double size;
  final double aspect;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size * aspect), painter: painter);
}

// ---------------------------------------------------------------------------
// Instagram: kotak membulat bergradasi + kamera putih
// ---------------------------------------------------------------------------
class _InstagramPainter extends CustomPainter {
  const _InstagramPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final rect = Offset.zero & size;
    const gradient = RadialGradient(
      center: Alignment(-0.4, 1.14),
      radius: 1.15,
      colors: [
        Color(0xFFFED576),
        Color(0xFFF47133),
        Color(0xFFBC3081),
        Color(0xFF4C63D2),
      ],
      stops: [0.0, 0.26, 0.61, 1.0],
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(s * 0.27)),
      Paint()..shader = gradient.createShader(rect),
    );

    final line = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.075;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.2, s * 0.2, s * 0.6, s * 0.6),
        Radius.circular(s * 0.17),
      ),
      line,
    );
    canvas.drawCircle(Offset(s / 2, s / 2), s * 0.14, line);
    canvas.drawCircle(
      Offset(s * 0.69, s * 0.31),
      s * 0.045,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// X: path resmi (viewBox 24x24), hitam di mode terang / putih di mode gelap
// ---------------------------------------------------------------------------
class _XPainter extends CustomPainter {
  const _XPainter(this.color);

  final Color color;

  static const String _d =
      'M18.901 1.153h3.68l-8.04 9.19L24 22.846h-7.406l-5.8-7.584-6.638 7.584'
      'H.474l8.6-9.83L0 1.154h7.594l5.243 6.932ZM17.61 20.644h2.039L6.486 3.24'
      'H4.298Z';

  @override
  void paint(Canvas canvas, Size size) {
    final path = _parseLinePath(_d)..fillType = PathFillType.evenOdd;
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _XPainter old) => old.color != color;
}

/// Parser kecil untuk path SVG yang hanya berisi garis lurus
/// (perintah M m L l H h V v Z z).
Path _parseLinePath(String d) {
  final tokens = RegExp(r'[A-Za-z]|-?\d*\.?\d+')
      .allMatches(d)
      .map((m) => m.group(0)!)
      .toList();
  final path = Path();
  var i = 0;
  var cmd = '';
  double x = 0, y = 0, startX = 0, startY = 0;

  double n(int k) => double.parse(tokens[k]);
  bool isCommand(String t) => RegExp(r'^[A-Za-z]$').hasMatch(t);

  while (i < tokens.length) {
    final t = tokens[i];
    if (isCommand(t)) {
      cmd = t;
      i++;
      if (cmd == 'Z' || cmd == 'z') {
        path.close();
        x = startX;
        y = startY;
      }
      continue;
    }
    switch (cmd) {
      case 'M':
        x = n(i);
        y = n(i + 1);
        i += 2;
        path.moveTo(x, y);
        startX = x;
        startY = y;
        cmd = 'L';
        break;
      case 'm':
        x += n(i);
        y += n(i + 1);
        i += 2;
        path.moveTo(x, y);
        startX = x;
        startY = y;
        cmd = 'l';
        break;
      case 'L':
        x = n(i);
        y = n(i + 1);
        i += 2;
        path.lineTo(x, y);
        break;
      case 'l':
        x += n(i);
        y += n(i + 1);
        i += 2;
        path.lineTo(x, y);
        break;
      case 'H':
        x = n(i);
        i += 1;
        path.lineTo(x, y);
        break;
      case 'h':
        x += n(i);
        i += 1;
        path.lineTo(x, y);
        break;
      case 'V':
        y = n(i);
        i += 1;
        path.lineTo(x, y);
        break;
      case 'v':
        y += n(i);
        i += 1;
        path.lineTo(x, y);
        break;
      default:
        i++; // perintah tak dikenal: lewati angka agar tidak loop selamanya
    }
  }
  return path;
}

// ---------------------------------------------------------------------------
// YouTube: persegi panjang membulat merah + segitiga putih
// ---------------------------------------------------------------------------
class _YouTubePainter extends CustomPainter {
  const _YouTubePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(h * 0.3)),
      Paint()..color = const Color(0xFFFF0000),
    );
    final cx = w / 2;
    final cy = h / 2;
    canvas.drawPath(
      Path()
        ..moveTo(cx - h * 0.17, cy - h * 0.26)
        ..lineTo(cx - h * 0.17, cy + h * 0.26)
        ..lineTo(cx + h * 0.28, cy)
        ..close(),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// TikTok: not musik tiga lapis (cyan, merah muda, hitam/putih)
// ---------------------------------------------------------------------------
class _TikTokPainter extends CustomPainter {
  const _TikTokPainter(this.mainColor);

  final Color mainColor;

  static const Color _cyan = Color(0xFF25F4EE);
  static const Color _pink = Color(0xFFFE2C55);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    _note(canvas, const Offset(-0.9, -0.8), _cyan);
    _note(canvas, const Offset(0.9, 0.8), _pink);
    _note(canvas, Offset.zero, mainColor);
    canvas.restore();
  }

  void _note(Canvas canvas, Offset shift, Color color) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.3;

    // batang
    canvas.drawLine(
      Offset(14.4 + shift.dx, 3.2 + shift.dy),
      Offset(14.4 + shift.dx, 16.4 + shift.dy),
      stroke,
    );
    // lingkaran not
    canvas.drawCircle(Offset(10.6 + shift.dx, 16.6 + shift.dy), 3.7, stroke);
    // bendera
    final flag = Path()
      ..moveTo(14.4 + shift.dx, 3.2 + shift.dy)
      ..cubicTo(
        14.8 + shift.dx,
        6.0 + shift.dy,
        17.0 + shift.dx,
        7.7 + shift.dy,
        20.6 + shift.dx,
        7.9 + shift.dy,
      );
    canvas.drawPath(flag, stroke);
  }

  @override
  bool shouldRepaint(covariant _TikTokPainter old) =>
      old.mainColor != mainColor;
}
