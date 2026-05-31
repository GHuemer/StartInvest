import '../../domain/entities/challenge.dart';

class ChallengeModel extends Challenge {
  const ChallengeModel({
    required super.id,
    required super.tag,
    required super.title,
    required super.description,
    required super.points,
    super.iconType,
  });

  factory ChallengeModel.fromMap(Map<String, dynamic> map, String id) {
    return ChallengeModel(
      id: id,
      tag: map['tag'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      points: (map['points'] ?? 0) as int,
      iconType: map['iconType'] ?? 'emoji_events',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tag': tag,
      'title': title,
      'description': description,
      'points': points,
      'iconType': iconType,
    };
  }
}
