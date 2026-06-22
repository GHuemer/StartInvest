import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/position.dart';
import '../../repositories/portfolio_repository.dart';

@injectable
class GetPositionsUseCase {
  final PortfolioRepository _repository;
  GetPositionsUseCase(this._repository);

  Future<Either<Failure, List<Position>>> call(String walletId) =>
      _repository.getPositions(walletId);
}
