# Cooking Mama

Aplikasi resep masakan rumahan, **clone [Cookpad](https://cookpad.com)** dengan nama plesetan **Cooking Mama**.
Proyek UTS Pemrograman Aplikasi Bergerak (Sistem Informasi, TA 2026/2027).

| | |
|---|---|
| Aplikasi asli | Cookpad |
| Nama plesetan | Cooking Mama |
| Frontend | Flutter (Dart), satu codebase untuk Web, Android, iOS |
| Backend | Node.js + Express (REST API, JWT) |
| Database | PostgreSQL |

## Daftar anggota

**Kelompok 7:**

| No | Nama | NIM | Tanggung jawab |
|----|------|-----|----------------|
| 1 | Novia Syahidatul Tazkiyah | 24051214189 | Dokumentasi dan pengujian |
| 2 | Erico Dhandy Setiawan | 24051214181 | Database dan skrip |
| 3 | Elang Febriansyah | 24051214202 | Frontend (Flutter) |
| 4 | Jiddan Ibnu Ali | 24051214203 | Backend (REST API) |

### Pembagian bagian kode

| Anggota | Folder / file utama |
|---|---|
| Elang Febriansyah | `frontend/lib` (screens, widgets, router, services, l10n) |
| Jiddan Ibnu Ali | `backend/src` (routes, controllers, models, middleware, `docs/openapi.yaml`) |
| Erico Dhandy Setiawan | `backend/src/db` (migrations, `migrate.js`, `seed.js`, `seed-data.js`) |
| Novia Syahidatul Tazkiyah | `README.md`, `docs/`, `frontend/test` |

## Isi repositori

```
cooking_mama/
├── frontend/                 Kode sumber aplikasi Flutter
│   ├── lib/                  screens, widgets, router, services, l10n
│   ├── android/ ios/ web/    konfigurasi tiap platform
│   └── test/                 widget test
├── backend/                  REST API
│   └── src/
│       ├── routes/           daftar endpoint
│       ├── controllers/      logika tiap fitur
│       ├── models/           query SQL
│       ├── middleware/       auth JWT, validasi, upload, error handler
│       ├── docs/openapi.yaml dokumentasi API (Swagger UI di /docs)
│       └── db/               Script/migration database
│           ├── migrations/   001_init.sql (skema tabel)
│           ├── migrate.js    menjalankan migrasi
│           └── seed.js       mengisi data contoh
└── docs/                     Panduan instalasi lengkap untuk Windows
```

## Panduan singkat menjalankan proyek

**Prasyarat:** Node.js 18 atau lebih baru, PostgreSQL 13 atau lebih baru, Flutter SDK (Dart 3.3 atau lebih baru), dan Google Chrome.

### 1. Buat database (sekali saja)

```bash
createdb -U postgres cooking_mama
```

Atau lewat psql: `CREATE DATABASE cooking_mama;`

### 2. Jalankan backend (terminal 1)

```bash
cd backend
cp .env.example .env        # Windows: copy .env.example .env
# edit .env: isi DB_PASSWORD dan JWT_SECRET (tanpa spasi di sekitar "=")
npm install
npm run db:migrate          # membuat tabel
npm run db:seed             # mengisi 12 resep Indonesia + akun contoh
npm run dev                 # http://localhost:3000
```

Membuat `JWT_SECRET` acak:

```bash
node -e "console.log(require('crypto').randomBytes(48).toString('hex'))"
```

Cek server: <http://localhost:3000/api/health> (harus `status: ok`).
Dokumentasi API: <http://localhost:3000/docs>.

### 3. Jalankan frontend (terminal 2)

```bash
cd frontend
flutter pub get
flutter run -d chrome                 # Web
flutter run -d <emulator-android>     # Android (otomatis memakai 10.0.2.2:3000)
flutter run --dart-define=API_BASE_URL=http://IP_KOMPUTER:3000/api   # HP fisik
```

### 4. Login contoh

```
Email    : mamarina@example.com
Password : password123
```

Atau daftar akun baru lewat halaman **Daftar**.

### Perintah lain

| Perintah | Fungsi |
|---|---|
| `npm run db:reset` (di `backend`) | Hapus semua tabel, buat ulang, isi data contoh |
| `flutter test` (di `frontend`) | Menjalankan tes frontend |

Masalah umum dan langkah rinci ada di [`docs/PANDUAN_INSTALASI.md`](docs/PANDUAN_INSTALASI.md).

## Arsitektur singkat

```
Flutter (UI) ──HTTP/JSON + JWT──▶ Express REST API ──SQL──▶ PostgreSQL
 AppState ─▶ ApiClient             routes → controllers → models
```

Detail endpoint, skema database, dan contoh request ada di [`backend/README.md`](backend/README.md).

## Catatan keamanan

- Password di-hash dengan bcrypt; token JWT berlaku 7 hari.
- `.env` tidak ikut di-commit (lihat `.gitignore`). **Jangan** meng-commit password database atau `JWT_SECRET`.
- HTTP non-HTTPS hanya diizinkan pada build debug/profile Android dan jaringan lokal iOS. Untuk produksi gunakan HTTPS.
