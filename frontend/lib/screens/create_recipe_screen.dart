import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/app_state.dart';
import '../data/dummy_data.dart';
import '../l10n/app_localizations.dart';
import '../models/recipe.dart';
import '../services/api_client.dart';
import '../services/image_service.dart';
import '../utils/platform_info.dart';
import '../widgets/photo_picker_box.dart';
import '../router/routes.dart';
import '../theme/app_theme.dart';
import '../widgets/hover_builder.dart';
import '../widgets/page_layout.dart';

/// Tulis resep — PRIVAT (dijaga guard di app_router.dart).
class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _minutes = TextEditingController();
  final _servings = TextEditingController();
  final List<TextEditingController> _ingredients = [TextEditingController()];
  final List<TextEditingController> _steps = [TextEditingController()];
  String _category = 'Nasi';
  bool _saving = false;

  /// Path foto dari kamera/galeri (hanya terisi di app mobile).
  String? _photoPath;

  /// Baris yang baru ditambah: langsung fokus agar keyboard siap mengetik.
  final Set<TextEditingController> _autofocus = {};

  @override
  void initState() {
    super.initState();
    if (AppPlatform.isMobileApp) {
      ImageService.recoverLostPhoto().then((p) {
        if (p != null && mounted) setState(() => _photoPath = p);
      });
    }
  }

  void _addRow(List<TextEditingController> list) {
    final c = TextEditingController();
    setState(() {
      list.add(c);
      if (AppPlatform.isMobileApp) _autofocus.add(c);
    });
  }

  @override
  void dispose() {
    for (final c in [_title, _desc, _minutes, _servings]) {
      c.dispose();
    }
    for (final c in [..._ingredients, ..._steps]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final ingredients = _ingredients
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final steps =
        _steps.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

    if (ingredients.isEmpty || steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('create.minNeeded'))),
      );
      return;
    }

    // Draft: id & foto final ditentukan server (lihat AppState.addRecipe).
    final draft = Recipe(
      id: 0,
      title: _title.text.trim(),
      description: _desc.text.trim(),
      imageUrl: '',
      author: AppState.instance.userName,
      category: _category,
      cookMinutes: int.tryParse(_minutes.text) ?? 0,
      servings: int.tryParse(_servings.text) ?? 1,
      ingredients: ingredients,
      steps: steps,
    );

    setState(() => _saving = true);
    try {
      // POST /api/uploads/image (bila ada foto) lalu POST /api/recipes.
      final recipe =
          await AppState.instance.addRecipe(draft, photoPath: _photoPath);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('create.published'))),
      );
      context.go(AppRoutes.recipeLocation(recipe));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _dynamicList({
    required String title,
    required String hint,
    required List<TextEditingController> controllers,
    required bool numbered,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        ...List.generate(controllers.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (numbered)
                  Padding(
                    padding: const EdgeInsets.only(top: 14, right: 10),
                    child: Text(
                      '${i + 1}.',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                Expanded(
                  child: TextField(
                    controller: controllers[i],
                    minLines: 1,
                    maxLines: numbered ? null : 1,
                    autofocus: _autofocus.contains(controllers[i]),
                    // Mobile: ruang ekstra di bawah field aktif agar tidak
                    // menempel/tertutup keyboard.
                    scrollPadding: AppPlatform.isMobileApp
                        ? const EdgeInsets.fromLTRB(20, 20, 20, 180)
                        : const EdgeInsets.all(20),
                    textInputAction: AppPlatform.isMobileApp && !numbered
                        ? TextInputAction.next
                        : null,
                    textCapitalization: AppPlatform.isMobileApp
                        ? TextCapitalization.sentences
                        : TextCapitalization.none,
                    onEditingComplete: AppPlatform.isMobileApp && !numbered
                        ? () {
                            // Enter di bahan terakhir -> baris bahan baru.
                            final isLast = i == controllers.length - 1;
                            if (isLast &&
                                controllers[i].text.trim().isNotEmpty) {
                              _addRow(controllers);
                            } else {
                              FocusScope.of(context).nextFocus();
                            }
                          }
                        : null,
                    decoration: InputDecoration(hintText: hint),
                  ),
                ),
                IconButton(
                  tooltip: context.tr('create.remove'),
                  icon: const Icon(Icons.remove_circle_outline,
                      color: AppTheme.grey),
                  onPressed: controllers.length == 1
                      ? null
                      : () => setState(() {
                            controllers.removeAt(i).dispose();
                          }),
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () => _addRow(controllers),
          icon: const Icon(Icons.add, color: AppTheme.orange),
          label: Text(
            numbered
                ? context.tr('create.addStep')
                : context.tr('create.addIngredient'),
            style: const TextStyle(color: AppTheme.orange),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cats = categories.where((c) => c != 'Semua').toList();

    return Title(
      title: context.tr('create.tab'),
      color: AppTheme.orange,
      child: PageScroll(
        children: [
          ContentBox(
            maxWidth: 800,
            verticalPadding: 32,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.tr('create.title'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr('create.subtitle'),
                    style: const TextStyle(color: AppTheme.grey),
                  ),
                  const SizedBox(height: 24),
                  if (AppPlatform.isMobileApp)
                    PhotoPickerBox(
                      path: _photoPath,
                      onChanged: (p) => setState(() => _photoPath = p),
                    )
                  else
                  HoverBuilder(
                    builder: (context, hovered) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.tr('create.photoSoon')),
                        ),
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 180,
                        decoration: BoxDecoration(
                          color: hovered
                              ? const Color(0xFFFFE6D1)
                              : AppTheme.orangeSoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                hovered ? AppTheme.orange : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_a_photo_outlined,
                                color: AppTheme.orange, size: 38),
                            const SizedBox(height: 8),
                            Text(
                              context.tr('create.photo'),
                              style: const TextStyle(
                                color: AppTheme.orange,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _title,
                    decoration: InputDecoration(
                      hintText: context.tr('create.titleHint'),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? context.tr('create.titleReq')
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _desc,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: context.tr('create.descHint'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minutes,
                          keyboardType: TextInputType.number,
                          textInputAction: AppPlatform.isMobileApp
                              ? TextInputAction.next
                              : null,
                          decoration: InputDecoration(
                            hintText: context.tr('create.timeHint'),
                          ),
                          validator: (v) => (int.tryParse(v ?? '') == null)
                              ? context.tr('create.number')
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _servings,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: context.tr('create.servingsHint'),
                          ),
                          validator: (v) => (int.tryParse(v ?? '') == null)
                              ? context.tr('create.number')
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(),
                    items: cats
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(context.category(c)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _category = v ?? _category),
                  ),
                  const SizedBox(height: 28),
                  _dynamicList(
                    title: context.tr('detail.ingredients'),
                    hint: context.tr('create.ingredientHint'),
                    controllers: _ingredients,
                    numbered: false,
                  ),
                  const SizedBox(height: 20),
                  _dynamicList(
                    title: context.tr('detail.steps'),
                    hint: context.tr('create.stepHint'),
                    controllers: _steps,
                    numbered: true,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => context.go(AppRoutes.home),
                        child: Text(context.tr('create.cancel')),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _save,
                        child: Text(context.tr('create.publish')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
