/// Teks Bahasa Indonesia (bahasa default & acuan kunci).
/// Parameter ditulis {nama}, diisi lewat `context.tr(key, args: {...})`.
const Map<String, String> stringsId = {
  // ---- Kategori ----
  'cat.Semua': 'Semua',
  'cat.Ayam': 'Ayam',
  'cat.Daging': 'Daging',
  'cat.Sayur': 'Sayur',
  'cat.Nasi': 'Nasi',
  'cat.Camilan': 'Camilan',
  'cat.Minuman': 'Minuman',
  'cat.Dessert': 'Dessert',

  // ---- Navigasi & aksi umum ----
  'nav.search': 'Cari',
  'nav.premium': 'Premium',
  'nav.cookTogether': 'Posting Bareng',
  'nav.countries': 'Negara',
  'nav.collection': 'Koleksi Resep',
  'nav.collapse': 'Ciutkan menu',
  'nav.expand': 'Perluas menu',
  'nav.menu': 'Menu',
  'nav.back': 'Kembali',
  'hint.guest.before': 'Untuk mulai membuat koleksi resep, silakan ',
  'hint.guest.link': 'daftar atau masuk',
  'hint.guest.after': '.',
  'hint.user': 'Kamu punya {n} resep tersimpan. ',
  'hint.user.link': 'Lihat koleksi',
  'action.login': 'Masuk',
  'action.signup': 'Daftar',
  'action.write': 'Tulis Resep',
  'account.tooltip': 'Akun saya',
  'account.profile': 'Profil saya',
  'account.saved': 'Resep tersimpan',
  'account.logout': 'Keluar',
  'lang.tooltip': 'Bahasa',
  'lang.label': 'Bahasa',
  'comment.justNow': 'Baru saja',

  // ---- Banner bawah ----
  'promo.subtitle': 'Temukan resep terpopuler di urutan teratas.',
  'promo.cta': 'Mulai',

  // ---- Footer ----
  'footer.about': 'Tentang Kami',
  'footer.mission1': 'Misi kami di Cooking Mama adalah untuk ',
  'footer.mission.bold1': 'membuat masak sehari-hari makin menyenangkan',
  'footer.mission2':
      ', karena kami percaya bahwa memasak adalah kunci menuju kehidupan yang '
          'lebih bahagia dan lebih sehat bagi manusia, komunitas, dan bumi. '
          'Kami mendukung juru masak rumahan di seluruh dunia untuk ',
  'footer.mission.bold2': 'membantu satu sama lain',
  'footer.mission3': ' dengan berbagi resep dan pengalaman memasak.',
  'footer.premiumLink': 'Langganan Premium',
  'footer.premiumAfter': ' untuk menikmati fitur & manfaat eksklusif!',
  'footer.community': 'Komunitas Cooking Mama',
  'footer.seeAll': 'Lihat Semua',
  'footer.more': 'Selengkapnya',
  'footer.download': 'Unduh aplikasi kami',
  'footer.copyright':
      'Copyright © Cooking Mama · Proyek UTS Pemrograman Aplikasi Bergerak',
  'footer.appSoon': 'Aplikasi mobile belum tersedia.',
  'badge.google.small': 'TEMUKAN DI',
  'badge.apple.small': 'Download di',

  // ---- Beranda ----
  'home.tab': 'Cooking Mama - Resep Masakan Rumahan',
  'home.popular': 'Pencarian Populer',
  'home.updated': 'Diperbarui {time}',
  'home.latest': 'Resep terbaru',
  'home.seeAll': 'Lihat semua',
  'home.categoryTitle': 'Resep {cat}',
  'home.emptyCat.title': 'Belum ada resep di kategori ini',
  'home.emptyCat.msg': 'Jadilah yang pertama membagikan resep {cat}.',
  'slide1.title': 'Bingung masak apa minggu ini?',
  'slide1.sub': 'Ide masakan mudah dan enak untuk seminggu ke depan.',
  'slide1.cta': 'Lihat resep minggu ini',
  'slide2.title': 'Punya resep andalan?',
  'slide2.sub': 'Bagikan ke sesama Mama dan jadi inspirasi dapur Indonesia.',
  'slide3.title': 'Simpan resep favoritmu',
  'slide3.sub': 'Buat koleksi supaya mudah ditemukan kapan saja.',
  'slide3.cta': 'Lihat Koleksi',
  'banner.prev': 'Sebelumnya',
  'banner.next': 'Berikutnya',

  // ---- Pencarian ----
  'search.hint': 'Cari resep, bahan, pengguna',
  'search.tab': 'Cari Resep - Cooking Mama',
  'search.tabQuery': 'Resep {q} - Cooking Mama',
  'search.all': 'Semua resep',
  'search.resultsFor': 'Hasil pencarian “{q}”',
  'search.count': '{n} resep ditemukan',
  'search.empty.title': 'Resep tidak ditemukan',
  'search.empty.msg': 'Coba kata kunci lain atau ganti kategori pencarian.',
  'search.empty.cta': 'Lihat semua resep',

  // ---- Kartu & detail resep ----
  'card.minutes': '{n} mnt',
  'card.unsave': 'Hapus dari tersimpan',
  'detail.save': 'Simpan resep',
  'detail.saved': 'Tersimpan',
  'detail.share': 'Bagikan',
  'detail.copied': 'Tautan resep disalin ke papan klip.',
  'detail.crumbHome': 'Beranda',
  'detail.minutes': '{n} menit',
  'detail.servings': '{n} porsi',
  'detail.ingredients': 'Bahan-bahan',
  'detail.steps': 'Langkah memasak',
  'detail.comments': 'Komentar ({n})',
  'detail.commentHint': 'Tulis komentar…',
  'detail.send': 'Kirim komentar',
  'detail.sendShort': 'Kirim',
  'detail.loginToComment': 'Masuk untuk menulis komentar.',
  'detail.firstComment': 'Jadilah yang pertama berkomentar.',
  'detail.notFound.msg':
      'Resep yang kamu cari tidak ada atau sudah dihapus oleh penulisnya.',

  // ---- Halaman tidak ditemukan ----
  'nf.title': 'Halaman tidak ditemukan',
  'nf.msg': 'Alamat yang kamu buka tidak tersedia atau sudah dipindahkan.',
  'nf.tab': 'Tidak ditemukan - Cooking Mama',
  'nf.cta': 'Kembali ke Beranda',

  // ---- Masuk & daftar ----
  'login.tab': 'Masuk - Cooking Mama',
  'login.title': 'Masuk ke Cooking Mama',
  'login.subtitle': 'Temukan dan bagikan resep masakan rumahan',
  'login.noticeSave': 'Masuk untuk menyimpan resep ini ke koleksimu.',
  'login.noticeGo': 'Masuk untuk melanjutkan ke halaman yang kamu tuju.',
  'auth.email': 'Email',
  'auth.password': 'Kata sandi',
  'auth.emailInvalid': 'Masukkan email yang valid',
  'auth.passMin': 'Kata sandi minimal 6 karakter',
  'auth.noAccount': 'Belum punya akun? ',
  'auth.haveAccount': 'Sudah punya akun? ',
  'auth.guest': 'Lanjut menjelajah tanpa masuk',
  'auth.show': 'Tampilkan',
  'auth.hide': 'Sembunyikan',
  'reg.tab': 'Daftar - Cooking Mama',
  'reg.title': 'Buat akun',
  'reg.subtitle': 'Gratis, dan hanya butuh satu menit',
  'reg.noticeSave': 'Buat akun untuk menyimpan resep ini ke koleksimu.',
  'reg.noticeGo': 'Buat akun untuk melanjutkan ke halaman yang kamu tuju.',
  'reg.name': 'Nama lengkap',
  'reg.nameReq': 'Nama wajib diisi',
  'reg.confirm': 'Ulangi kata sandi',
  'reg.mismatch': 'Kata sandi tidak sama',

  // ---- Koleksi & profil ----
  'fav.tab': 'Resep Tersimpan - Cooking Mama',
  'fav.title': 'Resep tersimpan',
  'fav.count': '{n} resep',
  'fav.empty.title': 'Belum ada resep tersimpan',
  'fav.empty.msg':
      'Klik ikon penanda di resep mana pun untuk menyimpannya di sini.',
  'fav.empty.cta': 'Jelajahi resep',
  'prof.tab': 'Profil - Cooking Mama',
  'prof.recipes': 'Resep',
  'prof.saved': 'Tersimpan',
  'prof.followers': 'Pengikut',
  'prof.mine': 'Resep saya',
  'prof.empty.title': 'Kamu belum menulis resep',
  'prof.empty.msg': 'Bagikan resep andalanmu supaya bisa dicoba orang lain.',

  // ---- Tulis resep ----
  'create.tab': 'Tulis Resep - Cooking Mama',
  'create.title': 'Tulis resep',
  'create.subtitle': 'Bagikan resep andalanmu kepada pembaca Cooking Mama.',
  'create.photo': 'Tambah foto masakan',
  'create.photoSoon': 'Unggah foto akan aktif setelah backend tersedia.',
  'create.titleHint': 'Judul resep',
  'create.titleReq': 'Judul wajib diisi',
  'create.descHint': 'Ceritakan sedikit tentang masakan ini',
  'create.timeHint': 'Waktu (menit)',
  'create.servingsHint': 'Porsi',
  'create.number': 'Isi angka',
  'create.ingredientHint': 'Contoh: 2 siung bawang putih',
  'create.addIngredient': 'Tambah bahan',
  'create.stepHint': 'Jelaskan langkahnya',
  'create.addStep': 'Tambah langkah',
  'create.remove': 'Hapus',
  'create.cancel': 'Batal',
  'create.publish': 'Terbitkan resep',
  'create.minNeeded': 'Isi minimal satu bahan dan satu langkah.',
  'create.published': 'Resep berhasil dipublikasikan.',

  // ---- Negara ----
  'ctry.title': 'Pilih Negara',
  'ctry.tab': 'Pilih Negara - Cooking Mama',
  'ctry.unavailable': 'Versi untuk {country} belum tersedia.',

  // ---- Halaman info ----
  'info.explore': 'Jelajahi resep',
  'info.premium.title': 'Cooking Mama Premium',
  'info.premium.body':
      'Premium adalah paket langganan untuk menikmati fitur dan manfaat eksklusif di Cooking Mama.\n\n'
          'Manfaat yang direncanakan: resep terpopuler di urutan teratas, koleksi resep tanpa batas, dan pencarian tanpa iklan.\n\n'
          'Cooking Mama saat ini adalah proyek pembelajaran, sehingga langganan belum dapat dibeli. Seluruh fitur yang ada sekarang bisa dipakai gratis.',
  'info.posting-bareng.title': 'Posting Bareng',
  'info.posting-bareng.body':
      'Posting Bareng adalah ajakan memasak bersama: setiap periode ada satu tema masakan, lalu para Mama membagikan versi resep masing-masing.\n\n'
          'Untuk ikut serta, masuk ke akunmu lalu tulis resepmu lewat tombol Tulis Resep.\n\n'
          'Fitur tema dan daftar peserta akan hadir setelah layanan backend tersedia.',
  'info.karir.title': 'Karir',
  'info.karir.body':
      'Cooking Mama dibuat sebagai proyek UTS mata kuliah Pemrograman Aplikasi Bergerak, sehingga saat ini belum ada lowongan.',
  'info.kirim-saran.title': 'Kirim Saran',
  'info.kirim-saran.body':
      'Masukan sangat berharga untuk menyempurnakan Cooking Mama.\n\n'
          'Formulir saran akan diaktifkan setelah backend tersedia. Sementara itu, sampaikan masukan langsung kepada pengembang proyek ini.',
  'info.blog.title': 'Blog',
  'info.blog.body':
      'Blog Cooking Mama akan berisi tips memasak, kisah para Mama, dan kabar terbaru dari aplikasi.\n\n'
          'Belum ada artikel yang diterbitkan.',
  'info.ketentuan.title': 'Ketentuan Pemakaian',
  'info.ketentuan.body':
      'Dengan memakai Cooking Mama, kamu setuju untuk membagikan resep yang kamu tulis sendiri atau yang kamu punya izin untuk membagikannya.\n\n'
          'Jangan mengunggah konten yang melanggar hukum, menyinggung, atau menyesatkan.\n\n'
          'Kami dapat menghapus konten yang melanggar ketentuan ini.',
  'info.panduan.title': 'Panduan Komunitas Cooking Mama',
  'info.panduan.body':
      'Hormati sesama anggota: berkomentarlah dengan sopan dan membangun.\n\n'
          'Cantumkan sumber bila resep berasal dari orang lain.\n\n'
          'Bagikan pengalaman memasak yang jujur, termasuk saat resep belum berhasil.',
  'info.privasi.title': 'Kebijakan Privasi',
  'info.privasi.body':
      'Cooking Mama hanya menyimpan data yang diperlukan agar aplikasi berfungsi: nama, email, serta resep dan koleksi milikmu.\n\n'
          'Sesi login disimpan di browser perangkatmu dan dihapus saat kamu keluar.\n\n'
          'Data tidak dijual kepada pihak ketiga.',
  'info.faq.title': 'FAQ',
  'info.faq.body':
      'Apakah saya harus login untuk melihat resep? Tidak. Beranda, pencarian, dan detail resep bisa dibuka siapa saja.\n\n'
          'Kapan saya perlu login? Saat menyimpan resep, menulis resep, berkomentar, atau membuka profil.\n\n'
          'Apakah Cooking Mama gratis? Ya, semua fitur yang tersedia sekarang gratis.',
  'mnav.home': 'Beranda',
  'mnav.search': 'Cari',
  'mnav.create': 'Buat Resep',
  'mnav.profile': 'Profil',
  'create.photoCamera': 'Ambil foto',
  'create.photoGallery': 'Pilih dari galeri',
  'create.photoRemove': 'Hapus foto',
  'create.photoChange': 'Ganti foto',
  'create.photoDenied': 'Izin kamera/galeri ditolak. Aktifkan lewat Pengaturan perangkat.',
  'create.photoError': 'Gagal mengambil foto. Coba lagi.',
};
