import 'package:flutter/material.dart';
import '../widgets/course_player_view.dart';

class CoursePlayerPage extends StatelessWidget {
  final String title;
  final String? videoUrl;

  const CoursePlayerPage({super.key, required this.title, this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return CoursePlayerView(title: title, videoUrl: videoUrl);
  }
}
