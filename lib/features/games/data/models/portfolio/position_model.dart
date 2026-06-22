import '../../../domain/entities/position.dart';

class PositionModel extends Position {
  const PositionModel({
    required super.ticker,
    required super.walletId,
    required super.assetType,
    required super.quantity,
    required super.avgBuyPrice,
    required super.currentPrice,
  });

  factory PositionModel.fromFirestore(
    String ticker,
    Map<String, dynamic> data,
    String walletId,
  ) {
    return PositionModel(
      ticker: ticker,
      walletId: walletId,
      assetType: AssetTypeLabel.fromString(
        data['assetType'] as String? ?? 'stock',
      ),
      quantity: (data['quantity'] as num?)?.toDouble() ?? 0.0,
      avgBuyPrice: (data['avgBuyPrice'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (data['avgBuyPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'ticker': ticker,
    'walletId': walletId,
    'assetType': assetType.value,
    'quantity': quantity,
    'avgBuyPrice': avgBuyPrice,
  };
}
