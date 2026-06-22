import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/position.dart';
import '../../../domain/usecases/portfolio/get_wallets_usecase.dart';
import '../../../domain/usecases/portfolio/create_wallet_usecase.dart';
import '../../../domain/usecases/portfolio/get_positions_usecase.dart';
import '../../../domain/usecases/portfolio/buy_asset_usecase.dart';
import '../../../domain/usecases/portfolio/sell_asset_usecase.dart';
import '../../../domain/usecases/portfolio/get_trades_usecase.dart';
import '../../../domain/repositories/portfolio_repository.dart';
import '../../../../../core/error/failures.dart';
import 'portfolio_event.dart';
import 'portfolio_state.dart';

@injectable
class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final GetWalletsUseCase _getWallets;
  final CreateWalletUseCase _createWallet;
  final GetPositionsUseCase _getPositions;
  final BuyAssetUseCase _buyAsset;
  final SellAssetUseCase _sellAsset;
  final GetTradesUseCase _getTrades;
  final PortfolioRepository _repository;

  PortfolioBloc(
    this._getWallets,
    this._createWallet,
    this._getPositions,
    this._buyAsset,
    this._sellAsset,
    this._getTrades,
    this._repository,
  ) : super(const PortfolioInitial()) {
    on<LoadWallets>(_onLoadWallets);
    on<CreateWallet>(_onCreateWallet);
    on<LoadPositions>(_onLoadPositions);
    on<LoadTrades>(_onLoadTrades);
    on<BuyAsset>(_onBuyAsset);
    on<SellAsset>(_onSellAsset);
    on<UpdatePrices>(_onUpdatePrices);
  }

  Future<void> _onLoadWallets(
    LoadWallets event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const PortfolioLoading());
    final result = await _getWallets();
    result.fold(
      (Failure f) => emit(PortfolioError(f.message)),
      (wallets) => emit(WalletsLoaded(wallets)),
    );
  }

  Future<void> _onCreateWallet(
    CreateWallet event,
    Emitter<PortfolioState> emit,
  ) async {
    final currentCount = state is WalletsLoaded
        ? (state as WalletsLoaded).wallets.length
        : 0;
    emit(const PortfolioLoading());
    final result = await _createWallet(
      name: event.name,
      startingBalance: event.startingBalance,
      currentWalletCount: currentCount,
    );
    result.fold(
      (Failure f) => emit(PortfolioError(f.message)),
      (wallet) => emit(WalletCreated(wallet)),
    );
  }

  Future<void> _onLoadPositions(
    LoadPositions event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const PortfolioLoading());
    final walletsResult = await _getWallets();
    final posResult = await _getPositions(event.walletId);

    posResult.fold((Failure f) => emit(PortfolioError(f.message)), (positions) {
      double available = 0;
      double starting = 0;
      walletsResult.fold((_) {}, (wallets) {
        final wallet = wallets.where((w) => w.id == event.walletId).firstOrNull;
        available = wallet?.availableBalance ?? 0;
        starting = wallet?.startingBalance ?? 0;
      });
      emit(
        PositionsLoaded(
          walletId: event.walletId,
          positions: positions,
          availableBalance: available,
          startingBalance: starting,
        ),
      );
      // Atualiza preços imediatamente ao carregar, sem esperar o timer de 60s
      add(UpdatePrices(event.walletId));
    });
  }

  Future<void> _onLoadTrades(
    LoadTrades event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const PortfolioLoading());
    final result = await _getTrades(event.walletId);
    result.fold(
      (Failure f) => emit(PortfolioError(f.message)),
      (trades) => emit(TradesLoaded(trades)),
    );
  }

  Future<void> _onBuyAsset(BuyAsset event, Emitter<PortfolioState> emit) async {
    emit(const PortfolioLoading());
    final result = await _buyAsset(
      walletId: event.walletId,
      ticker: event.ticker,
      assetType: event.assetType,
      quantity: event.quantity,
      price: event.price,
      availableBalance: event.availableBalance,
    );
    result.fold(
      (Failure f) => emit(PortfolioError(f.message)),
      (trade) => emit(
        TradeExecuted(
          trade: trade,
          message: 'Compra de ${event.ticker} realizada com sucesso!',
          xpChange: 0,
        ),
      ),
    );
  }

  Future<void> _onSellAsset(
    SellAsset event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const PortfolioLoading());
    final result = await _sellAsset(
      walletId: event.walletId,
      ticker: event.ticker,
      assetType: event.assetType,
      quantity: event.quantity,
      price: event.price,
      avgBuyPrice: event.avgBuyPrice,
      ownedQuantity: event.ownedQuantity,
    );
    result.fold((Failure f) => emit(PortfolioError(f.message)), (trade) {
      final xp = trade.xpEarned ?? 0;
      final xpMsg = xp > 0
          ? '+$xp XP'
          : xp < 0
          ? '$xp XP'
          : '';
      emit(
        TradeExecuted(
          trade: trade,
          message: 'Venda de ${event.ticker} realizada! $xpMsg'.trim(),
          xpChange: xp,
        ),
      );
    });
  }

  // Taxa CDI diária (~13,75% a.a. / 252 dias úteis)
  static const double _cdiDailyRate = 0.1375 / 252;

  Future<void> _onUpdatePrices(
    UpdatePrices event,
    Emitter<PortfolioState> emit,
  ) async {
    if (state is! PositionsLoaded) return;
    final current = state as PositionsLoaded;
    final updated = <Position>[];

    for (final pos in current.positions) {
      if (pos.assetType == AssetType.fixedIncome) {
        // Renda Fixa: juros compostos CDI desde a data de compra
        final days = DateTime.now().difference(pos.purchaseDate).inDays;
        final accumulatedPrice =
            pos.avgBuyPrice * pow(1 + _cdiDailyRate, days > 0 ? days : 1);
        updated.add(pos.copyWith(currentPrice: accumulatedPrice.toDouble()));
      } else {
        final result = await _repository.getAssetPrice(
          pos.ticker,
          pos.assetType,
        );
        result.fold(
          // API falhou: mantém o último preço conhecido (não zera)
          (_) => updated.add(pos),
          (asset) {
            // Se API retornar 0 (fallback zerado), mantém preço anterior
            final newPrice = asset.currentPrice > 0
                ? asset.currentPrice
                : pos.currentPrice;
            updated.add(pos.copyWith(currentPrice: newPrice));
          },
        );
      }
    }

    emit(
      PositionsLoaded(
        walletId: current.walletId,
        positions: updated,
        availableBalance: current.availableBalance,
        startingBalance: current.startingBalance,
      ),
    );
  }
}
