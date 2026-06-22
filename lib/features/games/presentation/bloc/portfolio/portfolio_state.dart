import 'package:equatable/equatable.dart';
import '../../../domain/entities/wallet.dart';
import '../../../domain/entities/position.dart';
import '../../../domain/entities/trade.dart';

abstract class PortfolioState extends Equatable {
  const PortfolioState();
  @override
  List<Object?> get props => [];
}

class PortfolioInitial extends PortfolioState {
  const PortfolioInitial();
}

class PortfolioLoading extends PortfolioState {
  const PortfolioLoading();
}

class WalletsLoaded extends PortfolioState {
  final List<Wallet> wallets;
  const WalletsLoaded(this.wallets);
  @override
  List<Object?> get props => [wallets];
}

class PositionsLoaded extends PortfolioState {
  final String walletId;
  final List<Position> positions;
  final double availableBalance;
  final double startingBalance;
  const PositionsLoaded({
    required this.walletId,
    required this.positions,
    required this.availableBalance,
    required this.startingBalance,
  });
  @override
  List<Object?> get props => [
    walletId,
    positions,
    availableBalance,
    startingBalance,
  ];
}

class TradesLoaded extends PortfolioState {
  final List<Trade> trades;
  const TradesLoaded(this.trades);
  @override
  List<Object?> get props => [trades];
}

class TradeExecuted extends PortfolioState {
  final Trade trade;
  final String message;
  final int xpChange;
  const TradeExecuted({
    required this.trade,
    required this.message,
    required this.xpChange,
  });
  @override
  List<Object?> get props => [trade, message, xpChange];
}

class WalletCreated extends PortfolioState {
  final Wallet wallet;
  const WalletCreated(this.wallet);
  @override
  List<Object?> get props => [wallet];
}

class WalletDeleted extends PortfolioState {
  const WalletDeleted();
}

class PortfolioError extends PortfolioState {
  final String message;
  const PortfolioError(this.message);
  @override
  List<Object?> get props => [message];
}
