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

Por que investir no Tesouro Direto?
Antes do Tesouro Direto, o investimento em títulos públicos era acessível apenas para grandes investidores e fundos de investimento, que compravam grandes lotes em leilões do Banco Central.

Os títulos públicos são ativos de renda fixa. Isso significa que, no momento da compra, você já sabe como o seu dinheiro será remunerado. Eles são considerados os investimentos de menor risco em uma economia, pois são garantidos pelo Governo Federal.

Principais Categorias:
1. Tesouro Selic: Ideal para reserva de emergência, pois sua rentabilidade acompanha a taxa básica de juros e possui liquidez diária (D+0).
2. Tesouro Prefixado: Você sabe exatamente quanto receberá no final, independente das variações da economia. É bom para quando se acredita que os juros vão cair.
3. Tesouro IPCA+: Protege seu poder de compra, garantindo um rendimento acima da inflação (IPCA). Ideal para aposentadoria.''',
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
            '''Diversificação é a estratégia de distribuir seus investimentos por diferentes classes de ativos para reduzir riscos. A ideia é que, se um ativo for mal, outros podem compensar a perda.

A Estratégia dos Ovos na Cesta
A regra de ouro é: nunca coloque todos os ovos na mesma cesta. Se a cesta cair, todos se quebram. No mundo das finanças, a "cesta" é o tipo de investimento.

Como montar uma carteira equilibrada:
- Renda Fixa (Segurança): Proporciona estabilidade. Inclua CDBs, Tesouro Direto e LCIs.
- Renda Variável (Crescimento): Foco em aumento de patrimônio. Ações e Fundos Imobiliários (FIIs).
- Ativos Internacionais (Proteção): Proteção contra o risco Brasil (Dólar). BDRs ou ETFs globais.
- Reserva de Emergência: O alicerce da sua vida financeira, com liquidez imediata.

Diversificar não é apenas ter muitos ativos, mas sim ter ativos que não andam juntos (correlação baixa).''',
        author: 'Bruno Rocha',
        readingTime: '7 min',
        publishedAt: DateTime.now().subtract(const Duration(days: 5)),
        imageUrl: 'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?q=80&w=2070&auto=format&fit=crop',
      ),
      ArticleModel(
        id: '3',
        title: 'Reserva de Emergência: O Guia',
        content:
            '''A reserva de emergência é o montante financeiro que deve ser guardado para cobrir despesas imprevistas como perda de emprego or problemas de saúde.

Quanto eu devo guardar?
Especialistas recomendam que a reserva cubra de 6 a 12 meses do seu custo de vida mensal. Se você gasta R\$ 2.000 por mês, sua reserva deve ser entre R\$ 12.000 e R\$ 24.000.

Onde colocar esse dinheiro?
Ela deve ter alta liquidez e baixíssimo risco:
- Tesouro Selic: O título mais seguro do Brasil.
- CDBs 100% CDI: De bancos grandes com liquidez imediata.
- Contas Digitais: Que rendam 100% do CDI desde o primeiro dia.

Lembre-se: O objetivo da reserva não é ficar rico, mas sim ter paz de espírito para investir em coisas que rendem mais depois.''',
        author: 'Carlos Mendes',
        readingTime: '4 min',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        imageUrl: 'https://images.unsplash.com/photo-1567427017947-545c5f8d16ad?q=80&w=2000&auto=format&fit=crop',
      ),
      ArticleModel(
        id: '4',
        title: 'Primeiros Passos em Ações',
        content:
            '''Comprar uma ação significa tornar-se sócio de uma empresa real (como Vale, Petrobras ou Itaú). Você passa a participar dos lucros e do crescimento da companhia.

Como começar de verdade?
Para investir, você precisa de uma conta em uma corretora de valores. Através do Home Broker, você envia ordens de compra e venda.

O que analisar?
1. Lucratividade: A empresa ganha dinheiro de verdade?
2. Dívida: Ela deve muito para os bancos?
3. Dividendos: Ela divide o lucro com os sócios?

Não tente ficar rico da noite para o dia. A bolsa de valores premia a paciência e a disciplina de investir todos os meses.''',
        author: 'Daniela Souza',
        readingTime: '8 min',
        publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
        imageUrl: 'https://images.unsplash.com/photo-1611974714851-eb6053e6c3e1?q=80&w=2070&auto=format&fit=crop',
      ),
      ArticleModel(
        id: '5',
        title: 'O Poder dos Dividendos',
        content:
            '''Dividendos são parte do lucro das empresas distribuídos aos seus acionistas em dinheiro vivo. É a base da renda passiva.

O Efeito Bola de Neve
Ao receber dividendos e reinvesti-los comprando mais ações, você cria um ciclo virtuoso. Mais ações geram mais dividendos, que compram ainda mais ações.

Dividend Yield (DY)
Este indicador mostra quanto a empresa pagou em dividendos no último ano em relação ao preço da ação. Um DY de 8% ao ano é considerado muito bom no mercado brasileiro.

Procure por "Vacas Leiteiras": empresas estáveis em setores perenes como energia elétrica e saneamento.''',
        author: 'Ana Silva',
        readingTime: '6 min',
        publishedAt: DateTime.now().subtract(const Duration(days: 3)),
        imageUrl: 'https://images.unsplash.com/photo-1553729459-efe14ef6055d?q=80&w=2070&auto=format&fit=crop',
      ),
      ArticleModel(
        id: '6',
        title: 'Inflação e seu Dinheiro',
        content:
            '''A inflação (IPCA) é o aumento generalizado dos preços. Ela é o "imposto invisível" que corrói o seu poder de compra.

Como ela te afeta?
Se você deixar R\$ 100,00 embaixo do colchão, daqui a um ano esses mesmos R\$ 100,00 comprarão menos coisas no supermercado devido ao aumento dos preços.

Como se proteger?
- Títulos IPCA+: Garantem que você ganhe da inflação + uma taxa fixa.
- Ações e FIIs: Empresas e imóveis tendem a reajustar seus preços e aluguéis pela inflação.

Investir não é apenas para ganhar mais, é para não ficar mais pobre com o tempo.''',
        author: 'Bruno Rocha',
        readingTime: '5 min',
        publishedAt: DateTime.now().subtract(const Duration(days: 10)),
        imageUrl: 'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?q=80&w=2070&auto=format&fit=crop',
      ),
    ];
  }

  @override
  Future<List<Course>> getCourses() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const CourseModel(
        id: 'c1',
        title: 'Bolsa de Valores para Iniciantes',
        videoUrl: null,
      ),
      const CourseModel(
        id: 'c2',
        title: 'Planejamento Financeiro 101',
        videoUrl: null,
      ),
      const CourseModel(
        id: 'c3',
        title: 'Criptoativos: O Guia Básico',
        videoUrl: null,
      ),
    ];
  }
}
