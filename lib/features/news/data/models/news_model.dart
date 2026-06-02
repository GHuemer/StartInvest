import '../../domain/entities/news_entry.dart';

class NewsModel extends NewsEntry {
  const NewsModel({
    required super.id,
    required super.title,
    required super.content,
    required super.source,
    required super.date,
    required super.tag,
    required super.category,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      source: json['source'] as String,
      date: json['date'] as String,
      tag: json['tag'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'source': source,
      'date': date,
      'tag': tag,
      'category': category,
    };
  }
}
