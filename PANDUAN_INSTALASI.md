# Panduan Instalasi Cooking Mama (Windows)

Panduan dari nol: ekstrak file, menyiapkan database, menjalankan backend, sampai menjalankan aplikasi Flutter.

## 0. Prasyarat (pasang sekali saja)

| Software | Versi | Cek di PowerShell |
|---|---|---|
| Node.js | 18 atau lebih baru (disarankan LTS) | `node -v` |
| PostgreSQL | 13 atau lebih baru | buka **SQL Shell (psql)** dari Start Menu |
| Flutter SDK | Dart 3.3 atau lebih baru | `flutter --version` |
| Google Chrome | terbaru | – |
| Android Studio (opsional) | untuk emulator Android | `flutter devices` |

Saat memasang PostgreSQL, **catat password** untuk user `postgres`. Anda akan membutuhkannya di langkah 3.

## 1. Ekstrak proyek

1. Ekstrak `cooking_mama.zip`.
2. Hasilnya adalah folder `cooking_mama` yang berisi `backend/`, `frontend/`, dan `README.md`.
3. Buka PowerShell, lalu masuk ke folder tersebut (sesuaikan path Anda):

```powershell
cd "C:\Users\Administrator\Documents\Semester 5\Flutter\UTS\cooking_mama\cooking_mama"
```

Pastikan `dir` menampilkan folder `backend` dan `frontend`. Jika tidak, Anda masih berada satu folder di luar atau di dalam.

## 2. Buat database

Buka **SQL Shell (psql)** dari Start Menu. Tekan Enter untuk Server, Database, Port, dan Username (default), lalu masukkan password `postgres`. Jalankan:

```sql
CREATE DATABASE cooking_mama;
```

Keluar dengan `\q`.

## 3. Siapkan dan jalankan backend

Buka **terminal pertama** di root proyek (folder yang berisi `backend` dan `frontend`).

```powershell
cd backend
copy .env.example .env
notepad .env
```

Di Notepad, ubah dua baris ini lalu simpan:

```
DB_PASSWORD=password_postgres_anda
JWT_SECRET=teks_acak_panjang
```

Untuk membuat `JWT_SECRET` acak, jalankan:

```powershell
node -e "console.log(require('crypto').randomBytes(48).toString('hex'))"
```

Salin hasilnya ke `JWT_SECRET`. Jangan memakai spasi di sekitar tanda `=`.

Lalu pasang paket, buat tabel, isi data contoh, dan jalankan server:

```powershell
npm install
npm run db:migrate
npm run db:seed
npm run dev
```

Tanda berhasil: muncul tulisan `Cooking Mama API berjalan di http://localhost:3000`.

Cek di browser:
- <http://localhost:3000/api/health> harus menampilkan `status: ok`
- <http://localhost:3000/docs> adalah dokumentasi API (Swagger)

**Biarkan terminal ini terbuka.** Jika ditutup, backend mati.

## 4. Jalankan frontend (Flutter)

Buka **terminal kedua**, lalu masuk ke root proyek lagi.

```powershell
cd "C:\Users\Administrator\Documents\Semester 5\Flutter\UTS\cooking_mama\cooking_mama"
cd frontend
flutter pub get
```

`flutter pub get` **harus dijalankan di dalam folder `frontend`**, tempat `pubspec.yaml` berada.

Pilih salah satu cara menjalankan:

**a. Web (paling mudah)**

```powershell
flutter run -d chrome
```

Atau tanpa membuka Chrome otomatis:

```powershell
flutter run -d web-server --web-port 8080
```

Lalu buka <http://localhost:8080> di browser.

**b. Android emulator**

```powershell
flutter devices
flutter run -d <nama-emulator>
```

Alamat backend otomatis memakai `10.0.2.2:3000`, jadi tidak perlu pengaturan tambahan.

**c. HP Android fisik**

HP dan komputer harus di Wi-Fi yang sama. Cari IP komputer dengan `ipconfig` (lihat **IPv4 Address**), lalu:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000/api
```

Ganti `192.168.1.10` dengan IP komputer Anda. Jika gagal terhubung, izinkan port 3000 di Windows Firewall.

**d. iOS** (hanya di Mac)

```bash
cd ios && pod install && cd ..
flutter run -d <ios-simulator>
```

## 5. Login contoh

```
Email    : mamarina@example.com
Password : password123
```

Anda juga bisa mendaftar akun baru lewat halaman Daftar.

## 6. Menjalankan tes (opsional)

```powershell
cd frontend
flutter test
```

## 7. Masalah umum

| Gejala | Penyebab dan solusi |
|---|---|
| `Expected to find project root` atau `No pubspec.yaml file found` | Anda belum di dalam `frontend`. Jalankan `cd frontend`. |
| `[env] Variabel wajib belum diisi di .env` | File `.env` belum dibuat atau `DB_PASSWORD`/`JWT_SECRET` kosong. Ulangi langkah 3. |
| `password authentication failed` | `DB_PASSWORD` di `.env` tidak sama dengan password PostgreSQL. |
| `database "cooking_mama" does not exist` | Langkah 2 belum dijalankan. |
| `ECONNREFUSED 127.0.0.1:5432` | Service PostgreSQL belum berjalan. Buka `services.msc`, cari **postgresql**, lalu Start. |
| `port 3000 already in use` | Ubah `PORT` di `.env`, dan sesuaikan `API_BASE_URL` di frontend. |
| `npm` atau `node` tidak dikenali | Node.js belum terpasang atau terminal belum dibuka ulang setelah instalasi. |
| Aplikasi terbuka tapi daftar resep kosong | Backend belum berjalan atau tidak terjangkau. Cek langkah 3, lalu muat ulang aplikasi. |
| Pesan "Tidak dapat terhubung ke server" saat login | Sama seperti di atas. Pastikan <http://localhost:3000/api/health> terbuka di browser. |
| Emulator Android tidak bisa terhubung | Pastikan backend jalan, dan jangan pakai `localhost` untuk emulator. Alamat yang benar `10.0.2.2` sudah otomatis. |
| Aplikasi lama masih muncul di emulator | `applicationId` berubah menjadi `com.example.cooking_mama`. Uninstall aplikasi lama (`cooking_mami`) dulu. |
| Mengulang data dari awal | `npm run db:reset` di folder `backend` (menghapus semua tabel lalu seed ulang). |

## 8. Urutan ringkas (setelah semua terpasang)

Setiap kali ingin menjalankan aplikasi:

1. Pastikan PostgreSQL berjalan.
2. Terminal 1: `cd backend` lalu `npm run dev`
3. Terminal 2: `cd frontend` lalu `flutter run -d chrome`

## 9. Sebelum push ke GitHub

- `.env` **tidak boleh** ikut di-commit (sudah ada di `backend/.gitignore`).
- Isi nama dan NIM anggota di `README.md` pada root proyek.
- File `frontend_changes.diff` boleh dihapus.
