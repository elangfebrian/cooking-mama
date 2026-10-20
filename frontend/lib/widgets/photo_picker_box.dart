import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:image_picker/image_picker.dart' show ImageSource;

import '../l10n/app_localizations.dart';
import '../services/image_service.dart';
import '../theme/app_theme.dart';

/// Kotak foto masakan (KHUSUS MOBILE): ketuk -> bottom sheet
/// Kamera / Galeri / Hapus. Versi web tetap memakai kotak lama.
class PhotoPickerBox extends StatelessWidget {
  const PhotoPickerBox({
    super.key,
    required this.path,
    required this.onChanged,
  });

  final String? path;
  final ValueChanged<String?> onChanged;

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final messenger = ScaffoldMessenger.of(context);
    final denied = context.tr('create.photoDenied');
    final failed = context.tr('create.photoError');
    try {
      final picked = await ImageService.pick(source);
      if (picked != null) onChanged(picked);
    } on PlatformException catch (e) {
      final isDenied = e.code.contains('access_denied');
      messenger.showSnackBar(SnackBar(content: Text(isDenied ? denied : failed)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    }
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(context.tr('create.photoCamera')),
              onTap: () {
                Navigator.pop(sheetContext);
                _pick(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.tr('create.photoGallery')),
              onTap: () {
                Navigator.pop(sheetContext);
                _pick(context, ImageSource.gallery);
              },
            ),
            if (path != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(context.tr('create.photoRemove')),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onChanged(null);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = path != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        _openSheet(context);
      },
      child: Container(
        height: 200,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppTheme.orangeSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: hasPhoto
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(path!),
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: AppTheme.orange, size: 38),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Material(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.edit, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              context.tr('create.photoChange'),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
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
    );
  }
}
