import 'package:equatable/equatable.dart';

class Course extends Equatable {
  final String id;
  final String title;
  final String? videoUrl;
  final String? thumbnailUrl;

  const Course({
    required this.id,
    required this.title,
    this.videoUrl,
    this.thumbnailUrl,
  });

  @override
  List<Object?> get props => [id, title, videoUrl, thumbnailUrl];
}
