import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/content_repository.dart';
import 'content_event.dart';
import 'content_state.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final ContentRepository _contentRepository;

  ContentBloc({required ContentRepository contentRepository})
    : _contentRepository = contentRepository,
      super(const ContentState()) {
    on<ContentStarted>(_onContentStarted);
  }

  Future<void> _onContentStarted(
    ContentStarted event,
    Emitter<ContentState> emit,
  ) async {
    emit(state.copyWith(status: ContentStatus.loading));
    try {
      final results = await Future.wait([
        _contentRepository.getArticles(),
        _contentRepository.getCourses(),
      ]);

      emit(
        state.copyWith(
          status: ContentStatus.success,
          articles: results[0] as List<Article>,
          courses: results[1] as List<Course>,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ContentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
