import 'package:image_picker/image_picker.dart';

/// Pembungkus image_picker: kamera & galeri.
///
/// Izin ditangani plugin: Android 13+ memakai Photo Picker (tanpa izin
/// storage), kamera meminta izin CAMERA saat dipakai; iOS memunculkan dialog
/// berdasar NSCameraUsageDescription / NSPhotoLibraryUsageDescription.
/// Bila izin ditolak, `pickImage` melempar PlatformException
/// (kode: camera_access_denied / photo_access_denied) -> ditangkap di UI.
class ImageService {
  ImageService._();

  static final ImagePicker _picker = ImagePicker();

  /// Mengembalikan path file lokal, atau null bila pengguna membatalkan.
  static Future<String?> pick(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
      // iOS: tidak perlu izin "full photo library" hanya untuk metadata.
      requestFullMetadata: false,
    );
    return file?.path;
  }

  /// Android bisa mematikan Activity saat kamera terbuka (memori kecil).
  /// Panggil sekali saat layar dibuat untuk memulihkan hasil foto.
  static Future<String?> recoverLostPhoto() async {
    try {
      final LostDataResponse res = await _picker.retrieveLostData();
      if (res.isEmpty) return null;
      final files = res.files;
      if (files != null && files.isNotEmpty) return files.first.path;
    } catch (_) {}
    return null;
  }
}
