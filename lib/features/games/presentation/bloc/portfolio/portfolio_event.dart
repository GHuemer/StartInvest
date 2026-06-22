import 'package:equatable/equatable.dart';
import '../../../domain/entities/position.dart';

abstract class PortfolioEvent extends Equatable {
  const PortfolioEvent();
  @override
  List<Object?> get props => [];
}

class LoadWallets extends PortfolioEvent {
  const LoadWallets();
}

class CreateWallet extends PortfolioEvent {
  final String name;
  final double startingBalance;
  const CreateWallet({required this.name, required this.startingBalance});
  @override
  List<Object?> get props => [name, startingBalance];
}

class LoadPositions extends PortfolioEvent {
  final String walletId;
  const LoadPositions(this.walletId);
  @override
  List<Object?> get props => [walletId];
}

class LoadTrades extends PortfolioEvent {
  final String walletId;
  const LoadTrades(this.walletId);
  @override
  List<Object?> get props => [walletId];
}

class BuyAsset extends PortfolioEvent {
  final String walletId;
  final String ticker;
  final AssetType assetType;
  final double quantity;
  final double price;
  final double availableBalance;
  const BuyAsset({
    required this.walletId,
    required this.ticker,
    required this.assetType,
    required this.quantity,
    required this.price,
    required this.availableBalance,
  });
  @override
  List<Object?> get props => [walletId, ticker, quantity, price];
}

class SellAsset extends PortfolioEvent {
  final String walletId;
  final String ticker;
  final AssetType assetType;
  final double quantity;
  final double price;
  final double avgBuyPrice;
  final double ownedQuantity;
  const SellAsset({
    required this.walletId,
    required this.ticker,
    required this.assetType,
    required this.quantity,
    required this.price,
    required this.avgBuyPrice,
    required this.ownedQuantity,
  });
  @override
  List<Object?> get props => [walletId, ticker, quantity, price];
}

class UpdatePrices extends PortfolioEvent {
  final String walletId;
  const UpdatePrices(this.walletId);
  @override
  List<Object?> get props => [walletId];
}
