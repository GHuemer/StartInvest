import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/news_repository.dart';
import 'news_state.dart';

@injectable
class NewsCubit extends Cubit<NewsState> {
  final NewsRepository _repository;

  NewsCubit(this._repository) : super(NewsInitial());

  Future<void> init() async {
    emit(NewsLoading());
    try {
      final news = await _repository.getNews();
      emit(NewsLoaded(allNews: news, filteredNews: news));
    } catch (e) {
      emit(const NewsError('Erro ao carregar notícias'));
    }
  }

  void searchNews(String query) {
    if (state is NewsLoaded) {
      final currentState = state as NewsLoaded;
      _applyFilters(query, currentState.selectedCategory);
    }
  }

  void selectCategory(String category) {
    if (state is NewsLoaded) {
      final currentState = state as NewsLoaded;
      _applyFilters(currentState.searchQuery, category);
    }
  }

  void _applyFilters(String query, String category) {
    if (state is NewsLoaded) {
      final currentState = state as NewsLoaded;
      
      var filtered = currentState.allNews;

      // Filter by category
      if (category != 'Tudo') {
        final categoryMap = {
          'Ações': 'stocks',
          'Cripto': 'crypto',
          'Economia': 'economy',
          'Tech': 'tech',
        };
        final categoryKey = categoryMap[category] ?? category.toLowerCase();
        filtered = filtered.where((n) => n.category == categoryKey).toList();
      }

      // Filter by search query
      if (query.isNotEmpty) {
        filtered = filtered.where((n) {
          return n.title.toLowerCase().contains(query.toLowerCase()) ||
                 n.tag.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }

      emit(currentState.copyWith(
        filteredNews: filtered,
        searchQuery: query,
        selectedCategory: category,
      ));
    }
  }
}
