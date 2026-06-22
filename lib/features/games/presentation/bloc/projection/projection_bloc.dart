import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/repositories/portfolio_repository.dart';
import '../../../domain/usecases/projection/run_projection_usecase.dart';
import '../../../../../core/error/failures.dart';
import 'projection_event.dart';
import 'projection_state.dart';

@injectable
class ProjectionBloc extends Bloc<ProjectionEvent, ProjectionState> {
  final RunProjectionUseCase _runProjection;
  final PortfolioRepository _repository;

  ProjectionBloc(this._runProjection, this._repository)
    : super(
        ProjectionSetup(
          assets: const [],
          periodMonths: 60,
          periodLabel: '5 anos',
        ),
      ) {
    on<AddProjectionAsset>(_onAdd);
    on<RemoveProjectionAsset>(_onRemove);
    on<UpdateProjectionAmount>(_onUpdateAmount);
    on<SelectProjectionPeriod>(_onSelectPeriod);
    on<RunSimulation>(_onRun);
    on<LoadProjectionHistory>(_onLoadHistory);
  }

  void _onAdd(AddProjectionAsset event, Emitter<ProjectionState> emit) {
    final alreadyAdded = state.assets.any(
      (a) => a.ticker == event.input.ticker,
    );
    if (alreadyAdded) return;
    emit(
      ProjectionSetup(
        assets: [...state.assets, event.input],
        periodMonths: state.periodMonths,
        periodLabel: state.periodLabel,
      ),
    );
  }

  void _onRemove(RemoveProjectionAsset event, Emitter<ProjectionState> emit) {
    emit(
      ProjectionSetup(
        assets: state.assets.where((a) => a.ticker != event.ticker).toList(),
        periodMonths: state.periodMonths,
        periodLabel: state.periodLabel,
      ),
    );
  }

  void _onUpdateAmount(
    UpdateProjectionAmount event,
    Emitter<ProjectionState> emit,
  ) {
    emit(
      ProjectionSetup(
        assets: state.assets
            .map(
              (a) => a.ticker == event.ticker
                  ? a.copyWith(amount: event.amount)
                  : a,
            )
            .toList(),
        periodMonths: state.periodMonths,
        periodLabel: state.periodLabel,
      ),
    );
  }

  void _onSelectPeriod(
    SelectProjectionPeriod event,
    Emitter<ProjectionState> emit,
  ) {
    emit(
      ProjectionSetup(
        assets: state.assets,
        periodMonths: event.periodMonths,
        periodLabel: event.periodLabel,
      ),
    );
  }

  Future<void> _onLoadHistory(
    LoadProjectionHistory event,
    Emitter<ProjectionState> emit,
  ) async {
    final result = await _repository.getProjectionHistory();
    result.fold(
      (Failure f) => emit(
        ProjectionError(
          assets: state.assets,
          periodMonths: state.periodMonths,
          periodLabel: state.periodLabel,
          message: f.message,
        ),
      ),
      (history) => emit(
        ProjectionHistoryLoaded(
          assets: state.assets,
          periodMonths: state.periodMonths,
          periodLabel: state.periodLabel,
          history: history,
        ),
      ),
    );
  }

  Future<void> _onRun(
    RunSimulation event,
    Emitter<ProjectionState> emit,
  ) async {
    emit(
      ProjectionLoading(
        assets: state.assets,
        periodMonths: state.periodMonths,
        periodLabel: state.periodLabel,
      ),
    );

    final result = await _runProjection(
      assets: state.assets,
      periodMonths: state.periodMonths,
      periodLabel: state.periodLabel,
    );

    result.fold(
      (Failure f) => emit(
        ProjectionError(
          assets: state.assets,
          periodMonths: state.periodMonths,
          periodLabel: state.periodLabel,
          message: f.message,
        ),
      ),
      (simulation) => emit(
        ProjectionComplete(
          assets: state.assets,
          periodMonths: state.periodMonths,
          periodLabel: state.periodLabel,
          result: simulation,
        ),
      ),
    );
  }
}
