import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/news_cubit.dart';
import '../bloc/news_state.dart';
import '../widgets/news_card.dart';
import '../../domain/entities/news_entry.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_back_button.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<NewsCubit>()..init(),
      child: const NewsView(),
    );
  }
}

class NewsView extends StatelessWidget {
  const NewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<NewsCubit, NewsState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Row(
                      children: [
                        const AppBackButton(),
                        const Text(
                          'Notícias',
                          style: AppTextStyles.headlineLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextField(
                      onChanged: (value) => context.read<NewsCubit>().searchNews(value),
                      decoration: InputDecoration(
                        hintText: 'Buscar notícias...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.backgroundCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _FilterChip(label: 'Tudo'),
                        _FilterChip(label: 'Ações'),
                        _FilterChip(label: 'Cripto'),
                        _FilterChip(label: 'Economia'),
                        _FilterChip(label: 'Tech'),
                      ],
                    ),
                  ),
                ),
                if (state is NewsLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is NewsError)
                  SliverFillRemaining(
                    child: Center(child: Text(state.message)),
                  )
                else if (state is NewsLoaded)
                  state.filteredNews.isEmpty
                      ? const SliverFillRemaining(
                          child: Center(child: Text('Nenhuma notícia encontrada.')),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final news = state.filteredNews[index];
                                return NewsCard(
                                  news: news,
                                  onTap: () {
                                    context.push('${AppRoutes.news}/${AppRoutes.newsDetail}', extra: news);
                                  },
                                );
                              },
                              childCount: state.filteredNews.length,
                            ),
                          ),
                        ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class NewsDetailPage extends StatelessWidget {
  final NewsEntry news;
  const NewsDetailPage({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.backgroundDark,
            leading: const AppBackButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primary.withOpacity(0.1),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(news.category),
                    size: 64,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      news.tag,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    news.title,
                    style: AppTextStyles.headlineMedium.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        news.source,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•  ${news.date}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 24),
                  Text(
                    news.content,
                    style: AppTextStyles.bodyLarge.copyWith(
                      height: 1.6,
                      color: AppColors.textPrimary.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'stocks':
        return Icons.trending_up;
      case 'crypto':
        return Icons.currency_bitcoin;
      case 'economy':
        return Icons.public;
      case 'tech':
        return Icons.memory;
      default:
        return Icons.newspaper;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  const _FilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        final isSelected = state is NewsLoaded && state.selectedCategory == label;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(label),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (selected) {
              if (selected) {
                context.read<NewsCubit>().selectCategory(label);
              }
            },
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.backgroundCard,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textMuted,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
            ),
          ),
        );
      },
    );
  }
}
