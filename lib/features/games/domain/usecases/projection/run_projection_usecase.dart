import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/position.dart';
import '../../entities/simulation_result.dart';
import '../../repositories/portfolio_repository.dart';

@injectable
class RunProjectionUseCase {
  final PortfolioRepository _repository;

  RunProjectionUseCase(this._repository);

  static const List<(int, String)> periods = [
    (1, '1 mês'),
    (3, '3 meses'),
    (6, '6 meses'),
    (12, '1 ano'),
    (24, '2 anos'),
    (60, '5 anos'),
    (120, '10 anos'),
    (240, '20 anos'),
    (600, '50 anos'),
  ];

  Future<Either<Failure, SimulationResult>> call({
    required List<ProjectionAssetInput> assets,
    required int periodMonths,
    required String periodLabel,
  }) async {
    if (assets.isEmpty) {
      return const Left(ServerFailure('Adicione pelo menos um ativo.'));
    }

    final projections = <AssetProjection>[];

    for (final input in assets) {
      final cagrResult = await _repository.getHistoricalCagr(
        input.ticker,
        input.assetType,
      );
      final cagr = cagrResult.fold(
        (_) => _defaultCagr(input.assetType),
        (c) => c,
      );

      final points = _generatePoints(input.amount, cagr, periodMonths);
      projections.add(
        AssetProjection(
          ticker: input.ticker,
          name: input.name,
          assetType: input.assetType,
          investedAmount: input.amount,
          annualRate: cagr,
          dataPoints: points,
        ),
      );
    }

    final maxLen = projections.map((p) => p.dataPoints.length).reduce(max);
    final consolidated = List.generate(maxLen, (i) {
      return projections.fold(0.0, (sum, p) {
        final v = i < p.dataPoints.length ? p.dataPoints[i] : p.projectedValue;
        return sum + v;
      });
    });

    await _repository.awardXp(5);

    final simulation = SimulationResult(
      assets: projections,
      periodMonths: periodMonths,
      periodLabel: periodLabel,
      consolidatedPoints: consolidated,
    );

    // Fire-and-forget: falha de persistência não bloqueia o resultado
    _repository.saveProjectionHistory(simulation);

    return Right(simulation);
  }

  List<double> _generatePoints(double amount, double cagr, int periodMonths) {
    if (periodMonths <= 12) {
      final monthlyRate = pow(1 + cagr, 1 / 12).toDouble() - 1;
      return List.generate(
        periodMonths + 1,
        (m) => amount * pow(1 + monthlyRate, m),
      );
    } else {
      final years = (periodMonths / 12).round();
      return List.generate(
        years + 1,
        (y) => amount * pow(1 + cagr, y).toDouble(),
      );
    }
  }

  double _defaultCagr(AssetType type) => switch (type) {
    AssetType.stock => 0.12,
    AssetType.fii => 0.08,
    AssetType.fixedIncome => 0.1375,
  };
}
