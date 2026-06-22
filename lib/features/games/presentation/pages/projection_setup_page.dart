import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/position.dart';
import '../../domain/entities/simulation_result.dart';
import '../../domain/usecases/projection/run_projection_usecase.dart';
import '../bloc/projection/projection_bloc.dart';
import '../bloc/projection/projection_event.dart';
import '../bloc/projection/projection_state.dart';
import 'projection_history_page.dart';
import 'projection_result_page.dart';

class ProjectionSetupPage extends StatelessWidget {
  const ProjectionSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProjectionBloc>(),
      child: const _ProjectionSetupView(),
    );
  }
}

class _ProjectionSetupView extends StatelessWidget {
  const _ProjectionSetupView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectionBloc, ProjectionState>(
      listener: (context, state) {
        if (state is ProjectionComplete) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectionResultPage(result: state.result),
            ),
          );
        } else if (state is ProjectionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.textNegative,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ProjectionLoading;
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const AppBackButton(),
            title: const Text(
              'Projetor de Investimentos',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.history, color: Colors.white70),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<ProjectionBloc>(),
                      child: const ProjectionHistoryPage(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                children: [
                  _InfoBanner(),
                  const SizedBox(height: 24),
                  _PeriodSelector(
                    selected: state.periodMonths,
                    onSelect: (months, label) => context
                        .read<ProjectionBloc>()
                        .add(SelectProjectionPeriod(months, label)),
                  ),
                  const SizedBox(height: 24),
                  _AssetList(
                    assets: state.assets,
                    onRemove: (t) => context
                        .read<ProjectionBloc>()
                        .add(RemoveProjectionAsset(t)),
                    onEditAmount: (ticker, current) =>
                        _showAmountDialog(context, ticker, current),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showAddAssetSheet(context),
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    label: const Text(
                      'Adicionar ativo',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              if (isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text(
                          'Calculando projeção...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: _SimularButton(
            enabled: state.assets.isNotEmpty && !isLoading,
            onPressed: () =>
                context.read<ProjectionBloc>().add(const RunSimulation()),
          ),
        );
      },
    );
  }

  void _showAmountDialog(
      BuildContext context, String ticker, double current) {
    final ctrl = TextEditingController(
      text: current.toStringAsFixed(2).replaceAll('.', ','),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: Text(
          'Valor em $ticker',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
          ],
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixText: 'R\$ ',
            prefixStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: AppColors.backgroundDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              final val =
                  double.tryParse(ctrl.text.replaceAll(',', '.')) ?? 0;
              if (val > 0) {
                context
                    .read<ProjectionBloc>()
                    .add(UpdateProjectionAmount(ticker, val));
              }
              Navigator.pop(ctx);
            },
            child: const Text('OK',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddAssetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ProjectionBloc>(),
        child: const _AddAssetSheet(),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2E1A), Color(0xFF0F1F0F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_up, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simulação futura',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  'Baseado no desempenho histórico de cada ativo. Passado não garante futuro.',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '+5 XP',
              style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final int selected;
  final void Function(int, String) onSelect;
  const _PeriodSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Período de projeção',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: RunProjectionUseCase.periods.map((p) {
              final isSelected = p.$1 == selected;
              return GestureDetector(
                onTap: () => onSelect(p.$1, p.$2),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.cardBorder.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    p.$2,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _AssetList extends StatelessWidget {
  final List<ProjectionAssetInput> assets;
  final void Function(String) onRemove;
  final void Function(String, double) onEditAmount;

  const _AssetList({
    required this.assets,
    required this.onRemove,
    required this.onEditAmount,
  });

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.add_chart, color: Colors.white24, size: 40),
              SizedBox(height: 12),
              Text(
                'Nenhum ativo adicionado.\nToque em "Adicionar ativo" abaixo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seus ativos',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        ...assets.map((a) => _AssetItem(
              asset: a,
              fmt: fmt,
              onRemove: () => onRemove(a.ticker),
              onEditAmount: () => onEditAmount(a.ticker, a.amount),
            )),
      ],
    );
  }
}

class _AssetItem extends StatelessWidget {
  final ProjectionAssetInput asset;
  final NumberFormat fmt;
  final VoidCallback onRemove;
  final VoidCallback onEditAmount;

  const _AssetItem({
    required this.asset,
    required this.fmt,
    required this.onRemove,
    required this.onEditAmount,
  });

  Color get _typeColor => switch (asset.assetType) {
    AssetType.stock => const Color(0xFF4CAF50),
    AssetType.fii => const Color(0xFF2196F3),
    AssetType.fixedIncome => const Color(0xFFFF9800),
  };

  String get _typeLabel => switch (asset.assetType) {
    AssetType.stock => 'Ação',
    AssetType.fii => 'FII',
    AssetType.fixedIncome => 'RF',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _typeColor.withValues(alpha: 0.15),
            radius: 20,
            child: Text(
              _typeLabel,
              style: TextStyle(
                  color: _typeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.ticker,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                Text(
                  asset.name,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEditAmount,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                fmt.format(asset.amount),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, color: Colors.white38, size: 18),
          ),
        ],
      ),
    );
  }
}

