import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/di/injection.dart';
import '../bloc/portfolio/portfolio_bloc.dart';
import '../bloc/portfolio/portfolio_event.dart';
import '../bloc/portfolio/portfolio_state.dart';
import '../../domain/entities/position.dart';
import '../../domain/usecases/portfolio/calculate_portfolio_xp_usecase.dart';

enum TradingMode { buy, sell }

class BuySellPage extends StatefulWidget {
  final String walletId;
  final String ticker;
  final AssetType assetType;
  final double currentPrice;
  final double changePercent;
  final String assetName;
  final TradingMode mode;
  final double availableBalance;
  final double? ownedQuantity;
  final double? avgBuyPrice;
  final VoidCallback onTradeComplete;

  const BuySellPage({
    super.key,
    required this.walletId,
    required this.ticker,
    required this.assetType,
    required this.currentPrice,
    required this.changePercent,
    required this.assetName,
    required this.mode,
    required this.availableBalance,
    required this.onTradeComplete,
    this.ownedQuantity,
    this.avgBuyPrice,
  });

  @override
  State<BuySellPage> createState() => _BuySellPageState();
}

class _BuySellPageState extends State<BuySellPage> {
  final _qtyController = TextEditingController(text: '1');
  late PortfolioBloc _bloc;
  late CalculatePortfolioXpUseCase _calcXp;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<PortfolioBloc>();
    _calcXp = getIt<CalculatePortfolioXpUseCase>();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _bloc.close();
    super.dispose();
  }

  double get _qty =>
      double.tryParse(_qtyController.text.replaceAll(',', '.')) ?? 0;
  double get _total => _qty * widget.currentPrice;

  int get _estimatedXp {
    if (widget.mode == TradingMode.buy || widget.avgBuyPrice == null) return 0;
    final pct =
        ((widget.currentPrice - widget.avgBuyPrice!) / widget.avgBuyPrice!) *
        100;
    return _calcXp(assetType: widget.assetType, profitLossPct: pct);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isBuy = widget.mode == TradingMode.buy;
    final changeIsPositive = widget.changePercent >= 0;

    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<PortfolioBloc, PortfolioState>(
        listener: (context, state) {
          if (state is TradeExecuted) {
            HapticFeedback.mediumImpact();
            widget.onTradeComplete();
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
          final isLoading = state is PortfolioLoading;

          return Scaffold(
            backgroundColor: AppColors.backgroundDark,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const AppBackButton(),
              title: Text(
                isBuy ? 'Comprar ${widget.ticker}' : 'Vender ${widget.ticker}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info do ativo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.ticker,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              Text(
                                widget.assetName,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              fmt.format(widget.currentPrice),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '${changeIsPositive ? '+' : ''}${widget.changePercent.toStringAsFixed(2)}% hoje',
                              style: TextStyle(
                                color: changeIsPositive
                                    ? AppColors.textPositive
                                    : AppColors.textNegative,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Quantidade',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _qtyController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.backgroundCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixText: !isBuy
                          ? 'de ${widget.ownedQuantity?.toStringAsFixed(0) ?? '?'}'
                          : null,
                      suffixStyle: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  // Resumo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _SummaryRow(
                          label: isBuy ? 'Total a pagar' : 'Total a receber',
                          value: fmt.format(_total),
                          highlight: true,
                        ),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          label: 'Saldo disponível',
                          value: fmt.format(widget.availableBalance),
                        ),
                        if (!isBuy && widget.avgBuyPrice != null) ...[
                          const SizedBox(height: 8),
                          _SummaryRow(
                            label: 'Preço médio de compra',
                            value: fmt.format(widget.avgBuyPrice),
                          ),
                          const SizedBox(height: 8),
                          _XpRow(xp: _estimatedXp),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading || _qty <= 0
                          ? null
                          : () => _confirm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBuy
                            ? AppColors.primary
                            : AppColors.textNegative,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isBuy ? 'Confirmar Compra' : 'Confirmar Venda',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirm(BuildContext context) {
    if (widget.mode == TradingMode.buy) {
      _bloc.add(
        BuyAsset(
          walletId: widget.walletId,
          ticker: widget.ticker,
          assetType: widget.assetType,
          quantity: _qty,
          price: widget.currentPrice,
          availableBalance: widget.availableBalance,
        ),
      );
    } else {
      _bloc.add(
        SellAsset(
          walletId: widget.walletId,
          ticker: widget.ticker,
          assetType: widget.assetType,
          quantity: _qty,
          price: widget.currentPrice,
          avgBuyPrice: widget.avgBuyPrice ?? widget.currentPrice,
          ownedQuantity: widget.ownedQuantity ?? 0,
        ),
      );
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight ? Colors.white : Colors.white70,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            fontSize: highlight ? 15 : 13,
          ),
        ),
      ],
    );
  }
}

class _XpRow extends StatelessWidget {
  final int xp;
  const _XpRow({required this.xp});

  @override
  Widget build(BuildContext context) {
    final isPositive = xp >= 0;
    final color = isPositive ? AppColors.primary : AppColors.textNegative;
    final label = xp > 0
        ? '+$xp XP estimado'
        : xp < 0
        ? '$xp XP estimado'
        : 'Sem XP';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'XP nesta venda',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
