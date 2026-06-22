import 'package:equatable/equatable.dart';
import '../../../domain/entities/simulation_result.dart';

abstract class ProjectionState extends Equatable {
  final List<ProjectionAssetInput> assets;
  final int periodMonths;
  final String periodLabel;

  const ProjectionState({
    required this.assets,
    required this.periodMonths,
    required this.periodLabel,
  });

  @override
  List<Object?> get props => [assets, periodMonths];
}

class ProjectionSetup extends ProjectionState {
  const ProjectionSetup({
    required super.assets,
    required super.periodMonths,
    required super.periodLabel,
  });
}

class ProjectionLoading extends ProjectionState {
  const ProjectionLoading({
    required super.assets,
    required super.periodMonths,
    required super.periodLabel,
  });
}

class ProjectionComplete extends ProjectionState {
  final SimulationResult result;
  const ProjectionComplete({
    required super.assets,
    required super.periodMonths,
    required super.periodLabel,
    required this.result,
  });
  @override
  List<Object?> get props => [...super.props, result];
}

class ProjectionError extends ProjectionState {
  final String message;
  const ProjectionError({
    required super.assets,
    required super.periodMonths,
    required super.periodLabel,
    required this.message,
  });
  @override
  List<Object?> get props => [...super.props, message];
}

class ProjectionHistoryLoaded extends ProjectionState {
  final List<SimulationResult> history;
  const ProjectionHistoryLoaded({
    required super.assets,
    required super.periodMonths,
    required super.periodLabel,
    required this.history,
  });
  @override
  List<Object?> get props => [...super.props, history];
}