class _SimularButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;
  const _SimularButton({required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Simular',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: Colors.black, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────

class _AddAssetSheet extends StatefulWidget {
  const _AddAssetSheet();

  @override
  State<_AddAssetSheet> createState() => _AddAssetSheetState();
}

class _AddAssetSheetState extends State<_AddAssetSheet> {
  AssetType _selectedType = AssetType.stock;
  ProjectionAssetInput? _selectedAsset;
  final _amountCtrl = TextEditingController();

  static const _stocks = [
    ('PETR4', 'Petrobras PN'),
    ('VALE3', 'Vale ON'),
    ('ITUB4', 'Itaú Unibanco PN'),
    ('BBAS3', 'Banco do Brasil ON'),
    ('ABEV3', 'Ambev ON'),
    ('WEGE3', 'WEG ON'),
    ('RENT3', 'Localiza ON'),
    ('MGLU3', 'Magazine Luiza ON'),
  ];

  static const _fiis = [
    ('MXRF11', 'Maxi Renda FII'),
    ('HGLG11', 'CSHG Logística FII'),
    ('XPML11', 'XP Malls FII'),
    ('KNRI11', 'Kinea Renda Imob. FII'),
    ('VISC11', 'Vinci Shopping Centers FII'),
  ];

  static const _rf = [
    ('CDB_CDI_100', 'CDB 100% CDI'),
    ('CDB_CDI_110', 'CDB 110% CDI'),
    ('TESOURO_SELIC', 'Tesouro Selic 2027'),
    ('TESOURO_IPCA', 'Tesouro IPCA+ 2029'),
  ];

  List<(String, String)> get _catalog => switch (_selectedType) {
    AssetType.stock => _stocks,
    AssetType.fii => _fiis,
    AssetType.fixedIncome => _rf,
  };

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Adicionar ativo',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _TypeTabs(
              selected: _selectedType,
              onSelect: (t) => setState(() {
                _selectedType = t;
                _selectedAsset = null;
              }),
            ),
            const SizedBox(height: 12),
            if (_selectedAsset == null)
              SizedBox(
                height: 220,
                child: ListView(
                  children: _catalog
                      .map((item) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              item.$1,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              item.$2,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12),
                            ),
                            trailing: const Icon(Icons.add_circle_outline,
                                color: AppColors.primary),
                            onTap: () => setState(() {
                              _selectedAsset = ProjectionAssetInput(
                                ticker: item.$1,
                                name: item.$2,
                                assetType: _selectedType,
                                amount: 1000,
                              );
                              _amountCtrl.text = '1000,00';
                            }),
                          ))
                      .toList(),
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedAsset!.ticker,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _selectedAsset!.name,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _selectedAsset = null),
                      child: const Icon(Icons.edit_outlined,
                          color: Colors.white38, size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Valor a investir',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountCtrl,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                ],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixText: 'R\$ ',
                  prefixStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: AppColors.backgroundDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Adicionar',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirm() {
    final val =
        double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
    if (val <= 0 || _selectedAsset == null) return;
    context.read<ProjectionBloc>().add(
          AddProjectionAsset(_selectedAsset!.copyWith(amount: val)),
        );
    Navigator.pop(context);
  }
}

class _TypeTabs extends StatelessWidget {
  final AssetType selected;
  final void Function(AssetType) onSelect;
  const _TypeTabs({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const types = [
      (AssetType.stock, 'Ações'),
      (AssetType.fii, 'FIIs'),
      (AssetType.fixedIncome, 'Renda Fixa'),
    ];
    return Row(
      children: types.map((t) {
        final isSelected = t.$1 == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(t.$1),
            child: Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                t.$2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white54,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
