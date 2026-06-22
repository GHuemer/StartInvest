import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile(String uid);
  Future<Either<Failure, void>> updateUserProfile(UserProfile profile);
  Future<Either<Failure, List<UserProfile>>> getRanking();
  Future<Either<Failure, List<UserProfile>>> getFriendsRanking(
    List<String> friendIds,
  );
  Future<Either<Failure, UserProfile?>> searchUserByName(String name);
  Future<Either<Failure, void>> addFriend(String userId, String friendId);

  // Novos métodos para o sistema de solicitações
  Future<Either<Failure, void>> sendFriendRequest(String fromId, String toId);
  Stream<List<Map<String, dynamic>>> watchFriendRequests(String userId);
  Future<Either<Failure, void>> respondToFriendRequest(
    String requestId,
    bool accept,
  );
}
