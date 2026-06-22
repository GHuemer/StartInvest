import 'package:flutter/material.dart';
import '../../domain/entities/article.dart';
import '../widgets/article_detail_view.dart';

class ArticleDetailPage extends StatelessWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return ArticleDetailView(article: article);
  }
}
