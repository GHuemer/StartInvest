import '../entities/news_entry.dart';

abstract class NewsRepository {
  Future<List<NewsEntry>> getNews();
}
