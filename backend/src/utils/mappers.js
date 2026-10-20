/** Mengubah baris database menjadi JSON yang dibaca frontend (Recipe.fromJson). */
exports.user = (row) => ({
  id: row.id,
  name: row.name,
  email: row.email,
  avatar_url: row.avatar_url || '',
  bio: row.bio || '',
  created_at: row.created_at,
});

exports.recipe = (row) => ({
  id: row.id,
  title: row.title,
  description: row.description,
  image_url: row.image_url,
  author: row.author,
  author_id: row.author_id,
  category: row.category,
  cook_minutes: row.cook_minutes,
  servings: row.servings,
  ingredients: row.ingredients,
  steps: row.steps,
  comments: row.comments,
  is_favorite: row.is_favorite,
  created_at: row.created_at,
  updated_at: row.updated_at,
});

exports.comment = (row) => ({
  id: row.id,
  recipe_id: row.recipe_id,
  user_id: row.user_id,
  user: row.user_name,
  text: row.content,
  created_at: row.created_at,
});
