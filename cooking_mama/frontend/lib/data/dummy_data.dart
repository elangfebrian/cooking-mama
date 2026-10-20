/// Daftar kategori untuk chip filter dan form "Tulis Resep".
/// Nilainya sama dengan tabel `categories` di backend (+ "Semua" sebagai filter).
/// Data resep TIDAK lagi di sini: diambil dari REST API lewat AppState.
const List<String> categories = [
  'Semua', 'Ayam', 'Daging', 'Sayur', 'Nasi', 'Camilan', 'Minuman', 'Dessert',
];
