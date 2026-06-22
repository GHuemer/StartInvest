import 'package:equatable/equatable.dart';
import 'position.dart';

enum TradeType { buy, sell }

class Trade extends Equatable {
  final String id;
  final String walletId;
  final String ticker;
  final AssetType assetType;
  final TradeType type;
  final double quantity;
  final double price;
  final double totalValue;
  final DateTime timestamp;
  final int? xpEarned;

  const Trade({
    required this.id,
    required this.walletId,
    required this.ticker,
    required this.assetType,
    required this.type,
    required this.quantity,
    required this.price,
    required this.totalValue,
    required this.timestamp,
    this.xpEarned,
  });

  @override
  List<Object?> get props => [
    id,
    walletId,
    ticker,
    assetType,
    type,
    quantity,
    price,
    totalValue,
    timestamp,
    xpEarned,
  ];
}
