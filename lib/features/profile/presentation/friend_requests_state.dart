part of 'friend_requests_cubit.dart';

abstract class FriendRequestsState extends Equatable {
  const FriendRequestsState();

  @override
  List<Object> get props => [];
}

class FriendRequestsInitial extends FriendRequestsState {}

class FriendRequestsLoaded extends FriendRequestsState {
  final List<Map<String, dynamic>> requests;

  const FriendRequestsLoaded(this.requests);

  @override
  List<Object> get props => [requests];
}
