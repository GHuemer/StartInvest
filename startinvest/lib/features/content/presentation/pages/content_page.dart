import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ContentPage extends StatelessWidget {
  const ContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  children: [
                    const BackButton(),
                    const Text('Portal de Ensino', style: AppTextStyles.headlineLarge),
                    const Spacer(),
                    CircleAvatar(radius: 18, backgroundColor: AppColors.backgroundCard, child: const Icon(Icons.person, size: 18, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Ex: Introdução a criptomoedas',
                    prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: const Text('Cursos', style: AppTextStyles.headlineMedium),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: 2,
                  itemBuilder: (context, i) => _CourseCard(
                    title: i == 0 ? 'Bolsa de Valores I' : 'Planejamento Pessoal',
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: const Text('Artigos e Textos', style: AppTextStyles.headlineMedium),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final articles = [
                    'Juros Compostos: O Milagre da Economia',
                    'Renda Fixa x Renda Variável',
                    'O Que é Tesouro Direto?',
                    'Qual o Segredo das Criptomoedas?',
                  ];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                    child: _ArticleCard(title: articles[i]),
                  );
                },
                childCount: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.backgroundCardLight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Center(child: Icon(Icons.play_circle_outline, color: AppColors.primary, size: 40)),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(title, style: AppTextStyles.titleMedium, maxLines: 2),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: AppColors.backgroundCardLight, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.article, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: AppTextStyles.titleMedium)),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
