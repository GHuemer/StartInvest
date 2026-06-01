import 'package:equatable/equatable.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/course.dart';

enum ContentStatus { initial, loading, success, failure }

class ContentState extends Equatable {
  final ContentStatus status;
  final List<Article> articles;
  final List<Course> courses;
  final String? errorMessage;

  const ContentState({
    this.status = ContentStatus.initial,
    this.articles = const [],
    this.courses = const [],
    this.errorMessage,
  });

  ContentState copyWith({
    ContentStatus? status,
    List<Article>? articles,
    List<Course>? courses,
    String? errorMessage,
  }) {
    return ContentState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      courses: courses ?? this.courses,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, articles, courses, errorMessage];
}
