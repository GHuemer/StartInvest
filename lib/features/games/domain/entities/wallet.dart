import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String id;
  final String userId;
  final String name;
  final double startingBalance;
  final double availableBalance;
  final DateTime createdAt;

  const Wallet({
    required this.id,
    required this.userId,
    required this.name,
    required this.startingBalance,
    required this.availableBalance,
    required this.createdAt,
  });

  double get totalInvested => startingBalance - availableBalance;

  Wallet copyWith({String? name, double? availableBalance}) {
    return Wallet(
      id: id,
      userId: userId,
      name: name ?? this.name,
      startingBalance: startingBalance,
      availableBalance: availableBalance ?? this.availableBalance,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    startingBalance,
    availableBalance,
    createdAt,
  ];
}
