import 'package:equatable/equatable.dart';
import '../../../domain/entities/simulation_result.dart';

abstract class ProjectionEvent extends Equatable {
  const ProjectionEvent();
  @override
  List<Object?> get props => [];
}

class AddProjectionAsset extends ProjectionEvent {
  final ProjectionAssetInput input;
  const AddProjectionAsset(this.input);
  @override
  List<Object?> get props => [input];
}

class RemoveProjectionAsset extends ProjectionEvent {
  final String ticker;
  const RemoveProjectionAsset(this.ticker);
  @override
  List<Object?> get props => [ticker];
}

class UpdateProjectionAmount extends ProjectionEvent {
  final String ticker;
  final double amount;
  const UpdateProjectionAmount(this.ticker, this.amount);
  @override
  List<Object?> get props => [ticker, amount];
}

class SelectProjectionPeriod extends ProjectionEvent {
  final int periodMonths;
  final String periodLabel;
  const SelectProjectionPeriod(this.periodMonths, this.periodLabel);
  @override
  List<Object?> get props => [periodMonths];
}

class RunSimulation extends ProjectionEvent {
  const RunSimulation();
}

class LoadProjectionHistory extends ProjectionEvent {
  const LoadProjectionHistory();
}
