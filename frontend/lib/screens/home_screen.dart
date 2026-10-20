import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../router/routes.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/category_chips.dart';
import '../widgets/empty_state.dart';
import '../widgets/hover_builder.dart';
import '../widgets/page_layout.dart';
import '../widgets/popular_tile.dart';
import '../widgets/recipe_grid.dart';
import '../widgets/search_box.dart';
import '../widgets/section_header.dart';

/// Beranda — PUBLIK. Tata letak mengikuti beranda Cookpad:
/// logo besar -> kolom Cari -> banner -> Pencarian Populer -> resep.
/// Kategori disimpan di URL (`/?cat=Ayam`).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.category = 'Semua'});

  final String category;

  static String _updatedTime() {
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return '$hh.$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Title(
      title: context.tr('home.tab'),
      color: AppTheme.orange,
      child: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final all = AppState.instance.recipes;
          final filtered = category == 'Semua'
              ? all
              : all.where((r) => r.category == category).toList();

          return PageScroll(
            children: [
              ContentBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    const Center(child: BrandLogo(size: 64)),
                    const SizedBox(height: 28),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: const SearchBox(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const _PromoCarousel(),
                    SectionHeader(
                      title: context.tr('home.popular'),
                      trailing: context.tr(
                        'home.updated',
                        args: {'time': _updatedTime()},
                      ),
                    ),
                    RecipeGrid(
                      recipes: all.take(5).toList(),
                      maxRows: 1,
                      itemBuilder: (r) => PopularTile(recipe: r),
                    ),
                    SectionHeader(
                      title: category == 'Semua'
                          ? context.tr('home.latest')
                          : context.tr(
                              'home.categoryTitle',
                              args: {'cat': context.category(category)},
                            ),
                      actionLabel:
                          category == 'Semua' ? context.tr('home.seeAll') : null,
                      onAction: () => context.go(AppRoutes.search),
                    ),
                    CategoryChips(
                      selected: category,
                      onSelected: (c) =>
                          context.go(AppRoutes.homeLocation(category: c)),
                    ),
                    const SizedBox(height: 24),
                    if (filtered.isEmpty)
                      EmptyState(
                        icon: Icons.restaurant_menu,
                        title: context.tr('home.emptyCat.title'),
                        message: context.tr(
                          'home.emptyCat.msg',
                          args: {'cat': context.category(category)},
                        ),
                        actionLabel: context.tr('action.write'),
                        onAction: () => context.go(AppRoutes.create),
                      )
                    else
                      RecipeGrid(recipes: filtered),
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

// ---------------------------------------------------------------------------
// Banner carousel (tanpa autoplay; geser lewat titik indikator)
// ---------------------------------------------------------------------------

class _Slide {
  const _Slide({
    required this.titleKey,
    required this.subtitleKey,
    required this.ctaKey,
    required this.target,
    required this.icons,
  });

  // Kunci terjemahan (lihat lib/l10n/strings_*.dart).
  final String titleKey;
  final String subtitleKey;
  final String ctaKey;
  final String target;
  final List<IconData> icons;
}

const List<_Slide> _slides = [
  _Slide(
    titleKey: 'slide1.title',
    subtitleKey: 'slide1.sub',
    ctaKey: 'slide1.cta',
    target: AppRoutes.search,
    icons: [Icons.ramen_dining, Icons.rice_bowl],
  ),
  _Slide(
    titleKey: 'slide2.title',
    subtitleKey: 'slide2.sub',
    ctaKey: 'action.write',
    target: AppRoutes.create,
    icons: [Icons.soup_kitchen, Icons.bakery_dining],
  ),
  _Slide(
    titleKey: 'slide3.title',
    subtitleKey: 'slide3.sub',
    ctaKey: 'slide3.cta',
    target: AppRoutes.saved,
    icons: [Icons.collections_bookmark, Icons.lunch_dining],
  ),
];

/// Ubah ke false untuk mematikan geser otomatis (mis. saat tes widget).
bool kBannerAutoplay = true;

class _PromoCarousel extends StatefulWidget {
  const _PromoCarousel();

  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  static const Duration _interval = Duration(milliseconds: 5500);
  static final int _start = _slides.length * 1000;

  // Daftar halaman "tak berujung": index asli = halaman % jumlah slide,
  // sehingga geser maju/mundur tidak pernah melompat balik ke awal.
  late final PageController _controller = PageController(initialPage: _start);
  Timer? _timer;
  int _page = _start;
  bool _paused = false;

  int get _index => _page % _slides.length;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (!kBannerAutoplay) return;
    _timer = Timer.periodic(_interval, (_) {
      // Berhenti sementara saat kursor di atas banner.
      if (_paused || !mounted || !_controller.hasClients) return;
      _goTo(_page + 1, restart: false);
    });
  }

  void _goTo(int page, {bool restart = true}) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    if (restart) _startTimer(); // beri jeda penuh setelah navigasi manual
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final compact = c.maxWidth < 560;
        final height = compact ? 230.0 : (c.maxWidth * 0.24).clamp(230.0, 300.0);

        return MouseRegion(
          onEnter: (_) => _paused = true,
          onExit: (_) => _paused = false,
          child: Column(
            children: [
              SizedBox(
                height: height,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: PageView.builder(
                          controller: _controller,
                          onPageChanged: (p) => setState(() => _page = p),
                          itemBuilder: (context, i) => _SlideView(
                            slide: _slides[i % _slides.length],
                            compact: compact,
                          ),
                        ),
                      ),
                    ),
                    if (!compact) ...[
                      Positioned(
                        left: 10,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _ArrowButton(
                            icon: Icons.chevron_left,
                            onTap: () => _goTo(_page - 1),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _ArrowButton(
                            icon: Icons.chevron_right,
                            onTap: () => _goTo(_page + 1),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _slides.length; i++)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _goTo(_page - _index + i),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: i == _index ? 22 : 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: i == _index
                                  ? AppTheme.ink
                                  : const Color(0xFFCFCFCF),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      builder: (context, hovered) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(hovered ? 255 : 200),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: AppTheme.ink),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide, required this.compact});

  final _Slide slide;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFFFF4E0), Color(0xFFFFE2BF)],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 32, vertical: 20),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            // FittedBox(scaleDown): bila teks lebih tinggi dari banner,
            // seluruh blok otomatis mengecil — tidak ada lagi bottom overflow.
            child: LayoutBuilder(
              builder: (context, box) => FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: box.maxWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(slide.titleKey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 22 : 32,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr(slide.subtitleKey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: compact ? 14 : 17),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: () => context.go(slide.target),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(0, compact ? 40 : 48),
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 18 : 28,
                          ),
                          shape: const StadiumBorder(),
                          textStyle: TextStyle(
                            fontSize: compact ? 15 : 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(
                          context.tr(slide.ctaKey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!compact)
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (final icon in slide.icons)
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 64, color: AppTheme.orange),
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
