import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:startinvest/features/content/domain/entities/article.dart';
import 'package:startinvest/features/content/domain/entities/course.dart';
import 'package:startinvest/features/content/domain/repositories/content_repository.dart';
import 'package:startinvest/features/content/presentation/bloc/content_bloc.dart';
import 'package:startinvest/features/content/presentation/bloc/content_event.dart';
import 'package:startinvest/features/content/presentation/bloc/content_state.dart';

class MockContentRepository extends Mock implements ContentRepository {}

void main() {
  late MockContentRepository repository;

  final articles = [
    Article(
      id: 'a1',
      title: 'T',
      content: 'C',
      author: 'A',
      readingTime: '5 min',
      publishedAt: DateTime(2024),
    ),
  ];
  const courses = [Course(id: 'c1', title: 'Curso')];

  setUp(() => repository = MockContentRepository());

  ContentBloc build() => ContentBloc(contentRepository: repository);

  test('estado inicial', () {
    expect(build().state, const ContentState());
  });

  blocTest<ContentBloc, ContentState>(
    'emite [loading, success] ao carregar artigos e cursos',
    setUp: () {
      when(() => repository.getArticles()).thenAnswer((_) async => articles);
      when(() => repository.getCourses()).thenAnswer((_) async => courses);
    },
    build: build,
    act: (bloc) => bloc.add(ContentStarted()),
    expect: () => [
      const ContentState(status: ContentStatus.loading),
      ContentState(
        status: ContentStatus.success,
        articles: articles,
        courses: courses,
      ),
    ],
  );

  blocTest<ContentBloc, ContentState>(
    'emite [loading, failure] quando o repositorio lanca erro',
    setUp: () {
      when(() => repository.getArticles()).thenThrow(Exception('falhou'));
      when(() => repository.getCourses()).thenAnswer((_) async => courses);
    },
    build: build,
    act: (bloc) => bloc.add(ContentStarted()),
    expect: () => [
      const ContentState(status: ContentStatus.loading),
      isA<ContentState>()
          .having((s) => s.status, 'status', ContentStatus.failure),
    ],
  );
}
