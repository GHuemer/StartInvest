import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../profile/presentation/friend_requests_cubit.dart';

class HomeHeader extends StatelessWidget {
  final dynamic user;
  final String firstName;
  final String subtitle;

  const HomeHeader({
    super.key,
    required this.user,
    required this.firstName,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Start Invest',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppTextStyles.fontFamily,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Bem-vindo de volta,', style: AppTextStyles.greeting),
              const SizedBox(height: 4),
              Text(
                'Olá, $firstName!',
                style: AppTextStyles.userName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.pilarDescription,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            BlocBuilder<FriendRequestsCubit, FriendRequestsState>(
              builder: (context, state) {
                bool hasNotifications = false;
                if (state is FriendRequestsLoaded) {
                  hasNotifications = state.requests.isNotEmpty;
                }

                return Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        hasNotifications ? Icons.notifications_active : Icons.notifications_none,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        if (hasNotifications) {
                          _showFriendRequestsModal(context, state as FriendRequestsLoaded);
                        }
                      },
                    ),
                    if (hasNotifications)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${(state as FriendRequestsLoaded).requests.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.go(AppRoutes.profile),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.backgroundCard,
                child: ClipOval(
                  child: user?.photoUrl != null
                      ? Image.network(user!.photoUrl!)
                      : const Icon(Icons.person_outline, color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showFriendRequestsModal(BuildContext context, FriendRequestsLoaded state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: context.read<FriendRequestsCubit>(),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Solicitações de Amizade',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (state.requests.isEmpty)
                  const Text(
                    'Nenhuma solicitação pendente.',
                    style: TextStyle(color: Colors.white70),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.requests.length,
                      itemBuilder: (context, index) {
                        final request = state.requests[index];
                        final fromUser = request['fromUser'] as Map<String, dynamic>?;
                        final fromName = fromUser?['name'] ?? 'Usuário';
                        final fromUsername = fromUser?['username'] ?? '';

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.backgroundCard,
                            child: const Icon(Icons.person, color: AppColors.primary),
                          ),
                          title: Text(
                            fromName,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '@$fromUsername',
                            style: const TextStyle(color: Colors.white60),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () {
                                  context.read<FriendRequestsCubit>().acceptRequest(request['id']);
                                  Navigator.pop(context);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  context.read<FriendRequestsCubit>().declineRequest(request['id']);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
