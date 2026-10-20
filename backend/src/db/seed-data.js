// Data contoh bertema masakan Indonesia. Resep 1-8 sama dengan data mock frontend.
// Semua akun contoh memakai password: password123
module.exports = {
  "categories": [
    "Ayam",
    "Daging",
    "Sayur",
    "Nasi",
    "Camilan",
    "Minuman",
    "Dessert"
  ],
  "users": [
    {
      "name": "Mama Rina",
      "email": "mamarina@example.com"
    },
    {
      "name": "Bunda Sari",
      "email": "bundasari@example.com"
    },
    {
      "name": "Mama Dina",
      "email": "mamadina@example.com"
    },
    {
      "name": "Uni Rosa",
      "email": "unirosa@example.com"
    },
    {
      "name": "Kak Lia",
      "email": "kaklia@example.com"
    },
    {
      "name": "Ibu Rani",
      "email": "iburani@example.com"
    }
  ],
  "recipes": [
    {
      "id": 1,
      "title": "Nasi Goreng Kampung Spesial",
      "description": "Nasi goreng sederhana dengan bumbu terasi dan cabai, cocok untuk sarapan.",
      "image": "https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800",
      "author": "Bunda Sari",
      "category": "Nasi",
      "cookMinutes": 20,
      "servings": 2,
      "ingredients": [
        "2 piring nasi putih dingin",
        "3 siung bawang merah",
        "2 siung bawang putih",
        "3 buah cabai merah",
        "1 butir telur",
        "1 sdm kecap manis",
        "Garam dan merica secukupnya"
      ],
      "steps": [
        "Haluskan bawang merah, bawang putih, dan cabai.",
        "Tumis bumbu halus hingga harum.",
        "Masukkan telur, orak-arik sebentar.",
        "Tambahkan nasi, kecap, garam, dan merica. Aduk rata.",
        "Sajikan dengan kerupuk dan acar."
      ],
      "comments": [
        {
          "user": "Ibu Rani",
          "text": "Enak banget, anak-anak suka!",
          "daysAgo": 2
        }
      ]
    },
    {
      "id": 2,
      "title": "Soto Ayam Kuah Bening",
      "description": "Soto ayam hangat dengan kuah kuning yang segar.",
      "image": "https://images.unsplash.com/photo-1547592166-23ac45744acd?w=800",
      "author": "Mama Dina",
      "category": "Ayam",
      "cookMinutes": 45,
      "servings": 4,
      "ingredients": [
        "500 gr ayam",
        "2 batang serai",
        "3 lembar daun jeruk",
        "1 sdt kunyit bubuk",
        "4 siung bawang putih",
        "Soun, tauge, dan seledri"
      ],
      "steps": [
        "Rebus ayam hingga empuk, angkat dan suwir.",
        "Tumis bumbu halus bersama serai dan daun jeruk.",
        "Masukkan tumisan ke kaldu, masak 15 menit.",
        "Tata soun, tauge, dan ayam di mangkuk, siram kuah."
      ]
    },
    {
      "id": 3,
      "title": "Rendang Daging Sapi",
      "description": "Rendang empuk dengan bumbu rempah yang meresap sempurna.",
      "image": "https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?w=800",
      "author": "Uni Rosa",
      "category": "Daging",
      "cookMinutes": 180,
      "servings": 6,
      "ingredients": [
        "1 kg daging sapi",
        "1 liter santan kental",
        "10 buah cabai merah",
        "6 siung bawang merah",
        "2 lembar daun kunyit",
        "Lengkuas, jahe, serai"
      ],
      "steps": [
        "Haluskan semua bumbu.",
        "Masak santan dan bumbu hingga mendidih.",
        "Masukkan daging, masak dengan api kecil.",
        "Aduk berkala hingga kuah menyusut dan berminyak."
      ]
    },
    {
      "id": 4,
      "title": "Tumis Kangkung Belacan",
      "description": "Sayur cepat saji dengan aroma belacan yang menggoda.",
      "image": "https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800",
      "author": "Bunda Sari",
      "category": "Sayur",
      "cookMinutes": 10,
      "servings": 2,
      "ingredients": [
        "2 ikat kangkung",
        "1 sdt terasi",
        "3 siung bawang putih",
        "5 buah cabai rawit",
        "Garam dan gula secukupnya"
      ],
      "steps": [
        "Petik dan cuci kangkung.",
        "Tumis bawang putih, cabai, dan terasi.",
        "Masukkan kangkung, aduk dengan api besar 2 menit.",
        "Beri garam dan gula, angkat."
      ]
    },
    {
      "id": 5,
      "title": "Ayam Goreng Kremes",
      "description": "Ayam ungkep gurih dengan kremesan renyah.",
      "image": "https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=800",
      "author": "Mama Dina",
      "category": "Ayam",
      "cookMinutes": 60,
      "servings": 4,
      "ingredients": [
        "1 ekor ayam, potong 8",
        "5 siung bawang putih",
        "1 sdt ketumbar",
        "200 gr tepung beras",
        "Minyak goreng"
      ],
      "steps": [
        "Ungkep ayam bersama bumbu halus hingga empuk.",
        "Campur sisa kuah ungkepan dengan tepung beras.",
        "Goreng ayam, lalu teteskan adonan untuk kremesan.",
        "Tiriskan dan sajikan."
      ]
    },
    {
      "id": 6,
      "title": "Pisang Goreng Crispy",
      "description": "Camilan sore dengan balutan tepung renyah tahan lama.",
      "image": "https://images.unsplash.com/photo-1621939514649-280e2ee25f60?w=800",
      "author": "Kak Lia",
      "category": "Camilan",
      "cookMinutes": 25,
      "servings": 4,
      "ingredients": [
        "6 buah pisang kepok",
        "100 gr tepung terigu",
        "50 gr tepung beras",
        "1 sdm gula pasir",
        "Air es secukupnya"
      ],
      "steps": [
        "Campur tepung, gula, dan air es hingga kental.",
        "Celupkan pisang ke adonan.",
        "Goreng dalam minyak panas hingga keemasan."
      ]
    },
    {
      "id": 7,
      "title": "Es Teler Segar",
      "description": "Es buah santan dengan alpukat, kelapa muda, dan nangka.",
      "image": "https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=800",
      "author": "Kak Lia",
      "category": "Minuman",
      "cookMinutes": 15,
      "servings": 3,
      "ingredients": [
        "1 buah alpukat",
        "1 buah kelapa muda",
        "100 gr nangka",
        "200 ml santan",
        "Sirup dan susu kental manis"
      ],
      "steps": [
        "Potong dadu alpukat, kelapa muda, dan nangka.",
        "Campur dengan santan, sirup, dan susu.",
        "Tambahkan es batu, sajikan dingin."
      ]
    },
    {
      "id": 8,
      "title": "Martabak Manis Bangka",
      "description": "Martabak tebal lembut dengan topping coklat dan keju.",
      "image": "https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800",
      "author": "Uni Rosa",
      "category": "Dessert",
      "cookMinutes": 50,
      "servings": 6,
      "ingredients": [
        "250 gr tepung terigu",
        "1 sdt ragi instan",
        "1 butir telur",
        "1/2 sdt soda kue",
        "Coklat meises, keju, susu kental manis"
      ],
      "steps": [
        "Campur bahan adonan, diamkan 45 menit.",
        "Tambahkan soda kue, tuang ke teflon.",
        "Masak api kecil hingga berlubang.",
        "Beri topping, lipat, potong-potong."
      ]
    },
    {
      "id": 9,
      "title": "Gado-Gado Betawi",
      "description": "Sayuran rebus dengan bumbu kacang kental, lontong, dan kerupuk.",
      "image": "",
      "author": "Mama Dina",
      "category": "Sayur",
      "cookMinutes": 40,
      "servings": 3,
      "ingredients": [
        "2 buah kentang",
        "1 ikat kangkung",
        "100 gr tauge",
        "2 butir telur rebus",
        "150 gr kacang tanah goreng",
        "2 buah cabai rawit",
        "1 sdm gula merah",
        "Lontong dan kerupuk"
      ],
      "steps": [
        "Rebus kentang, kangkung, dan tauge hingga matang.",
        "Haluskan kacang goreng bersama cabai, gula merah, dan garam.",
        "Encerkan bumbu kacang dengan air hangat.",
        "Tata sayuran dan lontong, siram bumbu kacang, beri kerupuk."
      ]
    },
    {
      "id": 10,
      "title": "Sate Ayam Madura",
      "description": "Sate ayam bakar dengan bumbu kacang dan kecap manis.",
      "image": "",
      "author": "Bunda Sari",
      "category": "Ayam",
      "cookMinutes": 60,
      "servings": 4,
      "ingredients": [
        "500 gr daging dada ayam",
        "20 tusuk sate",
        "4 siung bawang merah",
        "3 sdm kecap manis",
        "100 gr kacang tanah goreng",
        "1 buah jeruk nipis"
      ],
      "steps": [
        "Potong dadu ayam, tusuk dengan tusukan sate.",
        "Lumuri ayam dengan kecap dan bawang halus, diamkan 30 menit.",
        "Bakar sambil sesekali dioles bumbu hingga matang.",
        "Sajikan dengan bumbu kacang dan irisan bawang."
      ]
    },
    {
      "id": 11,
      "title": "Klepon Isi Gula Merah",
      "description": "Bola ketan hijau berisi gula merah cair, digulung kelapa parut.",
      "image": "",
      "author": "Kak Lia",
      "category": "Camilan",
      "cookMinutes": 45,
      "servings": 6,
      "ingredients": [
        "200 gr tepung ketan",
        "2 sdm air daun pandan",
        "100 gr gula merah sisir",
        "150 gr kelapa parut",
        "Sejumput garam"
      ],
      "steps": [
        "Campur tepung ketan dengan air pandan hingga kalis.",
        "Bentuk bulat, isi dengan gula merah.",
        "Rebus hingga mengapung, angkat dan tiriskan.",
        "Gulingkan di kelapa parut yang sudah dikukus dengan garam."
      ]
    },
    {
      "id": 12,
      "title": "Bakso Sapi Kuah Segar",
      "description": "Bakso kenyal dengan kuah kaldu sapi yang gurih.",
      "image": "",
      "author": "Uni Rosa",
      "category": "Daging",
      "cookMinutes": 90,
      "servings": 5,
      "ingredients": [
        "500 gr daging sapi giling",
        "100 gr tepung tapioka",
        "4 siung bawang putih",
        "1 butir putih telur",
        "1 liter kaldu sapi",
        "Bihun, sawi, dan bawang goreng"
      ],
      "steps": [
        "Campur daging, tapioka, bawang putih halus, dan putih telur hingga rata.",
        "Bentuk bola-bola, rebus dalam air hangat hingga mengapung.",
        "Didihkan kaldu, masukkan bakso.",
        "Sajikan dengan bihun, sawi, dan bawang goreng."
      ]
    }
  ]
};
