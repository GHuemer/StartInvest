import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/content_bloc.dart';
import '../bloc/content_state.dart';
import '../pages/article_detail_page.dart';
import '../pages/course_player_page.dart';
import 'article_card.dart';
import 'course_card.dart';

class ContentView extends StatelessWidget {
  const ContentView({super.key});

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
                    const Text(
                      'Portal de Ensino',
                      style: AppTextStyles.headlineLarge,
                    ),
                    const Spacer(),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.backgroundCard,
                      child: const Icon(
                        Icons.person,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
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
                child: const Text(
                  'Cursos',
                  style: AppTextStyles.headlineMedium,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<ContentBloc, ContentState>(
                builder: (context, state) {
                  if (state.status == ContentStatus.loading) {
                    return const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      separatorBuilder: (_, unused) =>
                          const SizedBox(width: 12),
                      itemCount: state.courses.length,
                      itemBuilder: (context, i) {
                        final course = state.courses[i];
                        return CourseCard(
                          title: course.title,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CoursePlayerPage(
                                  title: course.title,
                                  videoUrl: course.videoUrl,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: const Text(
                  'Artigos e Textos',
                  style: AppTextStyles.headlineMedium,
                ),
              ),
            ),
            BlocBuilder<ContentBloc, ContentState>(
              builder: (context, state) {
                if (state.status == ContentStatus.loading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state.status == ContentStatus.failure) {
                  return SliverFillRemaining(
                    child: Center(child: Text(state.errorMessage ?? 'Erro')),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final article = state.articles[i];
                      return ArticleCard(
                        article: article,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ArticleDetailPage(article: article),
                            ),
                          );
                        },
                      );
                    }, childCount: state.articles.length),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
