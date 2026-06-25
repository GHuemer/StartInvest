import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:startinvest/features/news/domain/entities/news_entry.dart';
import 'package:startinvest/features/news/domain/repositories/news_repository.dart';
import 'package:startinvest/features/news/presentation/bloc/news_cubit.dart';
import 'package:startinvest/features/news/presentation/bloc/news_state.dart';

class MockNewsRepository extends Mock implements NewsRepository {}

void main() {
  late MockNewsRepository repository;

  const techNews = NewsEntry(
    id: '1',
    title: 'Bitcoin sobe',
    content: 'c',
    source: 's',
    date: 'hoje',
    tag: 'cripto',
    category: 'tech',
  );
  const economyNews = NewsEntry(
    id: '2',
    title: 'Selic mantida',
    content: 'c',
    source: 's',
    date: 'hoje',
    tag: 'juros',
    category: 'economy',
  );

  setUp(() => repository = MockNewsRepository());

  NewsCubit build() => NewsCubit(repository);

  blocTest<NewsCubit, NewsState>(
    'init emite [NewsLoading, NewsLoaded]',
    setUp: () => when(() => repository.getNews())
        .thenAnswer((_) async => [techNews, economyNews]),
    build: build,
    act: (cubit) => cubit.init(),
    expect: () => [
      isA<NewsLoading>(),
      isA<NewsLoaded>()
          .having((s) => s.allNews.length, 'allNews', 2)
          .having((s) => s.filteredNews.length, 'filteredNews', 2),
    ],
  );

  blocTest<NewsCubit, NewsState>(
    'init emite [NewsLoading, NewsError] em caso de erro',
    setUp: () => when(() => repository.getNews()).thenThrow(Exception('x')),
    build: build,
    act: (cubit) => cubit.init(),
    expect: () => [isA<NewsLoading>(), isA<NewsError>()],
  );

  blocTest<NewsCubit, NewsState>(
    'selectCategory filtra pela categoria escolhida',
    setUp: () => when(() => repository.getNews())
        .thenAnswer((_) async => [techNews, economyNews]),
    build: build,
    act: (cubit) async {
      await cubit.init();
      cubit.selectCategory('Tech');
    },
    skip: 2,
    expect: () => [
      isA<NewsLoaded>()
          .having((s) => s.selectedCategory, 'categoria', 'Tech')
          .having((s) => s.filteredNews.single.category, 'filtrado', 'tech'),
    ],
  );

  blocTest<NewsCubit, NewsState>(
    'searchNews filtra pelo titulo',
    setUp: () => when(() => repository.getNews())
        .thenAnswer((_) async => [techNews, economyNews]),
    build: build,
    act: (cubit) async {
      await cubit.init();
      cubit.searchNews('bitcoin');
    },
    skip: 2,
    expect: () => [
      isA<NewsLoaded>()
          .having((s) => s.filteredNews.single.id, 'id', '1')
          .having((s) => s.searchQuery, 'query', 'bitcoin'),
    ],
  );
}
