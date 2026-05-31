import 'package:equatable/equatable.dart';

class Challenge extends Equatable {
  final String id;
  final String tag;
  final String title;
  final String description;
  final int points;
  final String iconType; // emoji_events, rocket, etc.

  const Challenge({
    required this.id,
    required this.tag,
    required this.title,
    required this.description,
    required this.points,
    this.iconType = 'emoji_events',
  });

  @override
  List<Object?> get props => [id, tag, title, description, points, iconType];
}
