import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/wallet.dart';
import '../../../domain/entities/position.dart';
import '../../../../../core/theme/app_colors.dart';

class WalletCard extends StatelessWidget {
  final Wallet wallet;
  final List<Position> positions;
  final VoidCallback onTap;

  const WalletCard({
    super.key,
    required this.wallet,
    required this.positions,
    required this.onTap,
  });

  double get _totalCurrentValue =>
      positions.fold(0.0, (sum, p) => sum + p.currentValue);

  double get _portfolioValue =>
      wallet.lastPortfolioValue ??
      (wallet.availableBalance + _totalCurrentValue);

  double get _returnPct => wallet.startingBalance > 0
      ? ((_portfolioValue - wallet.startingBalance) / wallet.startingBalance) *
            100
      : 0;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isPositive = _returnPct >= 0;
    final returnColor = isPositive
        ? AppColors.textPositive
        : AppColors.textNegative;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    wallet.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white38),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patrimônio',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    Text(
                      fmt.format(_portfolioValue),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Retorno',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    Text(
                      '${isPositive ? '+' : ''}${_returnPct.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: returnColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Disponível: ${fmt.format(wallet.availableBalance)}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  '${positions.length} ativo${positions.length != 1 ? 's' : ''}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
