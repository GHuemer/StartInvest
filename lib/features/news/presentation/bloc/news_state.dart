import 'package:equatable/equatable.dart';
import '../../domain/entities/news_entry.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<NewsEntry> allNews;
  final List<NewsEntry> filteredNews;
  final String searchQuery;
  final String selectedCategory;

  const NewsLoaded({
    required this.allNews,
    required this.filteredNews,
    this.searchQuery = '',
    this.selectedCategory = 'Tudo',
  });

  @override
  List<Object?> get props => [
    allNews,
    filteredNews,
    searchQuery,
    selectedCategory,
  ];

  NewsLoaded copyWith({
    List<NewsEntry>? allNews,
    List<NewsEntry>? filteredNews,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return NewsLoaded(
      allNews: allNews ?? this.allNews,
      filteredNews: filteredNews ?? this.filteredNews,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class NewsError extends NewsState {
  final String message;
  const NewsError(this.message);

  @override
  List<Object?> get props => [message];
}
