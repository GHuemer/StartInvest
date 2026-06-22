import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:startinvest/core/error/failures.dart';
import 'package:startinvest/features/games/domain/entities/position.dart';
import 'package:startinvest/features/games/domain/entities/simulation_result.dart';
import 'package:startinvest/features/games/domain/repositories/portfolio_repository.dart';
import 'package:startinvest/features/games/domain/usecases/projection/run_projection_usecase.dart';

class MockPortfolioRepository extends Mock implements PortfolioRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(AssetType.stock);
    registerFallbackValue(const SimulationResult(
      assets: [],
      periodMonths: 0,
      periodLabel: '',
      consolidatedPoints: [],
    ));
  });

  late RunProjectionUseCase useCase;
  late MockPortfolioRepository mockRepository;

  final tAsset = const ProjectionAssetInput(
    ticker: 'PETR4',
    name: 'Petrobras',
    assetType: AssetType.stock,
    amount: 1000.0,
  );

  setUp(() {
    mockRepository = MockPortfolioRepository();
    useCase = RunProjectionUseCase(mockRepository);

    // Comportamento padrão: CAGR histórico falha → usa CAGR padrão
    when(() => mockRepository.getHistoricalCagr(any(), any()))
        .thenAnswer((_) async => const Left(ServerFailure()));
    when(() => mockRepository.awardXp(any()))
        .thenAnswer((_) async => const Right(null));
    when(() => mockRepository.saveProjectionHistory(any()))
        .thenAnswer((_) async => const Right(null));
  });

  group('RunProjectionUseCase - validação de entrada', () {
    test('deve retornar ServerFailure quando lista de ativos estiver vazia', () async {
      final result = await useCase(
        assets: [],
        periodMonths: 12,
        periodLabel: '1 ano',
      );

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f.message, 'Adicione pelo menos um ativo.'),
        (_) => fail('deveria ter retornado Left'),
      );
      verifyNever(() => mockRepository.awardXp(any()));
    });
  });

  group('RunProjectionUseCase - granularidade mensal (≤ 12 meses)', () {
    test('deve gerar periodMonths + 1 pontos para 1 mês', () async {
      final result = await useCase(
        assets: [tAsset],
        periodMonths: 1,
        periodLabel: '1 mês',
      );

      expect(result.isRight(), true);
      result.fold((_) {}, (sim) {
        expect(sim.assets.first.dataPoints.length, 2); // mês 0 + mês 1
        expect(sim.isYearly, false);
      });
    });

    test('deve gerar 13 pontos para 12 meses', () async {
      final result = await useCase(
        assets: [tAsset],
        periodMonths: 12,
        periodLabel: '1 ano',
      );

      expect(result.isRight(), true);
      result.fold((_) {}, (sim) {
        expect(sim.assets.first.dataPoints.length, 13); // mês 0 a 12
        expect(sim.isYearly, false);
      });
    });
  });

  group('RunProjectionUseCase - granularidade anual (> 12 meses)', () {
    test('deve gerar 3 pontos para 24 meses (2 anos)', () async {
      final result = await useCase(
        assets: [tAsset],
        periodMonths: 24,
        periodLabel: '2 anos',
      );

      expect(result.isRight(), true);
      result.fold((_) {}, (sim) {
        expect(sim.assets.first.dataPoints.length, 3); // ano 0, 1, 2
        expect(sim.isYearly, true);
      });
    });

    test('deve gerar 11 pontos para 120 meses (10 anos)', () async {
      final result = await useCase(
        assets: [tAsset],
        periodMonths: 120,
        periodLabel: '10 anos',
      );

      expect(result.isRight(), true);
      result.fold((_) {}, (sim) {
        expect(sim.assets.first.dataPoints.length, 11); // ano 0 a 10
        expect(sim.isYearly, true);
      });
    });
  });

  group('RunProjectionUseCase - CAGR padrão', () {
    test('deve usar CAGR 12% para ações quando histórico não disponível', () async {
      final result = await useCase(
        assets: [tAsset],
        periodMonths: 12,
        periodLabel: '1 ano',
      );

      expect(result.isRight(), true);
      result.fold((_) {}, (sim) {
        expect(sim.assets.first.annualRate, 0.12);
      });
    });

    test('deve usar CAGR 8% para FIIs quando histórico não disponível', () async {
      final fiiAsset = const ProjectionAssetInput(
        ticker: 'HGLG11',
        name: 'CSHG Logística',
        assetType: AssetType.fii,
        amount: 1000.0,
      );

      final result = await useCase(
        assets: [fiiAsset],
        periodMonths: 12,
        periodLabel: '1 ano',
      );

      expect(result.isRight(), true);
      result.fold((_) {}, (sim) {
        expect(sim.assets.first.annualRate, 0.08);
      });
    });

    test('deve usar CAGR 13.75% para renda fixa quando histórico não disponível', () async {
      final fixedAsset = const ProjectionAssetInput(
        ticker: 'TESOURO',
        name: 'Tesouro Selic',
        assetType: AssetType.fixedIncome,
        amount: 1000.0,
      );

      final result = await useCase(
        assets: [fixedAsset],
        periodMonths: 12,
        periodLabel: '1 ano',
      );

      expect(result.isRight(), true);
      result.fold((_) {}, (sim) {
        expect(sim.assets.first.annualRate, 0.1375);
      });
    });
  });

  group('RunProjectionUseCase - XP e persistência', () {
    test('deve conceder 5 XP ao executar simulação', () async {
      await useCase(
        assets: [tAsset],
        periodMonths: 12,
        periodLabel: '1 ano',
      );

      verify(() => mockRepository.awardXp(5)).called(1);
    });

    test('não deve bloquear resultado se saveProjectionHistory falhar', () async {
      when(() => mockRepository.saveProjectionHistory(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Erro ao salvar')));

      final result = await useCase(
        assets: [tAsset],
        periodMonths: 12,
        periodLabel: '1 ano',
      );

      expect(result.isRight(), true);
    });
  });

  group('RunProjectionUseCase - múltiplos ativos', () {
    test('deve consolidar pontos de dois ativos corretamente', () async {
      final asset2 = const ProjectionAssetInput(
        ticker: 'VALE3',
        name: 'Vale',
        assetType: AssetType.stock,
        amount: 500.0,
      );

      final result = await useCase(
        assets: [tAsset, asset2],
        periodMonths: 1,
        periodLabel: '1 mês',
      );

      expect(result.isRight(), true);
      result.fold((_) {}, (sim) {
        expect(sim.assets.length, 2);
        // ponto inicial consolidado deve ser soma dos investimentos
        expect(sim.consolidatedPoints.first, closeTo(1500.0, 0.01));
      });
    });
  });
}
