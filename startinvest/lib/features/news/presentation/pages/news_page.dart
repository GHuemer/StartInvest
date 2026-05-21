import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final news = [
      _NewsItem("Ações da TechCorp sobem 5% após novo lançamento", "UOL", "9 de dezembro de 2024", "MERCADO DE AÇÕES", AppColors.tagStocks),
      _NewsItem("Bitcoin atinge nova alta histórica", "CoinMarketCap", "12 de maio de 2025", "CRIPTOMOEDAS", AppColors.tagCrypto),
      _NewsItem("Inflação desacelera em maio, aliviando pressões interna", "Banco central", "20 de janeiro de 2025", "ECONOMIA", AppColors.tagEconomy),
    ];

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(children: [const BackButton(), const Text('Notícias', style: AppTextStyles.headlineLarge)]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search, color: AppColors.textMuted)),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: _NewsCard(item: news[i]),
                ),
                childCount: news.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsItem {
  const _NewsItem(this.title, this.source, this.date, this.tag, this.tagColor);
  final String title, source, date, tag;
  final Color tagColor;
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item});
  final _NewsItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: AppTextStyles.titleLarge),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fonte: ${item.source}', style: AppTextStyles.bodySmall),
                    Text(item.date, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: item.tagColor, borderRadius: BorderRadius.circular(6)),
                child: Text(item.tag, style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
