import '../utils/time_ago.dart';

class Comment {
  final String user;
  final String text;
  final String date;

  Comment({required this.user, required this.text, required this.date});

  /// Dari respons API: { user, text, created_at }.
  factory Comment.fromJson(Map<String, dynamic> json) {
    final created = DateTime.tryParse('${json['created_at']}');
    return Comment(
      user: json['user'] ?? '',
      text: json['text'] ?? '',
      date: created == null ? '' : timeAgo(created),
    );
  }
}

class Recipe {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String author;
  final int authorId;
  final String category;
  final int cookMinutes;
  final int servings;
  final List<String> ingredients;
  final List<String> steps;
  final List<Comment> comments;
  bool isFavorite;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.author,
    this.authorId = 0,
    required this.category,
    required this.cookMinutes,
    required this.servings,
    required this.ingredients,
    required this.steps,
    List<Comment>? comments,
    this.isFavorite = false,
  }) : comments = comments ?? [];

  /// Dari respons REST API (lihat backend: GET /api/recipes).
  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        imageUrl: json['image_url'] ?? '',
        author: json['author'] ?? '',
        authorId: json['author_id'] ?? 0,
        category: json['category'] ?? 'Lainnya',
        cookMinutes: json['cook_minutes'] ?? 0,
        servings: json['servings'] ?? 1,
        ingredients: List<String>.from(json['ingredients'] ?? []),
        steps: List<String>.from(json['steps'] ?? []),
        comments: ((json['comments'] ?? []) as List)
            .map((c) => Comment.fromJson(c as Map<String, dynamic>))
            .toList(),
        isFavorite: json['is_favorite'] ?? false,
      );
}
