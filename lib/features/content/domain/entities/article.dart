import 'package:equatable/equatable.dart';

class Article extends Equatable {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String author;
  final String readingTime;
  final DateTime publishedAt;

  const Article({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.readingTime,
    required this.publishedAt,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        imageUrl,
        author,
        readingTime,
        publishedAt,
      ];
}
