import 'package:equatable/equatable.dart';
import 'position.dart';

class ProjectionAssetInput extends Equatable {
  final String ticker;
  final String name;
  final AssetType assetType;
  final double amount;

  const ProjectionAssetInput({
    required this.ticker,
    required this.name,
    required this.assetType,
    required this.amount,
  });

  ProjectionAssetInput copyWith({double? amount}) => ProjectionAssetInput(
    ticker: ticker,
    name: name,
    assetType: assetType,
    amount: amount ?? this.amount,
  );

  @override
  List<Object?> get props => [ticker, assetType, amount];
}

class AssetProjection extends Equatable {
  final String ticker;
  final String name;
  final AssetType assetType;
  final double investedAmount;
  final double annualRate;
  final List<double> dataPoints;

  const AssetProjection({
    required this.ticker,
    required this.name,
    required this.assetType,
    required this.investedAmount,
    required this.annualRate,
    required this.dataPoints,
  });

  double get projectedValue =>
      dataPoints.isNotEmpty ? dataPoints.last : investedAmount;
  double get absoluteGain => projectedValue - investedAmount;
  double get gainPercent => investedAmount > 0
      ? (projectedValue - investedAmount) / investedAmount * 100
      : 0;

  @override
  List<Object?> get props => [ticker, investedAmount, annualRate, dataPoints];
}

class SimulationResult extends Equatable {
  final List<AssetProjection> assets;
  final int periodMonths;
  final String periodLabel;
  final List<double> consolidatedPoints;
  final DateTime? createdAt;

  const SimulationResult({
    required this.assets,
    required this.periodMonths,
    required this.periodLabel,
    required this.consolidatedPoints,
    this.createdAt,
  });

  double get totalInvested =>
      assets.fold(0, (s, a) => s + a.investedAmount);
  double get totalProjected =>
      consolidatedPoints.isNotEmpty ? consolidatedPoints.last : totalInvested;
  double get totalGainPercent => totalInvested > 0
      ? (totalProjected - totalInvested) / totalInvested * 100
      : 0;
  bool get isYearly => periodMonths > 12;

  @override
  List<Object?> get props => [assets, periodMonths, consolidatedPoints, createdAt];
}
