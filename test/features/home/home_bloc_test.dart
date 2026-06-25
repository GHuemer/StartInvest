import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:startinvest/features/home/domain/entities/challenge.dart';
import 'package:startinvest/features/home/domain/repositories/home_repository.dart';
import 'package:startinvest/features/home/presentation/bloc/home_bloc.dart';
import 'package:startinvest/features/home/presentation/bloc/home_event.dart';
import 'package:startinvest/features/home/presentation/bloc/home_state.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late MockHomeRepository repository;

  const challenge = Challenge(
    id: 'ch1',
    tag: 'tag',
    title: 'Desafio',
    description: 'desc',
    points: 100,
  );

  setUp(() => repository = MockHomeRepository());

  HomeBloc build() => HomeBloc(homeRepository: repository);

  test('estado inicial', () {
    expect(build().state, const HomeState());
  });

  blocTest<HomeBloc, HomeState>(
    'HomeStarted emite [loading, success] com o desafio diario',
    setUp: () => when(() => repository.getDailyChallenge())
        .thenAnswer((_) async => challenge),
    build: build,
    act: (bloc) => bloc.add(HomeStarted()),
    expect: () => [
      const HomeState(status: HomeStatus.loading),
      const HomeState(status: HomeStatus.success, dailyChallenge: challenge),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'HomeRefreshRequested recarrega os dados',
    setUp: () => when(() => repository.getDailyChallenge())
        .thenAnswer((_) async => challenge),
    build: build,
    act: (bloc) => bloc.add(HomeRefreshRequested()),
    expect: () => [
      const HomeState(status: HomeStatus.loading),
      const HomeState(status: HomeStatus.success, dailyChallenge: challenge),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'emite [loading, failure] quando o repositorio lanca erro',
    setUp: () =>
        when(() => repository.getDailyChallenge()).thenThrow(Exception('x')),
    build: build,
    act: (bloc) => bloc.add(HomeStarted()),
    expect: () => [
      const HomeState(status: HomeStatus.loading),
      isA<HomeState>().having((s) => s.status, 'status', HomeStatus.failure),
    ],
  );
}
