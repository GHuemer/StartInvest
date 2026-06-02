import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/content/presentation/pages/content_page.dart';
import '../../features/content/presentation/pages/course_player_page.dart';
import '../../features/games/presentation/pages/games_page.dart';
import '../../features/ranking/presentation/pages/ranking_page.dart';
import '../../features/news/presentation/pages/news_page.dart';
import '../../features/missions/presentation/pages/missions_page.dart';
import '../widgets/app_shell.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.signIn,
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final location = state.matchedLocation;
    final isOnAuthPage = location == AppRoutes.signIn ||
        location == AppRoutes.signUp ||
        location == AppRoutes.forgotPassword;

    if (authState is AuthAuthenticated && isOnAuthPage) {
      return AppRoutes.home;
    }
    if (authState is! AuthAuthenticated && !isOnAuthPage) {
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
              path: 'course', // resultará em /content/course
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
          builder: (context, state) => const RankingPage(),
        ),
        GoRoute(
          path: AppRoutes.news,
          builder: (context, state) => const NewsPage(),
        ),
        GoRoute(
          path: AppRoutes.missions,
          builder: (context, state) => const MissionsPage(),
        ),
      ],
    ),
  ],
);
