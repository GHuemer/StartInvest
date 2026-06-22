import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:startinvest/core/error/failures.dart';
import 'package:startinvest/features/games/domain/entities/position.dart';
import 'package:startinvest/features/games/domain/entities/simulation_result.dart';
import 'package:startinvest/features/games/domain/repositories/portfolio_repository.dart';
import 'package:startinvest/features/games/domain/usecases/projection/run_projection_usecase.dart';
import 'package:startinvest/features/games/presentation/bloc/projection/projection_bloc.dart';
import 'package:startinvest/features/games/presentation/bloc/projection/projection_event.dart';
import 'package:startinvest/features/games/presentation/bloc/projection/projection_state.dart';

class MockRunProjectionUseCase extends Mock implements RunProjectionUseCase {}
class MockPortfolioRepository extends Mock implements PortfolioRepository {}

const tAsset = ProjectionAssetInput(
  ticker: 'PETR4',
  name: 'Petrobras',
  assetType: AssetType.stock,
  amount: 1000.0,
);

SimulationResult _makeResult() => SimulationResult(
      assets: [
        const AssetProjection(
          ticker: 'PETR4',
          name: 'Petrobras',
          assetType: AssetType.stock,
          investedAmount: 1000.0,
          annualRate: 0.12,
          dataPoints: [1000.0, 1120.0, 1254.4],
        ),
      ],
      periodMonths: 24,
      periodLabel: '2 anos',
      consolidatedPoints: [1000.0, 1120.0, 1254.4],
    );

void main() {
  late ProjectionBloc bloc;
  late MockRunProjectionUseCase mockRunProjection;
  late MockPortfolioRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(AssetType.stock);
    registerFallbackValue(<ProjectionAssetInput>[]);
    registerFallbackValue(
      SimulationResult(
        assets: const [],
        periodMonths: 0,
        periodLabel: '',
        consolidatedPoints: const [],
      ),
    );
  });

  setUp(() {
    mockRunProjection = MockRunProjectionUseCase();
    mockRepository = MockPortfolioRepository();
    bloc = ProjectionBloc(mockRunProjection, mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  test('estado inicial deve ser ProjectionSetup com lista vazia e 5 anos', () {
    expect(bloc.state, isA<ProjectionSetup>());
    expect(bloc.state.assets, isEmpty);
    expect(bloc.state.periodMonths, 60);
  });

  group('AddProjectionAsset', () {
    blocTest<ProjectionBloc, ProjectionState>(
      'deve adicionar ativo quando ticker ainda não está na lista',
      build: () => bloc,
      act: (b) => b.add(const AddProjectionAsset(tAsset)),
      expect: () => [
        isA<ProjectionSetup>()
            .having((s) => s.assets.length, 'assets.length', 1)
            .having((s) => s.assets.first.ticker, 'ticker', 'PETR4'),
      ],
    );

    blocTest<ProjectionBloc, ProjectionState>(
      'deve ignorar ativo duplicado (mesmo ticker)',
      build: () => bloc,
      seed: () => ProjectionSetup(
        assets: const [tAsset],
        periodMonths: 60,
        periodLabel: '5 anos',
      ),
      act: (b) => b.add(const AddProjectionAsset(tAsset)),
      expect: () => [], // nenhuma mudança de estado
    );
  });

  group('RemoveProjectionAsset', () {
    blocTest<ProjectionBloc, ProjectionState>(
      'deve remover ativo pelo ticker',
      build: () => bloc,
      seed: () => ProjectionSetup(
        assets: const [tAsset],
        periodMonths: 60,
        periodLabel: '5 anos',
      ),
      act: (b) => b.add(const RemoveProjectionAsset('PETR4')),
      expect: () => [
        isA<ProjectionSetup>().having((s) => s.assets, 'assets', isEmpty),
      ],
    );
  });

  group('UpdateProjectionAmount', () {
    blocTest<ProjectionBloc, ProjectionState>(
      'deve atualizar o valor investido no ativo',
      build: () => bloc,
      seed: () => ProjectionSetup(
        assets: const [tAsset],
        periodMonths: 60,
        periodLabel: '5 anos',
      ),
      act: (b) => b.add(const UpdateProjectionAmount('PETR4', 2000.0)),
      expect: () => [
        isA<ProjectionSetup>().having(
          (s) => s.assets.first.amount,
          'assets.first.amount',
          2000.0,
        ),
      ],
    );
  });

  group('SelectProjectionPeriod', () {
    blocTest<ProjectionBloc, ProjectionState>(
      'deve atualizar o período de projeção',
      build: () => bloc,
      act: (b) => b.add(const SelectProjectionPeriod(12, '1 ano')),
      expect: () => [
        isA<ProjectionSetup>()
            .having((s) => s.periodMonths, 'periodMonths', 12)
            .having((s) => s.periodLabel, 'periodLabel', '1 ano'),
      ],
    );
  });

  group('RunSimulation', () {
    blocTest<ProjectionBloc, ProjectionState>(
      'deve emitir [ProjectionLoading, ProjectionComplete] em caso de sucesso',
      build: () {
        when(() => mockRunProjection(
              assets: any(named: 'assets'),
              periodMonths: any(named: 'periodMonths'),
              periodLabel: any(named: 'periodLabel'),
            )).thenAnswer((_) async => Right(_makeResult()));
        return bloc;
      },
      seed: () => ProjectionSetup(
        assets: const [tAsset],
        periodMonths: 24,
        periodLabel: '2 anos',
      ),
      act: (b) => b.add(const RunSimulation()),
      expect: () => [
        isA<ProjectionLoading>(),
        isA<ProjectionComplete>(),
      ],
    );

    blocTest<ProjectionBloc, ProjectionState>(
      'deve emitir [ProjectionLoading, ProjectionError] em caso de falha',
      build: () {
        when(() => mockRunProjection(
              assets: any(named: 'assets'),
              periodMonths: any(named: 'periodMonths'),
              periodLabel: any(named: 'periodLabel'),
            )).thenAnswer(
          (_) async => const Left(ServerFailure('Adicione pelo menos um ativo.')),
        );
        return bloc;
      },
      act: (b) => b.add(const RunSimulation()),
      expect: () => [
        isA<ProjectionLoading>(),
        isA<ProjectionError>().having(
          (s) => s.message,
          'message',
          'Adicione pelo menos um ativo.',
        ),
      ],
    );
  });

  group('LoadProjectionHistory', () {
    blocTest<ProjectionBloc, ProjectionState>(
      'deve emitir ProjectionHistoryLoaded em caso de sucesso',
      build: () {
        when(() => mockRepository.getProjectionHistory())
            .thenAnswer((_) async => Right([_makeResult()]));
        return bloc;
      },
      act: (b) => b.add(const LoadProjectionHistory()),
      expect: () => [
        isA<ProjectionHistoryLoaded>().having(
          (s) => s.history.length,
          'history.length',
          1,
        ),
      ],
    );

    blocTest<ProjectionBloc, ProjectionState>(
      'deve emitir ProjectionError em caso de falha',
      build: () {
        when(() => mockRepository.getProjectionHistory())
            .thenAnswer((_) async => const Left(ServerFailure('Sem histórico')));
        return bloc;
      },
      act: (b) => b.add(const LoadProjectionHistory()),
      expect: () => [
        isA<ProjectionError>().having(
          (s) => s.message,
          'message',
          'Sem histórico',
        ),
      ],
    );
  });
}
