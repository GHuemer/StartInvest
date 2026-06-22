import 'package:equatable/equatable.dart';
import 'position.dart';

class MarketAsset extends Equatable {
  final String ticker;
  final String name;
  final AssetType type;
  final double currentPrice;
  final double changePercent;
  final DateTime fetchedAt;
  final bool isOffline;

  const MarketAsset({
    required this.ticker,
    required this.name,
    required this.type,
    required this.currentPrice,
    required this.changePercent,
    required this.fetchedAt,
    this.isOffline = false,
  });

  bool get isStale => DateTime.now().difference(fetchedAt).inSeconds > 60;

  MarketAsset copyWith({double? currentPrice, double? changePercent}) {
    return MarketAsset(
      ticker: ticker,
      name: name,
      type: type,
      currentPrice: currentPrice ?? this.currentPrice,
      changePercent: changePercent ?? this.changePercent,
      fetchedAt: DateTime.now(),
      isOffline: isOffline,
    );
  }

  @override
  List<Object?> get props => [
    ticker,
    name,
    type,
    currentPrice,
    changePercent,
    fetchedAt,
    isOffline,
  ];
}
