import '../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';

/// Mengubah waktu dari server (ISO-8601) menjadi teks relatif untuk komentar,
/// mis. "Baru saja", "5 menit lalu", "2 hari lalu".
String timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time.toLocal());
  if (diff.inMinutes < 1) {
    return AppLocalizations.lookup(LocaleController.instance.code, 'comment.justNow');
  }
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  if (diff.inDays < 30) return '${diff.inDays} hari lalu';
  final months = diff.inDays ~/ 30;
  if (months < 12) return '$months bulan lalu';
  return '${months ~/ 12} tahun lalu';
}
