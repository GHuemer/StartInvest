import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:startinvest/features/missions/domain/entities/mission_entity.dart';
import 'package:startinvest/features/missions/domain/repositories/missions_repository.dart';
import 'package:startinvest/features/missions/presentation/bloc/missions_cubit.dart';
import 'package:startinvest/features/missions/presentation/bloc/missions_state.dart';

class MockMissionsRepository extends Mock implements MissionsRepository {}

void main() {
  late MockMissionsRepository repository;

  MissionEntity mission(String id,
          {int requiredLevel = 0,
          int requiredCourses = 0,
          MissionCategory category = MissionCategory.learning}) =>
      MissionEntity(
        id: id,
        title: 'Missao $id',
        description: 'desc',
        icon: Icons.star,
        category: category,
        requiredLevel: requiredLevel,
        requiredCourses: requiredCourses,
      );

  setUp(() => repository = MockMissionsRepository());

  MissionsCubit build() => MissionsCubit(repository);

  group('init', () {
    blocTest<MissionsCubit, MissionsState>(
      'marca missao como completed quando esta na lista de completas',
      setUp: () {
        when(() => repository.getMissions())
            .thenAnswer((_) async => [mission('1'), mission('2')]);
        when(() => repository.getUserProgress()).thenAnswer((_) async => {
              'level': 5,
              'completedCoursesCount': 0,
              'completedMissionsIds': ['1'],
            });
      },
      build: build,
      act: (cubit) => cubit.init(),
      verify: (cubit) {
        final completed =
            cubit.state.allMissions.firstWhere((m) => m.id == '1');
        expect(completed.status, MissionStatus.completed);
        expect(cubit.state.completedCount, 1);
        expect(cubit.state.isLoading, false);
      },
    );

    blocTest<MissionsCubit, MissionsState>(
      'bloqueia missao quando nivel do usuario e insuficiente',
      setUp: () {
        when(() => repository.getMissions())
            .thenAnswer((_) async => [mission('1', requiredLevel: 99)]);
        when(() => repository.getUserProgress())
            .thenAnswer((_) async => {'level': 1});
      },
      build: build,
      act: (cubit) => cubit.init(),
      verify: (cubit) {
        expect(cubit.state.allMissions.single.status, MissionStatus.locked);
      },
    );

    blocTest<MissionsCubit, MissionsState>(
      'calcula progresso parcial da missao 2 (cursos)',
      setUp: () {
        when(() => repository.getMissions())
            .thenAnswer((_) async => [mission('2')]);
        when(() => repository.getUserProgress()).thenAnswer((_) async => {
              'level': 5,
              'completedCoursesCount': 2,
            });
      },
      build: build,
      act: (cubit) => cubit.init(),
      verify: (cubit) {
        final m = cubit.state.allMissions.single;
        expect(m.status, MissionStatus.available);
        expect(m.progress, closeTo(2 / 5, 0.0001));
      },
    );

    blocTest<MissionsCubit, MissionsState>(
      'emite isLoading false quando o repositorio lanca erro',
      setUp: () =>
          when(() => repository.getMissions()).thenThrow(Exception('erro')),
      build: build,
      act: (cubit) => cubit.init(),
      verify: (cubit) => expect(cubit.state.isLoading, false),
    );
  });

  group('filterMissions', () {
    blocTest<MissionsCubit, MissionsState>(
      'filtra por categoria practice',
      setUp: () {
        when(() => repository.getMissions()).thenAnswer((_) async => [
              mission('1', category: MissionCategory.learning),
              mission('2', category: MissionCategory.practice),
            ]);
        when(() => repository.getUserProgress())
            .thenAnswer((_) async => {'level': 5});
      },
      build: build,
      act: (cubit) async {
        await cubit.init();
        cubit.filterMissions(MissionCategory.practice);
      },
      verify: (cubit) {
        expect(cubit.state.activeFilter, MissionCategory.practice);
        expect(cubit.state.filteredMissions.length, 1);
        expect(cubit.state.filteredMissions.single.category,
            MissionCategory.practice);
      },
    );
  });

  test('totalProgress e zero quando nao ha missoes', () {
    expect(const MissionsState().totalProgress, 0);
  });
}
