# Cooking Mama — Backend API

REST API untuk aplikasi Cooking Mama. **Node.js + Express + PostgreSQL (`pg`)**.

**Mengapa Express?** Frontend berupa Flutter yang hanya membutuhkan JSON over HTTP, sehingga backend bebas
framework (sesuai naskah UTS). Express ringan, mudah dijalankan di laptop mahasiswa tanpa setup tambahan,
dan SQL ditulis langsung sehingga skema relasional PostgreSQL terlihat jelas saat presentasi.

## Instalasi

```bash
createdb -U postgres cooking_mama      # atau: CREATE DATABASE cooking_mama; di psql
cp .env.example .env                   # isi DB_PASSWORD & JWT_SECRET
npm install
npm run db:migrate
npm run db:seed
npm run dev                            # atau: npm start
```

| Perintah | Fungsi |
|---|---|
| `npm run db:migrate` | Menjalankan file di `src/db/migrations/*.sql` yang belum dijalankan |
| `npm run db:seed` | Menghapus & mengisi ulang data contoh (**tidak jalan** bila `NODE_ENV=production`) |
| `npm run db:reset` | Drop semua tabel → migrasi → seed (development saja) |

Membuat `JWT_SECRET`: `node -e "console.log(require('crypto').randomBytes(48).toString('hex'))"`

## Struktur

```
backend/
├── package.json
├── .env.example
├── uploads/                      foto yang diunggah (tidak di-commit)
└── src/
    ├── server.js                 start server + cek koneksi DB
    ├── app.js                    middleware, Swagger (/docs), /uploads, /api
    ├── config/   env.js  db.js
    ├── db/       migrate.js  seed.js  seed-data.js  migrations/001_init.sql
    ├── middleware/  auth.js  validate.js  upload.js  errorHandler.js
    ├── validators/index.js       skema Zod (pesan Bahasa Indonesia)
    ├── routes/index.js
    ├── controllers/  auth  recipes  comments  favorites  categories  users  uploads
    ├── models/       user  recipe  category  comment  favorite   (query SQL)
    ├── utils/        AppError  asyncHandler  response  mappers  slugify
    └── docs/openapi.yaml
```

## Skema database

`users` · `categories` · `recipes` (→ users, categories) · `ingredients` & `steps` (→ recipes, urut by `position`) ·
`comments` (→ recipes, users) · `favorites` (PK user_id+recipe_id) · `follows` (PK follower_id+following_id).
Relasi menggunakan `ON DELETE CASCADE` kecuali `recipes.category_id` (`RESTRICT`). Lihat `src/db/migrations/001_init.sql`.

## Format respons

```jsonc
// sukses
{ "success": true, "data": { ... }, "meta": { "page": 1, "limit": 20, "total": 12, "total_pages": 1 } }
// gagal
{ "success": false, "error": { "code": "VALIDATION_ERROR", "message": "...", "details": [{ "field": "email", "message": "..." }] } }
```

Kode status: `200/201` sukses · `400` request rusak · `401` belum login/token salah · `403` bukan pemilik ·
`404` tidak ada · `409` konflik (email sudah terdaftar) · `413` foto terlalu besar · `422` validasi gagal · `500` error server.

## Endpoint

Prefix `/api`. 🔒 = wajib header `Authorization: Bearer <token>`; 🔓 = token opsional (mengisi `is_favorite`).

| Method | Path | Auth | Keterangan |
|---|---|---|---|
| GET | `/health` | – | Cek server |
| POST | `/auth/register` | – | `{name,email,password}` → `{token,user}` |
| POST | `/auth/login` | – | `{email,password}` → `{token,user}` |
| GET | `/auth/me` | 🔒 | Akun yang sedang login |
| GET | `/categories` | – | Daftar kategori |
| GET | `/recipes` | 🔓 | Query: `q`, `category`, `author_id`, `page`, `limit` (maks 100) |
| POST | `/recipes` | 🔒 | Tulis resep |
| GET | `/recipes/:id` | 🔓 | Detail (bahan, langkah, komentar) |
| PUT | `/recipes/:id` | 🔒 | Ubah (pemilik saja; field opsional) |
| DELETE | `/recipes/:id` | 🔒 | Hapus (pemilik saja) |
| GET | `/recipes/:id/comments` | – | Daftar komentar |
| POST | `/recipes/:id/comments` | 🔒 | `{text}` |
| DELETE | `/comments/:id` | 🔒 | Hapus komentar sendiri |
| GET | `/favorites` | 🔒 | Resep yang disimpan |
| PUT | `/recipes/:id/favorite` | 🔒 | Simpan (idempotent) |
| DELETE | `/recipes/:id/favorite` | 🔒 | Batal simpan (idempotent) |
| GET | `/users/:id` | 🔓 | Profil + statistik |
| PATCH | `/users/me` | 🔒 | Ubah `name`, `bio`, `avatar_url` |
| PUT/DELETE | `/users/:id/follow` | 🔒 | Ikuti / berhenti mengikuti |
| POST | `/uploads/image` | 🔒 | multipart, field `photo` (JPG/PNG/WEBP, maks 5 MB) → `{url}` |

Spesifikasi lengkap: `/docs` (Swagger UI) atau `src/docs/openapi.yaml`.

### Contoh (curl)

```bash
# login
curl -s -X POST localhost:3000/api/auth/login -H 'Content-Type: application/json' \
  -d '{"email":"mamarina@example.com","password":"password123"}'

# daftar resep (cari "ayam", kategori Ayam)
curl -s 'localhost:3000/api/recipes?q=ayam&category=Ayam'

# tulis resep
curl -s -X POST localhost:3000/api/recipes -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"title":"Telur Dadar","category":"Nasi","cook_minutes":5,"servings":1,"ingredients":["2 butir telur"],"steps":["Kocok, goreng."]}'
```

## Catatan desain

- `GET /recipes` mengembalikan bahan, langkah, dan komentar sekaligus (satu query dengan sub-select JSON) agar
  frontend yang memfilter/mencari di sisi klien tetap bekerja tanpa request tambahan. Untuk data besar, kurangi
  `limit` dan gunakan `page`.
- Foto: `POST /uploads/image` menyimpan file di `uploads/` dan mengembalikan URL absolut dari host yang dipakai
  klien (emulator Android → `http://10.0.2.2:3000/uploads/...`). Set `PUBLIC_BASE_URL` bila di belakang proxy.
- Hanya satu jenis tamu/pengguna; belum ada role admin, rate limiting, atau refresh token.
<!-- Backend REST API developed by Jiddan Ibnu Ali (4jeeh) -->
