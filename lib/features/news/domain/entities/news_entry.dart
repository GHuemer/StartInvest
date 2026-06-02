import 'package:equatable/equatable.dart';

class NewsEntry extends Equatable {
  final String id;
  final String title;
  final String content;
  final String source;
  final String date;
  final String tag;
  final String category;

  const NewsEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.source,
    required this.date,
    required this.tag,
    required this.category,
  });

  @override
  List<Object?> get props => [id, title, content, source, date, tag, category];
}
