import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/user_profile_model.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return Right(UserProfileModel.fromFirestore(doc));
      } else {
        return Left(ServerFailure('Perfil não encontrado'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(UserProfile profile) async {
    try {
      final model = UserProfileModel(
        id: profile.id,
        name: profile.name,
        email: profile.email,
        photoUrl: profile.photoUrl,
        xp: profile.xp,
        level: profile.level,
        league: profile.league,
        subtitle: profile.subtitle,
        completedCoursesCount: profile.completedCoursesCount,
        balance: profile.balance,
        assetTypesCount: profile.assetTypesCount,
        loginStreak: profile.loginStreak,
        completedMissionsIds: profile.completedMissionsIds,
        friendIds: profile.friendIds,
        memberSince: profile.memberSince,
      );
      await _firestore.collection('users').doc(profile.id).set(model.toFirestore(), SetOptions(merge: true));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserProfile>>> getRanking() async {
    try {
      final query = await _firestore
          .collection('users')
          .orderBy('xp', descending: true)
          .limit(20)
          .get();
      
      final ranking = query.docs
          .map((doc) => UserProfileModel.fromFirestore(doc))
          .toList();
          
      return Right(ranking);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserProfile>>> getFriendsRanking(List<String> friendIds) async {
    try {
      if (friendIds.isEmpty) return const Right([]);

      final query = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds.take(30).toList())
          .get();

      final ranking = query.docs
          .map((doc) => UserProfileModel.fromFirestore(doc))
          .toList();

      ranking.sort((a, b) => b.xp.compareTo(a.xp));

      return Right(ranking);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfile?>> searchUserByName(String name) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return const Right(null);
      
      return Right(UserProfileModel.fromFirestore(query.docs.first));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addFriend(String userId, String friendId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'friendIds': FieldValue.arrayUnion([friendId]),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
