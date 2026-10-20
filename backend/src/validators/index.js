const { z } = require('zod');

const trimmed = (min, max, label) =>
  z.string({ required_error: `${label} wajib diisi`, invalid_type_error: `${label} harus berupa teks` })
    .trim()
    .min(min, min === 1 ? `${label} wajib diisi` : `${label} minimal ${min} karakter`)
    .max(max, `${label} maksimal ${max} karakter`);

const listOfText = (label, max) =>
  z.array(trimmed(1, max, label), { required_error: `${label} wajib diisi` })
    .transform((arr) => arr.filter((s) => s.length > 0))
    .refine((arr) => arr.length >= 1, `${label} minimal 1 item`)
    .refine((arr) => arr.length <= 100, `${label} maksimal 100 item`);

exports.idParam = z.object({ id: z.coerce.number().int().positive('ID tidak valid') });

exports.register = z.object({
  name: trimmed(2, 100, 'Nama'),
  email: z.string({ required_error: 'Email wajib diisi' }).trim().toLowerCase().email('Format email tidak valid').max(255),
  password: z.string({ required_error: 'Password wajib diisi' }).min(6, 'Password minimal 6 karakter').max(72, 'Password maksimal 72 karakter'),
});

exports.login = z.object({
  email: z.string({ required_error: 'Email wajib diisi' }).trim().toLowerCase().email('Format email tidak valid'),
  password: z.string({ required_error: 'Password wajib diisi' }).min(1, 'Password wajib diisi'),
});

const recipeFields = {
  title: trimmed(3, 150, 'Judul'),
  description: z.string().trim().max(2000, 'Deskripsi maksimal 2000 karakter'),
  category: trimmed(1, 50, 'Kategori'),
  cook_minutes: z.coerce.number().int('Waktu masak harus bilangan bulat').min(0).max(10000),
  servings: z.coerce.number().int('Porsi harus bilangan bulat').min(1, 'Porsi minimal 1').max(1000),
  image_url: z.string().trim().max(500),
  ingredients: listOfText('Bahan', 300),
  steps: listOfText('Langkah', 2000),
};

exports.recipeCreate = z.object({
  title: recipeFields.title,
  description: recipeFields.description.default(''),
  category: recipeFields.category,
  cook_minutes: recipeFields.cook_minutes.default(0),
  servings: recipeFields.servings.default(1),
  image_url: recipeFields.image_url.default(''),
  ingredients: recipeFields.ingredients,
  steps: recipeFields.steps,
});

exports.recipeUpdate = z.object({
  title: recipeFields.title.optional(),
  description: recipeFields.description.optional(),
  category: recipeFields.category.optional(),
  cook_minutes: recipeFields.cook_minutes.optional(),
  servings: recipeFields.servings.optional(),
  image_url: recipeFields.image_url.optional(),
  ingredients: recipeFields.ingredients.optional(),
  steps: recipeFields.steps.optional(),
}).refine((o) => Object.keys(o).length > 0, 'Minimal satu field harus diubah');

exports.recipeList = z.object({
  q: z.string().trim().max(100).optional(),
  category: z.string().trim().max(50).optional(),
  author_id: z.coerce.number().int().positive().optional(),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

exports.comment = z.object({ text: trimmed(1, 1000, 'Komentar') });

exports.profileUpdate = z.object({
  name: trimmed(2, 100, 'Nama').optional(),
  bio: z.string().trim().max(500).optional(),
  avatar_url: z.string().trim().max(500).optional(),
}).refine((o) => Object.keys(o).length > 0, 'Minimal satu field harus diubah');
