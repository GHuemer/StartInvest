import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/trade.dart';
import '../../repositories/portfolio_repository.dart';

@injectable
class GetTradesUseCase {
  final PortfolioRepository _repository;
  GetTradesUseCase(this._repository);

  Future<Either<Failure, List<Trade>>> call(String walletId) =>
      _repository.getTrades(walletId);
}
