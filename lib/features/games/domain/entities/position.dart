import 'package:equatable/equatable.dart';

enum AssetType { stock, fii, fixedIncome }

extension AssetTypeLabel on AssetType {
  String get label {
    switch (this) {
      case AssetType.stock:
        return 'Ação';
      case AssetType.fii:
        return 'FII';
      case AssetType.fixedIncome:
        return 'Renda Fixa';
    }
  }

  String get value {
    switch (this) {
      case AssetType.stock:
        return 'stock';
      case AssetType.fii:
        return 'fii';
      case AssetType.fixedIncome:
        return 'fixedIncome';
    }
  }

  static AssetType fromString(String value) {
    switch (value) {
      case 'fii':
        return AssetType.fii;
      case 'fixedIncome':
        return AssetType.fixedIncome;
      default:
        return AssetType.stock;
    }
  }
}

class Position extends Equatable {
  final String ticker;
  final String walletId;
  final AssetType assetType;
  final double quantity;
  final double avgBuyPrice;
  final double currentPrice;
  final DateTime purchaseDate;

  const Position({
    required this.ticker,
    required this.walletId,
    required this.assetType,
    required this.quantity,
    required this.avgBuyPrice,
    required this.currentPrice,
    required this.purchaseDate,
  });

  double get totalCost => quantity * avgBuyPrice;
  double get currentValue => quantity * currentPrice;
  double get profitLoss => currentValue - totalCost;
  double get profitLossPct =>
      totalCost > 0 ? (profitLoss / totalCost) * 100 : 0;

  Position copyWith({
    double? currentPrice,
    double? quantity,
    double? avgBuyPrice,
  }) {
    return Position(
      ticker: ticker,
      walletId: walletId,
      assetType: assetType,
      quantity: quantity ?? this.quantity,
      avgBuyPrice: avgBuyPrice ?? this.avgBuyPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      purchaseDate: purchaseDate,
    );
  }

  @override
  List<Object?> get props => [
    ticker,
    walletId,
    assetType,
    quantity,
    avgBuyPrice,
    currentPrice,
    purchaseDate,
  ];
}
