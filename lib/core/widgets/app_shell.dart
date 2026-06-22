import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/profile/presentation/friend_requests_cubit.dart';
import '../../features/ranking/presentation/bloc/ranking_cubit.dart';
import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _tabs = [
    AppRoutes.home,
    AppRoutes.games,
    AppRoutes.content,
    AppRoutes.ranking,
  ];

  @override
  void initState() {
    super.initState();
  }

  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const NotificationsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabs.indexWhere((t) => location.startsWith(t));

    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: BlocBuilder<FriendRequestsCubit, FriendRequestsState>(
              builder: (context, state) {
                int count = 0;
                if (state is FriendRequestsLoaded) {
                  count = state.requests.length;
                }

                if (count == 0) return const SizedBox();

                return GestureDetector(
                  onTap: () => _showNotificationsModal(context),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.textNegative,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.navBarBackground,
          border: Border(
            top: BorderSide(color: AppColors.cardBorder, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex < 0 ? 0 : currentIndex,
          onTap: (i) => context.go(_tabs[i]),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          items: [
            _buildNavItem(Icons.grid_view_rounded, 'Home'),
            _buildNavItem(Icons.rocket_launch_outlined, 'Praticar'),
            _buildNavItem(Icons.school_outlined, 'Aprender'),
            _buildNavItem(Icons.emoji_events_rounded, 'Ranking'),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(icon),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      label: label,
    );
  }
}

class NotificationsModal extends StatelessWidget {
  const NotificationsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('Notificações', style: AppTextStyles.headlineMedium),
          ),
          const SizedBox(height: 16),
          BlocBuilder<FriendRequestsCubit, FriendRequestsState>(
            builder: (context, state) {
              if (state is FriendRequestsLoaded && state.requests.isNotEmpty) {
                return Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.requests.length,
                    itemBuilder: (context, index) {
                      final req = state.requests[index];
                      final fromUser = req['fromUser'] as Map<String, dynamic>?;
                      final name = fromUser?['name'] ?? 'Usuário';
                      final username = fromUser?['username'] ?? '';

                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.backgroundCardLight,
                          child: Icon(Icons.person, color: AppColors.primary),
                        ),
                        title: const Text(
                          'Pedido de amizade',
                          style: AppTextStyles.titleMedium,
                        ),
                        subtitle: Text(
                          '$name (@$username) quer ser seu amigo',
                          style: AppTextStyles.bodySmall,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                              ),
                              onPressed: () async {
                                await context
                                    .read<FriendRequestsCubit>()
                                    .acceptRequest(req['id']);
                                // Se estiver na RankingPage, forçamos o refresh
                                if (context.mounted) {
                                  try {
                                    context.read<RankingCubit>().loadRankings();
                                  } catch (_) {
                                    // Silenciosamente falha se o RankingCubit não estiver no contexto
                                  }
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.cancel,
                                color: AppColors.textNegative,
                              ),
                              onPressed: () => context
                                  .read<FriendRequestsCubit>()
                                  .declineRequest(req['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'Nenhuma notificação no momento',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
