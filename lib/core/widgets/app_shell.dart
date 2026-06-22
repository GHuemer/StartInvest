import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/profile/presentation/friend_requests_cubit.dart';
import '../../features/profile/presentation/profile_cubit.dart';
import '../../features/profile/presentation/profile_state.dart';
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

  static const _navItems = [
    ('Home', Icons.grid_view_rounded, AppRoutes.home),
    ('Praticar', Icons.rocket_launch_outlined, AppRoutes.games),
    ('Aprender', Icons.school_outlined, AppRoutes.content),
    ('Ranking', Icons.emoji_events_rounded, AppRoutes.ranking),
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

  Future<void> _handleLogout(BuildContext context) async {
    context.read<AuthBloc>().add(const AuthSignOutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabs.indexWhere((t) => location.startsWith(t));

    if (isDesktop) {
      return _buildDesktopLayout(context, currentIndex);
    } else {
      return _buildMobileLayout(context, currentIndex);
    }
  }

  Widget _buildDesktopLayout(BuildContext context, int currentIndex) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(
            child: Stack(
              children: [
                widget.child,
                Positioned(
                  top: 20,
                  right: 30,
                  child: _buildTopBar(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, int currentIndex) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: _buildNotificationIcon(context),
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
          items: _navItems.map((item) => _buildNavItem(item.$2, item.$1)).toList(),
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Container(
      width: 180,
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(
          right: BorderSide(color: AppColors.cardBorder, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Start Invest', style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary)),
                Text('Educação Financeira', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final (label, icon, route) = _navItems[index];
                final isSelected = location.startsWith(route);
                return _buildSidebarItem(
                  label: label,
                  icon: icon,
                  isSelected: isSelected,
                  onTap: () => context.go(route),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSidebarItem(
                  label: 'Perfil',
                  icon: Icons.person_outline,
                  isSelected: location.startsWith(AppRoutes.profile),
                  onTap: () => context.go(AppRoutes.profile),
                ),
                _buildSidebarItem(
                  label: 'Sair',
                  icon: Icons.logout_outlined,
                  isSelected: false,
                  onTap: () => _handleLogout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary, width: 1),
              )
            : null,
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final xp = authState is AuthAuthenticated ? authState.user.xp : 0;
    final profileState = context.watch<ProfileCubit>().state;
    final streak = profileState is ProfileLoaded ? profileState.streak : 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTextPill('$xp XP', AppColors.yellowHighlight),
        const SizedBox(width: 8),
        _buildStatPill(Icons.local_fire_department_outlined, '$streak DIAS', Colors.orange),
        const SizedBox(width: 16),
        _buildNotificationIcon(context),
      ],
    );
  }

  Widget _buildTextPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatPill(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return BlocBuilder<FriendRequestsCubit, FriendRequestsState>(
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
                child: const Icon(Icons.notifications_active, color: AppColors.primary),
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
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Icon(Icons.person, color: AppColors.primary, size: 20),
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
                        title: const Text('Pedido de amizade', style: AppTextStyles.titleMedium),
                        subtitle: Text('$name (@$username) quer ser seu amigo', style: AppTextStyles.bodySmall),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: AppColors.primary),
                              onPressed: () async {
                                await context.read<FriendRequestsCubit>().acceptRequest(req['id']);
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
                              icon: const Icon(Icons.cancel, color: AppColors.textNegative),
                              onPressed: () => context.read<FriendRequestsCubit>().declineRequest(req['id']),
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
                child: Center(child: Text('Nenhuma notificação no momento', style: AppTextStyles.bodyMedium)),
              );
            },
          ),
        ],
      ),
    );
  }
}
