import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/di/injection.dart';
import '../bloc/portfolio/portfolio_bloc.dart';
import '../bloc/portfolio/portfolio_event.dart';
import '../bloc/portfolio/portfolio_state.dart';
import '../../domain/entities/trade.dart';

class TradeHistoryPage extends StatelessWidget {
  final String walletId;
  const TradeHistoryPage({super.key, required this.walletId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PortfolioBloc>()..add(LoadTrades(walletId)),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const AppBackButton(),
          title: const Text(
            'Histórico de Operações',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: BlocBuilder<PortfolioBloc, PortfolioState>(
          builder: (context, state) {
            if (state is PortfolioLoading || state is PortfolioInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (state is TradesLoaded) {
              if (state.trades.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: Colors.white24,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Nenhuma operação realizada ainda.',
                        style: TextStyle(color: Colors.white38, fontSize: 14),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.trades.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: AppColors.divider, height: 1),
                itemBuilder: (_, i) => _TradeTile(trade: state.trades[i]),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _TradeTile extends StatelessWidget {
  final Trade trade;
  const _TradeTile({required this.trade});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFmt = DateFormat('dd/MM/yy HH:mm');
    final isBuy = trade.type == TradeType.buy;
    final typeColor = isBuy ? const Color(0xFF1565C0) : AppColors.textNegative;
    final xp = trade.xpEarned;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isBuy ? Icons.arrow_downward : Icons.arrow_upward,
              color: typeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      trade.ticker,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      fmt.format(trade.totalValue),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${isBuy ? 'Compra' : 'Venda'} • ${trade.quantity.toStringAsFixed(trade.quantity % 1 == 0 ? 0 : 2)} un × ${fmt.format(trade.price)}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    if (!isBuy && xp != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (xp >= 0
                                      ? AppColors.primary
                                      : AppColors.textNegative)
                                  .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${xp >= 0 ? '+' : ''}$xp XP',
                          style: TextStyle(
                            color: xp >= 0
                                ? AppColors.primary
                                : AppColors.textNegative,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  dateFmt.format(trade.timestamp),
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
