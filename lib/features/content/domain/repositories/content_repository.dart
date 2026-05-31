import '../entities/article.dart';
import '../entities/course.dart';

abstract class ContentRepository {
  Future<List<Article>> getArticles();
  Future<List<Course>> getCourses();
}
