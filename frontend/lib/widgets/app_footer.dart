import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/info_pages.dart';
import '../l10n/app_localizations.dart';
import '../router/routes.dart';
import '../theme/app_theme.dart';
import 'hover_builder.dart';
import 'hover_link.dart';
import 'page_layout.dart';
import 'social_icons.dart';

/// Footer ala Cookpad, tampil di dasar setiap halaman (di dalam area scroll):
/// Tentang Kami, Komunitas, Selengkapnya, sosial media, unduh aplikasi,
/// hak cipta, dan ilustrasi sayuran.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  static const _countries = [
    'Indonesia',
    'United States',
    'United Kingdom',
    'España',
    'India',
    'Malaysia',
    'Việt Nam',
    'ไทย',
    'Portugal',
    'France',
    '日本',
  ];

  @override
  Widget build(BuildContext context) {
    const heading = TextStyle(fontSize: 19, fontWeight: FontWeight.w700);
    const body = TextStyle(fontSize: 16, height: 1.75, color: AppTheme.ink);
    const bold = TextStyle(fontWeight: FontWeight.w700);
    const linkStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ContentBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('footer.about'), style: heading),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: body,
                    children: [
                      TextSpan(text: context.tr('footer.mission1')),
                      TextSpan(
                        text: context.tr('footer.mission.bold1'),
                        style: bold,
                      ),
                      TextSpan(text: context.tr('footer.mission2')),
                      TextSpan(
                        text: context.tr('footer.mission.bold2'),
                        style: bold,
                      ),
                      TextSpan(text: context.tr('footer.mission3')),
                    ],
                  ),
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    HoverLink(
                      text: context.tr('footer.premiumLink'),
                      underlined: true,
                      color: AppTheme.ink,
                      style: body.copyWith(fontWeight: FontWeight.w700),
                      onTap: () =>
                          context.go(AppRoutes.infoLocation('premium')),
                    ),
                    Text(context.tr('footer.premiumAfter'), style: body),
                  ],
                ),
                const SizedBox(height: 28),
                Text(context.tr('footer.community'), style: heading),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 22,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final c in _countries)
                      HoverLink(
                        text: c,
                        underlined: true,
                        color: AppTheme.ink,
                        style: linkStyle,
                        onTap: () => context.go(AppRoutes.countries),
                      ),
                    HoverBuilder(
                      builder: (context, hovered) => GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => context.go(AppRoutes.countries),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: hovered
                                ? const Color(0xFFE6E6E6)
                                : AppTheme.hoverFill,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            context.tr('footer.seeAll'),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(context.tr('footer.more'), style: heading),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    for (final slug in infoSlugs)
                      HoverLink(
                        text: context.tr('info.$slug.title'),
                        underlined: true,
                        color: AppTheme.ink,
                        style: linkStyle.copyWith(fontSize: 17),
                        onTap: () => context.go(AppRoutes.infoLocation(slug)),
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                const SocialIcons(),
                const SizedBox(height: 28),
                Text(context.tr('footer.download'), style: heading),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StoreBadge(
                      icon: Icons.play_arrow_rounded,
                      iconColor: const Color(0xFF34D17B),
                      small: context.tr('badge.google.small'),
                      big: 'Google Play',
                    ),
                    _StoreBadge(
                      icon: Icons.apple,
                      iconColor: Colors.white,
                      small: context.tr('badge.apple.small'),
                      big: 'App Store',
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Center(
                  child: Text(
                    context.tr('footer.copyright'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.grey.withAlpha(230)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(
            height: 120,
            child: CustomPaint(painter: _VeggiePainter()),
          ),
        ],
      ),
    );
  }
}

/// Tombol toko aplikasi (hiasan; aplikasi mobile belum dirilis).
class _StoreBadge extends StatelessWidget {
  const _StoreBadge({
    required this.icon,
    required this.iconColor,
    required this.small,
    required this.big,
  });

  final IconData icon;
  final Color iconColor;
  final String small;
  final String big;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      builder: (context, hovered) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('footer.appSoon'))),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: hovered ? const Color(0xFF2B2B2B) : Colors.black,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF7A7A7A)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 30),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    small,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    big,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ilustrasi sayuran di dasar footer (paprika, tomat, wortel, labu, lemon),
/// digambar dengan CustomPainter dan diulang selebar panel.
class _VeggiePainter extends CustomPainter {
  const _VeggiePainter();

  static const _yellow = Color(0xFFFBB827);
  static const _orange = Color(0xFFF5711F);
  static const _deepOrange = Color(0xFFE8590C);
  static const _green = Color(0xFF3F7D20);
  static const _cream = Color(0xFFFFF1D6);

  @override
  void paint(Canvas canvas, Size size) {
    const step = 118.0;
    final count = (size.width / step).ceil() + 1;
    final base = size.height + 14; // sebagian tubuh sayur terpotong di bawah
    final fill = Paint()..style = PaintingStyle.fill;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < count; i++) {
      final x = i * step + step / 2;
      switch (i % 5) {
        case 0: // paprika kuning
          fill.color = _yellow;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(x, base - 52), width: 78, height: 104),
              const Radius.circular(38),
            ),
            fill,
          );
          stroke.color = _orange;
          canvas.drawLine(Offset(x - 8, base - 90), Offset(x + 6, base - 24), stroke);
          fill.color = _green;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(x - 16, base - 108), width: 10, height: 22),
              const Radius.circular(4),
            ),
            fill,
          );
          break;
        case 1: // tomat
          fill.color = _orange;
          canvas.drawCircle(Offset(x, base - 28), 36, fill);
          stroke.color = _green;
          for (final dx in [-12.0, 0.0, 12.0]) {
            canvas.drawLine(
              Offset(x, base - 62),
              Offset(x + dx, base - 74),
              stroke,
            );
          }
          break;
        case 2: // wortel dengan daun
          fill.color = _deepOrange;
          canvas.drawPath(
            Path()
              ..moveTo(x - 26, base)
              ..lineTo(x - 12, base - 96)
              ..quadraticBezierTo(x, base - 108, x + 12, base - 96)
              ..lineTo(x + 26, base)
              ..close(),
            fill,
          );
          fill.color = _green;
          canvas.drawOval(
            Rect.fromCenter(center: Offset(x - 8, base - 118), width: 18, height: 40),
            fill,
          );
          canvas.drawOval(
            Rect.fromCenter(center: Offset(x + 10, base - 112), width: 16, height: 34),
            fill,
          );
          break;
        case 3: // irisan labu
          fill.color = _orange;
          canvas.drawPath(
            Path()
              ..moveTo(x - 52, base - 6)
              ..quadraticBezierTo(x - 40, base - 74, x + 52, base - 62)
              ..lineTo(x + 52, base)
              ..close(),
            fill,
          );
          fill.color = _cream;
          for (final dx in [-22.0, -4.0, 14.0, 32.0]) {
            canvas.drawOval(
              Rect.fromCenter(center: Offset(x + dx, base - 30), width: 8, height: 14),
              fill,
            );
          }
          break;
        default: // lemon
          fill.color = _yellow;
          canvas.drawOval(
            Rect.fromCenter(center: Offset(x, base - 34), width: 84, height: 76),
            fill,
          );
          fill.color = const Color(0xFFF2A516);
          for (final dx in [-16.0, 2.0, 18.0]) {
            canvas.drawCircle(Offset(x + dx, base - 38 + dx / 4), 2.2, fill);
          }
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _VeggiePainter oldDelegate) => false;
}
