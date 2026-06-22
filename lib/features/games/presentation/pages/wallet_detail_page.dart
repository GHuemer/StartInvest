import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/di/injection.dart';
import '../bloc/portfolio/portfolio_bloc.dart';
import '../bloc/portfolio/portfolio_event.dart';
import '../bloc/portfolio/portfolio_state.dart';
import '../widgets/portfolio/position_card.dart';
import '../../domain/entities/position.dart';
import 'asset_browser_page.dart';
import 'buy_sell_page.dart';
import 'trade_history_page.dart';

class WalletDetailPage extends StatefulWidget {
  final String walletId;
  final String walletName;

  const WalletDetailPage({
    super.key,
    required this.walletId,
    required this.walletName,
  });

  @override
  State<WalletDetailPage> createState() => _WalletDetailPageState();
}

class _WalletDetailPageState extends State<WalletDetailPage> {
  Timer? _priceTimer;
  late PortfolioBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<PortfolioBloc>()..add(LoadPositions(widget.walletId));
    _priceTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _bloc.add(UpdatePrices(widget.walletId)),
    );
  }

  @override
  void dispose() {
    _priceTimer?.cancel();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<PortfolioBloc, PortfolioState>(
        listener: (context, state) {
          if (state is TradeExecuted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: state.xpChange >= 0
                    ? AppColors.primary
                    : AppColors.textNegative,
              ),
            );
            _bloc.add(LoadPositions(widget.walletId));
          } else if (state is WalletDeleted) {
            Navigator.pop(context);
          } else if (state is PortfolioError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.textNegative,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.backgroundDark,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const AppBackButton(),
              title: Text(
                widget.walletName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.history, color: Colors.white70),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TradeHistoryPage(walletId: widget.walletId),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white38),
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
            body: _buildBody(context, state),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _openBrowser(context, state),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                'Comprar',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, PortfolioState state) {
    if (state is PortfolioLoading || state is PortfolioInitial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (state is PositionsLoaded) {
      return _buildPositions(context, state);
    }
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildPositions(BuildContext context, PositionsLoaded state) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final totalCurrentValue = state.positions.fold(
      0.0,
      (s, p) => s + p.currentValue,
    );
    final portfolioValue = state.availableBalance + totalCurrentValue;
    final returnPct = state.startingBalance > 0
        ? ((portfolioValue - state.startingBalance) / state.startingBalance) *
              100
        : 0.0;
    final isPositive = returnPct >= 0;

    return RefreshIndicator(
      onRefresh: () async => _bloc.add(LoadPositions(widget.walletId)),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
        children: [
          // Header com resumo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder.withOpacity(0.4)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Patrimônio Total',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        Text(
                          fmt.format(portfolioValue),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Retorno',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        Text(
                          '${isPositive ? '+' : ''}${returnPct.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: isPositive
                                ? AppColors.textPositive
                                : AppColors.textNegative,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.cardBorder, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(
                      label: 'Disponível',
                      value: fmt.format(state.availableBalance),
                    ),
                    _StatItem(
                      label: 'Investido',
                      value: fmt.format(totalCurrentValue),
                    ),
                    _StatItem(
                      label: 'Ativos',
                      value: '${state.positions.length}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (state.positions.isEmpty) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 48),
                child: Column(
                  children: [
                    Icon(Icons.show_chart, size: 48, color: Colors.white24),
                    SizedBox(height: 16),
                    Text(
                      'Nenhum ativo ainda.\nToque em Comprar para começar!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const Text(
              'Posições',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ...state.positions.map(
              (p) => PositionCard(
                position: p,
                onTap: () => _openSell(context, p, state.availableBalance),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openBrowser(BuildContext context, PortfolioState state) {
    double available = 0;
    if (state is PositionsLoaded) available = state.availableBalance;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssetBrowserPage(
          walletId: widget.walletId,
          availableBalance: available,
          onTradeComplete: () => _bloc.add(LoadPositions(widget.walletId)),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Excluir carteira?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'A carteira "${widget.walletName}" e todo seu histórico de operações serão excluídos permanentemente.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _bloc.add(DeleteWallet(widget.walletId));
            },
            child: const Text(
              'Excluir',
              style: TextStyle(
                color: AppColors.textNegative,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openSell(BuildContext context, Position position, double available) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BuySellPage(
          walletId: widget.walletId,
          ticker: position.ticker,
          assetType: position.assetType,
          currentPrice: position.currentPrice,
          changePercent: 0,
          assetName: position.ticker,
          mode: TradingMode.sell,
          ownedQuantity: position.quantity,
          avgBuyPrice: position.avgBuyPrice,
          availableBalance: available,
          onTradeComplete: () => _bloc.add(LoadPositions(widget.walletId)),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
