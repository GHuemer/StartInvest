import '../../domain/entities/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.content,
    required super.author,
    required super.readingTime,
    required super.publishedAt,
    super.imageUrl,
  });

  factory ArticleModel.fromMap(Map<String, dynamic> map, String id) {
    return ArticleModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      author: map['author'] ?? '',
      readingTime: map['readingTime'] ?? '',
      publishedAt: map['publishedAt'] != null
          ? DateTime.parse(map['publishedAt'])
          : DateTime.now(),
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'author': author,
      'readingTime': readingTime,
      'publishedAt': publishedAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}
