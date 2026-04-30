import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final _mockUser = const AppUser(
    id: 'mock-uid-001',
    name: 'Gabriel Huemer',
    email: 'gabriel@startinvest.com',
    xp: 2781,
    level: 3,
    league: 'elite',
  );

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    return Right(_mockUser);
  }

  @override
  Future<Either<Failure, AppUser>> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isEmpty) return const Left(AuthFailure('E-mail inválido'));
    return Right(_mockUser.copyWith(email: email));
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Right(null);
  }

  @override
  Stream<AppUser?> get authStateChanges => Stream.value(null);
}

extension on AppUser {
  AppUser copyWith({String? id, String? name, String? email, String? photoUrl, int? xp, int? level, String? league}) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      league: league ?? this.league,
    );
  }
}
