import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/complete_profile_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/content/presentation/pages/content_page.dart';
import '../../features/content/presentation/pages/course_player_page.dart';
import '../../features/games/presentation/pages/games_page.dart';
import '../../features/ranking/presentation/pages/ranking_page.dart';
import '../../features/ranking/presentation/bloc/ranking_cubit.dart';
import '../../features/news/presentation/pages/news_page.dart';
import '../../features/missions/presentation/pages/missions_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/profile_cubit.dart';
import '../di/injection.dart';
import '../../features/news/domain/entities/news_entry.dart';
import '../widgets/app_shell.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.signIn,
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final location = state.matchedLocation;
    
    final isAuthPage = location == AppRoutes.signIn ||
        location == AppRoutes.signUp ||
        location == AppRoutes.forgotPassword;

    if (authState is AuthAuthenticated) {
      // Se autenticado, verifica se tem username. 
      // Se não tiver, obriga a completar perfil (exceto se já estiver lá)
      final hasNoUsername = authState.user.username.isEmpty;
      
      if (hasNoUsername && location != AppRoutes.completeProfile) {
        return AppRoutes.completeProfile;
      }
      
      // Se já tem username e está tentando ir pra auth ou completar perfil, vai pra home
      if (!hasNoUsername && (isAuthPage || location == AppRoutes.completeProfile)) {
        return AppRoutes.home;
      }
    }

    if (authState is! AuthAuthenticated && !isAuthPage) {
      return AppRoutes.signIn;
    }
    
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.signIn,
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: AppRoutes.signUp,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.completeProfile,
      builder: (context, state) => const CompleteProfilePage(),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.games,
          builder: (context, state) => const GamesPage(),
        ),
        GoRoute(
          path: AppRoutes.content,
          builder: (context, state) => const ContentPage(),
          routes: [
            GoRoute(
              path: 'course',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                return CoursePlayerPage(
                  title: extra?['title'] ?? 'Curso',
                  videoUrl: extra?['videoUrl'],
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.ranking,
          builder: (context, state) => BlocProvider(
            create: (context) => getIt<RankingCubit>(),
            child: const RankingPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.news,
          builder: (context, state) => const NewsPage(),
          routes: [
            GoRoute(
              path: AppRoutes.newsDetail,
              builder: (context, state) {
                final news = state.extra as NewsEntry;
                return NewsDetailPage(news: news);
              },
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.missions,
          builder: (context, state) => const MissionsPage(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => BlocProvider(
            create: (context) => getIt<ProfileCubit>()..loadProfile(),
            child: const ProfilePage(),
          ),
        ),
      ],
    ),
  ],
);
