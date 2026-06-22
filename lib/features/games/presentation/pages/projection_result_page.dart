import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../domain/entities/position.dart';
import '../../domain/entities/simulation_result.dart';

class ProjectionResultPage extends StatelessWidget {
  final SimulationResult result;
  const ProjectionResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isPositive = result.totalGainPercent >= 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AppBackButton(),
        title: Text(
          'Projeção em ${result.periodLabel}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          // Summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPositive
                    ? [const Color(0xFF1A2E1A), const Color(0xFF0F1F0F)]
                    : [const Color(0xFF2E1A1A), const Color(0xFF1F0F0F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (isPositive ? AppColors.primary : AppColors.textNegative)
                    .withValues(alpha: 0.4),
              ),
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
                          'Investido hoje',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                        Text(
                          fmt.format(result.totalInvested),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white38,
                      size: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Em ${result.periodLabel}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          fmt.format(result.totalProjected),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        (isPositive
                                ? AppColors.textPositive
                                : AppColors.textNegative)
                            .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}${result.totalGainPercent.toStringAsFixed(1)}% de retorno estimado',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isPositive
                          ? AppColors.textPositive
                          : AppColors.textNegative,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Baseado no histórico de cada ativo. Rentabilidade passada não garante resultado futuro.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Chart
          const Text(
            'Evolução projetada',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 220,
            padding: const EdgeInsets.fromLTRB(0, 16, 16, 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _ProjectionChart(result: result),
          ),
          const SizedBox(height: 24),

          // Per-asset breakdown
          const Text(
            'Detalhes por ativo',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ...result.assets.asMap().entries.map((entry) {
            final proj = entry.value;
            final color = _assetColors[entry.key % _assetColors.length];
            return _AssetResultCard(
              projection: proj,
              fmt: fmt,
              accentColor: color,
              periodLabel: result.periodLabel,
            );
          }),
        ],
      ),
    );
  }

  static const _assetColors = [
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
  ];
}

// ──────────────────────────────────────────────────────────────────────────────

class _ProjectionChart extends StatelessWidget {
  final SimulationResult result;
  const _ProjectionChart({required this.result});

  static const _assetColors = [
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
  ];

  @override
  Widget build(BuildContext context) {
    final showIndividual = result.assets.length > 1;

    final lineBars = <LineChartBarData>[
      // Linha consolidada (verde primária)
      LineChartBarData(
        spots: result.consolidatedPoints
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList(),
        color: AppColors.primary,
        barWidth: 2.5,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: AppColors.primary.withValues(alpha: 0.08),
        ),
      ),
      // Linhas individuais (tracejadas, mais finas)
      if (showIndividual)
        ...result.assets.asMap().entries.map((entry) {
          final color = _assetColors[entry.key % _assetColors.length];
          return LineChartBarData(
            spots: entry.value.dataPoints
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value))
                .toList(),
            color: color.withValues(alpha: 0.5),
            barWidth: 1.5,
            dotData: const FlDotData(show: false),
            dashArray: [6, 4],
          );
        }),
    ];

    final allValues = [
      ...result.consolidatedPoints,
      ...result.assets.expand((a) => a.dataPoints),
    ];
    final minY = allValues.reduce((a, b) => a < b ? a : b);
    final maxY = allValues.reduce((a, b) => a > b ? a : b);
    final range = maxY - minY;

    final fmt = NumberFormat.compact(locale: 'pt_BR');
    final stepCount = result.consolidatedPoints.length - 1;
    final isYearly = result.isYearly;
    final xLabel = isYearly ? 'ano' : 'mês';

    return LineChart(
      LineChartData(
        lineBarsData: lineBars,
        minY: minY - range * 0.05,
        maxY: maxY + range * 0.05,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 58,
              getTitlesWidget: (value, meta) {
                if (value == meta.min || value == meta.max) {
                  return const SizedBox.shrink();
                }
                return Text(
                  'R\$${fmt.format(value)}',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: stepCount > 10 ? (stepCount / 4).roundToDouble() : 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i == 0) {
                  return const Text(
                    'hoje',
                    style: TextStyle(color: Colors.white38, fontSize: 9),
                  );
                }
                return Text(
                  '$i $xLabel',
                  style: const TextStyle(color: Colors.white38, fontSize: 9),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Colors.white10, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.backgroundCard,
            getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
              final val = NumberFormat.currency(
                locale: 'pt_BR',
                symbol: 'R\$',
              ).format(s.y);
              return LineTooltipItem(
                val,
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _AssetResultCard extends StatelessWidget {
  final AssetProjection projection;
  final NumberFormat fmt;
  final Color accentColor;
  final String periodLabel;

  const _AssetResultCard({
    required this.projection,
    required this.fmt,
    required this.accentColor,
    required this.periodLabel,
  });

  String get _typeLabel => switch (projection.assetType) {
    AssetType.stock => 'Ação',
    AssetType.fii => 'FII',
    AssetType.fixedIncome => 'Renda Fixa',
  };

  @override
  Widget build(BuildContext context) {
    final isPositive = projection.gainPercent >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: accentColor, width: 3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: accentColor.withValues(alpha: 0.15),
                radius: 18,
                child: Text(
                  projection.ticker.substring(0, 2),
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projection.ticker,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$_typeLabel · ${(projection.annualRate * 100).toStringAsFixed(1)}% a.a. histórico',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fmt.format(projection.projectedValue),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${isPositive ? '+' : ''}${projection.gainPercent.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: isPositive
                          ? AppColors.textPositive
                          : AppColors.textNegative,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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
                'Investido: ${fmt.format(projection.investedAmount)}',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              Text(
                'Ganho: ${fmt.format(projection.absoluteGain)}',
                style: TextStyle(
                  color: isPositive
                      ? AppColors.textPositive
                      : AppColors.textNegative,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
