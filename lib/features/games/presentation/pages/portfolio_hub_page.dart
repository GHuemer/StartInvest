import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/wallet.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/di/injection.dart';
import '../bloc/portfolio/portfolio_bloc.dart';
import '../bloc/portfolio/portfolio_event.dart';
import '../bloc/portfolio/portfolio_state.dart';
import '../widgets/portfolio/wallet_card.dart';
import 'create_wallet_page.dart';
import 'wallet_detail_page.dart';

class PortfolioHubPage extends StatelessWidget {
  const PortfolioHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PortfolioBloc>()..add(const LoadWallets()),
      child: const _PortfolioHubView(),
    );
  }
}

class _PortfolioHubView extends StatelessWidget {
  const _PortfolioHubView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Text(
          'Simulador de Carteira',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: BlocConsumer<PortfolioBloc, PortfolioState>(
        listener: (context, state) {
          if (state is WalletCreated) {
            context.read<PortfolioBloc>().add(const LoadWallets());
          } else if (state is PortfolioError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.textNegative,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PortfolioLoading || state is PortfolioInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is WalletsLoaded) {
            return _buildContent(context, state);
          }
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        },
      ),
      floatingActionButton: BlocBuilder<PortfolioBloc, PortfolioState>(
        builder: (context, state) {
          final count = state is WalletsLoaded ? state.wallets.length : 3;
          if (count >= 3) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _openCreateWallet(context),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text(
              'Nova Carteira',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WalletsLoaded state) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    if (state.wallets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: Colors.white38,
              ),
              const SizedBox(height: 24),
              const Text(
                'Nenhuma carteira ainda',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Crie sua primeira carteira e comece a simular investimentos. Ganhe XP conforme seu lucro!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _openCreateWallet(context),
                icon: const Icon(Icons.add),
                label: const Text('Criar Carteira'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<PortfolioBloc>().add(const LoadWallets()),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
        children: [
          _SummaryHeader(wallets: state.wallets, fmt: fmt),
          const SizedBox(height: 24),
          const Text(
            'Suas Carteiras',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ...state.wallets.map(
            (w) => WalletCard(
              wallet: w,
              positions: state.positionsMap[w.id] ?? const [],
              onTap: () => _openWallet(context, w.id, w.name),
            ),
          ),
          if (state.wallets.length < 3) ...[
            const SizedBox(height: 8),
            Text(
              '${3 - state.wallets.length} carteira${3 - state.wallets.length > 1 ? 's' : ''} disponível${3 - state.wallets.length > 1 ? 'is' : ''}',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          _ChallengesSection(),
        ],
      ),
    );
  }

  void _openCreateWallet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateWalletPage()),
    ).then((_) => context.read<PortfolioBloc>().add(const LoadWallets()));
  }

  void _openWallet(BuildContext context, String walletId, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalletDetailPage(walletId: walletId, walletName: name),
      ),
    ).then((_) => context.read<PortfolioBloc>().add(const LoadWallets()));
  }
}

class _SummaryHeader extends StatelessWidget {
  final List<Wallet> wallets;
  final NumberFormat fmt;
  const _SummaryHeader({required this.wallets, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2E1A), Color(0xFF0F1F0F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visão Geral',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 4),
          const Text(
            'Portfólio Consolidado',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${wallets.length} de 3 carteiras ativas',
            style: const TextStyle(color: AppColors.primary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ChallengesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final challenges = [
      (
        'Investidor Iniciante',
        'Realize sua primeira compra',
        Icons.shopping_cart_outlined,
        10,
      ),
      (
        'First Blood',
        'Venda com lucro pela primeira vez',
        Icons.trending_up,
        15,
      ),
      ('Portfólio Verde', 'Todas posições em lucro', Icons.eco_outlined, 30),
      (
        'Triplicar Categorias',
        'Tenha Ações, FIIs e Renda Fixa',
        Icons.pie_chart_outline,
        40,
      ),
      (
        'Arrojado Vencedor',
        'Venda uma Ação com +20% lucro',
        Icons.rocket_launch_outlined,
        80,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Desafios do Simulador',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...challenges.map(
          (c) => _ChallengeTile(
            title: c.$1,
            description: c.$2,
            icon: c.$3,
            xp: c.$4,
          ),
        ),
      ],
    );
  }
}

class _ChallengeTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final int xp;
  const _ChallengeTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+$xp XP',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
