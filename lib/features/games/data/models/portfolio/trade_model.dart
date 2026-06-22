import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/trade.dart';
import '../../../domain/entities/position.dart';

class TradeModel extends Trade {
  const TradeModel({
    required super.id,
    required super.walletId,
    required super.ticker,
    required super.assetType,
    required super.type,
    required super.quantity,
    required super.price,
    required super.totalValue,
    required super.timestamp,
    super.xpEarned,
  });

  factory TradeModel.fromFirestore(String id, Map<String, dynamic> data) {
    return TradeModel(
      id: id,
      walletId: data['walletId'] as String? ?? '',
      ticker: data['ticker'] as String? ?? '',
      assetType: AssetTypeLabel.fromString(
        data['assetType'] as String? ?? 'stock',
      ),
      type: (data['type'] as String?) == 'sell'
          ? TradeType.sell
          : TradeType.buy,
      quantity: (data['quantity'] as num?)?.toDouble() ?? 0.0,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      totalValue: (data['totalValue'] as num?)?.toDouble() ?? 0.0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      xpEarned: data['xpEarned'] as int?,
    );
  }
}
