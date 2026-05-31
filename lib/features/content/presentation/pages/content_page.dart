import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/content_bloc.dart';
import '../bloc/content_event.dart';
import '../widgets/content_view.dart';
import '../../data/repositories/content_repository_impl.dart';

class ContentPage extends StatelessWidget {
  const ContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContentBloc(
        contentRepository: ContentRepositoryImpl(),
      )..add(ContentStarted()),
      child: const ContentView(),
    );
  }
}
