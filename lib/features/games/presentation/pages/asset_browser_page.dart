import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/market_asset.dart';
import '../../domain/entities/position.dart';
import '../../data/datasources/market_api_datasource.dart';
import '../widgets/portfolio/asset_tile.dart';
import 'buy_sell_page.dart';

class AssetBrowserPage extends StatefulWidget {
  final String walletId;
  final double availableBalance;
  final VoidCallback onTradeComplete;

  const AssetBrowserPage({
    super.key,
    required this.walletId,
    required this.availableBalance,
    required this.onTradeComplete,
  });

  @override
  State<AssetBrowserPage> createState() => _AssetBrowserPageState();
}

class _AssetBrowserPageState extends State<AssetBrowserPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _search = '';
  final Map<AssetType, List<MarketAsset>> _cache = {};
  final Map<AssetType, bool> _loading = {
    AssetType.stock: false,
    AssetType.fii: false,
    AssetType.fixedIncome: false,
  };

  final _tabs = const [
    (AssetType.stock, 'Ações'),
    (AssetType.fii, 'FIIs'),
    (AssetType.fixedIncome, 'Renda Fixa'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChange);
    _loadAssets(AssetType.stock);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChange() {
    if (_tabController.indexIsChanging) return;
    final type = _tabs[_tabController.index].$1;
    if (!_cache.containsKey(type)) _loadAssets(type);
  }

  Future<void> _loadAssets(AssetType type) async {
    if (_loading[type] == true) return;
    setState(() => _loading[type] = true);
    try {
      final ds = getIt<MarketApiDataSource>();
      final assets = await ds.getAssetsByType(type);
      if (mounted) setState(() => _cache[type] = assets);
    } catch (e) {
      debugPrint('[AssetBrowser] Erro ao carregar ativos: $e');
    } finally {
      if (mounted) setState(() => _loading[type] = false);
    }
  }

  List<MarketAsset> _filtered(AssetType type) {
    final assets = _cache[type] ?? [];
    if (_search.isEmpty) return assets;
    final q = _search.toUpperCase();
    return assets
        .where((a) => a.ticker.contains(q) || a.name.toUpperCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AppBackButton(),
        title: const Text(
          'Buscar Ativos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.white54,
          tabs: _tabs.map((t) => Tab(text: t.$2)).toList(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por ticker ou nome...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                filled: true,
                fillColor: AppColors.backgroundCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs
                  .map(
                    (t) => _AssetList(
                      assets: _filtered(t.$1),
                      isLoading: _loading[t.$1] ?? false,
                      onRefresh: () => _loadAssets(t.$1),
                      onTap: (asset) => _openBuySell(context, asset),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _openBuySell(BuildContext context, MarketAsset asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BuySellPage(
          walletId: widget.walletId,
          ticker: asset.ticker,
          assetType: asset.type,
          currentPrice: asset.currentPrice,
          changePercent: asset.changePercent,
          assetName: asset.name,
          mode: TradingMode.buy,
          availableBalance: widget.availableBalance,
          onTradeComplete: () {
            Navigator.pop(context);
            widget.onTradeComplete();
          },
        ),
      ),
    );
  }
}

class _AssetList extends StatelessWidget {
  final List<MarketAsset> assets;
  final bool isLoading;
  final VoidCallback onRefresh;
  final void Function(MarketAsset) onTap;

  const _AssetList({
    required this.assets,
    required this.isLoading,
    required this.onRefresh,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.white24),
            const SizedBox(height: 12),
            const Text(
              'Nenhum ativo encontrado',
              style: TextStyle(color: Colors.white38),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRefresh,
              child: const Text(
                'Tentar novamente',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: assets.length,
        separatorBuilder: (_, __) => const Divider(
          color: AppColors.divider,
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (_, i) =>
            AssetTile(asset: assets[i], onTap: () => onTap(assets[i])),
      ),
    );
  }
}
