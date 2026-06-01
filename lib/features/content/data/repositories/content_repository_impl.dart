import '../../domain/entities/article.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/content_repository.dart';
import '../models/article_model.dart';
import '../models/course_model.dart';

class ContentRepositoryImpl implements ContentRepository {
  @override
  Future<List<Article>> getArticles() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      ArticleModel(
        id: '1',
        title: 'O que é o Tesouro Direto?',
        content:
            '''O Tesouro Direto é um programa do Tesouro Nacional desenvolvido em parceria com a B3 para a venda de títulos públicos federais para pessoas físicas, por meio da internet.

Lançado em 2002, o programa surgiu com o objetivo de democratizar o acesso aos títulos públicos, permitindo aplicações com valores baixos (a partir de R\$ 30,00).

Antes do Tesouro Direto, o investimento em títulos públicos era acessível apenas para grandes investidores e fundos de investimento, que compravam grandes lotes em leilões do Banco Central.

Os títulos públicos são ativos de renda fixa. Isso significa que, no momento da compra, você já sabe como o seu dinheiro será remunerado. Eles são considerados os investimentos de menor risco em uma economia, pois são garantidos pelo Governo Federal.''',
        author: 'Ana Silva',
        readingTime: '5 min',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        imageUrl:
            'https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?q=80&w=2071&auto=format&fit=crop',
      ),
      ArticleModel(
        id: '2',
        title: 'Como diversificar sua carteira',
        content:
            'Diversificação é a estratégia de distribuir seus investimentos por diferentes classes de ativos para reduzir riscos...',
        author: 'Bruno Rocha',
        readingTime: '7 min',
        publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  @override
  Future<List<Course>> getCourses() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const CourseModel(
        id: 'c1',
        title: 'Bolsa de Valores I',
        videoUrl: null, // Testando estado sem conteúdo
      ),
      const CourseModel(
        id: 'c2',
        title: 'Planejamento Pessoal',
        videoUrl: null,
      ),
      const CourseModel(
        id: 'c3',
        title: 'Cripto para Iniciantes',
        videoUrl: 'https://example.com/video', // Testando com link
      ),
    ];
  }
}
