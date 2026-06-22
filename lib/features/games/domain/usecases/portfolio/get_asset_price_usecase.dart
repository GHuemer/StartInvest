import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/market_asset.dart';
import '../../entities/position.dart';
import '../../repositories/portfolio_repository.dart';

@injectable
class GetAssetPriceUseCase {
  final PortfolioRepository _repository;
  GetAssetPriceUseCase(this._repository);

  Future<Either<Failure, MarketAsset>> call(String ticker, AssetType type) =>
      _repository.getAssetPrice(ticker, type);
}
