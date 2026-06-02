import 'package:injectable/injectable.dart';
import '../../domain/entities/news_entry.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_datasource.dart';

@LazySingleton(as: NewsRepository)
class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource _remoteDataSource;

  NewsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<NewsEntry>> getNews() async {
    final newsMaps = await _remoteDataSource.getNews();
    return newsMaps.map((map) => NewsEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      source: map['source'],
      date: map['date'],
      tag: map['tag'],
      category: map['category'],
    )).toList();
  }
}
