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
        title: 'Guia XP: Como começar a investir em ações do zero',
        content:
            '''Investir em ações significa tornar-se sócio de grandes empresas brasileiras ou estrangeiras. Na XP, acreditamos que a educação é o primeiro passo para o sucesso financeiro. O mercado de capitais é uma das ferramentas mais poderosas de geração de riqueza no longo prazo, mas exige disciplina, paciência e conhecimento técnico.

Como funciona a Bolsa de Valores?
A B3 (Brasil, Bolsa, Balcão) é onde as negociações acontecem. Quando você compra uma ação, está adquirindo uma fração do capital social de uma companhia. Se a empresa cresce e lucra, o valor da sua ação tende a subir e você pode receber uma parte desses lucros, chamados de dividendos. A bolsa funciona como um grande mercado onde compradores e vendedores se encontram digitalmente para negociar ativos sob regras rígidas de transparência.

Tipos de Ações e Códigos:
Existem dois tipos principais de ações que você encontrará no seu Home Broker:
- Ações Ordinárias (ON): Terminam com o número 3 (ex: PETR3). Dão direito a voto nas assembleias da empresa e possuem o chamado Tag Along, que protege o acionista minoritário caso a empresa seja vendida.
- Ações Preferenciais (PN): Terminam com o número 4 (ex: ITUB4). Não dão direito a voto, mas têm prioridade no recebimento de dividendos e reembolsos de capital.
- Units: São pacotes que combinam ações ordinárias e preferenciais, terminando com o número 11 (ex: SANB11). São comuns em empresas que buscam maior liquidez para seus papéis.

Análise Fundamentalista vs. Técnica:
Para escolher onde investir, os profissionais utilizam dois métodos principais:
1. Análise Fundamentalista: Foca na saúde financeira da empresa. Analisa-se o balanço patrimonial, o fluxo de caixa, a governança corporativa, o cenário macroeconômico e as perspectivas do setor. É a abordagem preferida para quem investe com foco no longo prazo (Buy and Hold).
2. Análise Técnica (Gráfica): Estuda o comportamento dos preços e volumes negociados no passado para tentar prever movimentos futuros através de gráficos. É muito utilizada por traders que buscam lucros rápidos em operações de curto prazo (Day Trade).

Psicologia do Investidor e Vieses Cognitivos:
O maior inimigo do investidor não é o mercado, mas ele mesmo. O medo e a ganância podem levar a decisões desastrosas:
- Aversão à Perda: A dor de perder R\$ 1.000 é muito maior do que o prazer de ganhar os mesmos R\$ 1.000. Isso faz com que investidores segurem ações ruins "esperando voltar ao preço que pagou" enquanto perdem oportunidades melhores.
- FOMO (Fear of Missing Out): O medo de ficar de fora de uma alta faz investidores comprarem no topo, movidos pelo efeito manada.
- Excesso de Confiança: Achar que sabe mais que o mercado e concentrar demais a carteira em poucos ativos.

Entendendo o Índice Ibovespa:
O Ibovespa é o principal indicador de desempenho das ações negociadas na B3. Ele é uma carteira teórica composta pelas ações com maior volume de negociação nos últimos meses. Quando dizemos que "a bolsa subiu", geralmente estamos nos referindo a esse índice. Entender sua composição ajuda a perceber quais setores (como bancos e commodities) têm mais peso na nossa economia.

Governança Corporativa e o Novo Mercado:
Empresas com boa governança tendem a performar melhor. O "Novo Mercado" é o segmento de listagem da B3 com os mais altos padrões de transparência e proteção aos acionistas. Ao escolher empresas nesse nível, você garante que terá acesso a informações claras e que o interesse dos controladores está alinhado com o seu.

Passo a passo detalhado para o investidor:
1. Abra sua conta: O processo é 100% digital. Escolha uma corretora que ofereça taxas competitivas e bons relatórios de análise.
2. Defina seu perfil: Descubra se você é conservador, moderado ou experiente. Isso determinará a porcentagem da sua carteira que será alocada em renda variável.
3. Monte uma estratégia: Você busca renda passiva recorrente (dividendos) ou valorização do patrimônio no futuro? Sua escolha ditará as empresas da sua carteira.
4. Analise os indicadores: Aprenda o que é P/L (Preço/Lucro), ROE (Retorno sobre Patrimônio), Dívida Líquida/EBITDA e Dividend Yield.
5. Operação: Use o Home Broker para enviar suas ordens. Comece com o Mercado Fracionário (códigos com "F" ao final, como PETR4F) se quiser comprar menos de 100 ações.

Tributação e Impostos:
Investir em ações exige atenção ao fisco. No Brasil, vendas de ações até R\$ 20.000 por mês são isentas de Imposto de Renda para ganhos de capital (em operações comuns). Acima disso, a alíquota é de 15% sobre o lucro. Já para Day Trade, a alíquota é de 20% e não há isenção. Os dividendos, atualmente, são isentos de IR para a pessoa física, o que torna a estratégia de renda passiva muito eficiente.

ESG: Sustentabilidade nos Investimentos:
A sigla ESG (Environmental, Social, and Governance) refere-se a critérios ambientais, sociais e de governança que investidores modernos usam para avaliar empresas. Companhias que respeitam o meio ambiente, têm responsabilidade social e ética na gestão tendem a ser mais resilientes a crises e processos judiciais, apresentando melhor desempenho de longo prazo.

Erros comuns que você deve evitar:
- Tentar acertar o fundo do poço: Ninguém sabe quando uma ação vai parar de cair. Foque em bons fundamentos, não em preços baixos.
- Efeito Manada: Comprar porque todo mundo está comprando ou vender porque todos estão em pânico.
- Não ter Reserva de Emergência: Nunca invista na bolsa aquele dinheiro que você pode precisar para uma emergência médica ou perda de emprego. A bolsa é para o capital que pode ficar parado por anos.

Ciclos de Mercado e a Mentalidade de Longo Prazo:
O mercado financeiro vive em ciclos de expansão (Bull Market) e contração (Bear Market). No Bull Market, o otimismo impera e os preços sobem. No Bear Market, o medo domina e os preços caem, muitas vezes de forma irracional. O investidor de sucesso aprende a manter a calma nesses ciclos, aproveitando as quedas para comprar boas empresas com "desconto".

Conclusão:
A renda variável é o caminho mais provável para a independência financeira, mas não há atalhos. Estude, diversifique entre setores (bancos, energia, commodities, saneamento e varejo) e tenha paciência. O tempo é o fator mais importante para que os juros compostos trabalhem a seu favor. Comece hoje, mesmo que seja com pouco, e mantenha a consistência nos aportes mensais. Lembre-se: na Bolsa de Valores, o tempo e a paciência são os seus maiores aliados para ver o seu dinheiro trabalhar para você.''',
        author: 'XP Research',
        readingTime: '6 min',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        imageUrl:
            'https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?q=80&w=2071&auto=format&fit=crop',
      ),
      ArticleModel(
        id: '2',
        title: 'BTG Pactual: O que é Selic e como ela afeta seu bolso',
        content:
            '''A Taxa Selic é a taxa básica de juros da economia no Brasil. Ela é o principal instrumento de política monetária utilizado pelo Banco Central (BC) para controlar a inflação.

Por que a Selic importa para você?
Quando a Selic sobe, os juros cobrados em empréstimos, financiamentos e cartões de crédito ficam mais altos. Por outro lado, as aplicações de Renda Fixa passam a render mais, atraindo investidores que buscam segurança com boa rentabilidade.

Impacto nos Investimentos:
- Tesouro Selic: Rende exatamente a variação da taxa. É o porto seguro do mercado.
- Poupança: Se a Selic estiver acima de 8,5% ao ano, a poupança rende 0,5% ao mês mais a TR. Se estiver abaixo, rende 70% da Selic.
- Crédito Privado (CDB, LCI, LCA): Geralmente atrelados ao CDI, que caminha junto com a Selic.

O Comitê de Política Monetária (Copom) se reúne a cada 45 dias para definir se a taxa sobe, desce ou se mantém estável, influenciando diretamente o seu bolso e as decisões de consumo de toda a população.''',
        author: 'BTG Digital',
        readingTime: '5 min',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        imageUrl:
            'https://images.unsplash.com/photo-1554224155-6726b3ff858f?q=80&w=2022&auto=format&fit=crop',
      ),
      ArticleModel(
        id: '3',
        title: 'Nubank: Reserva de Emergência, o manual definitivo',
        content:
            '''Ter uma reserva de emergência é o primeiro passo para conquistar a sua liberdade financeira. No Nubank, incentivamos nossos clientes a construírem esse colchão de segurança antes de qualquer outro investimento.

O que é exatamente?
É um dinheiro guardado exclusivamente para imprevistos: a geladeira que quebra, uma demissão inesperada ou uma emergência médica.

Qual o valor ideal?
A recomendação geral é somar o valor total das suas contas fixas e variáveis por mês e multiplicar esse número por 6. Se você gasta R\$ 3.000 mensais, sua reserva ideal é de R\$ 18.000. Isso te dá 6 meses de tranquilidade.

Onde guardar?
A regra para a reserva é clara: segurança e liquidez. O dinheiro deve estar disponível para saque imediato.
1. Caixinhas do Nubank (Reserva de Emergência): Rende 100% do CDI e tem liquidez imediata.
2. Tesouro Selic: Considerado o investimento mais seguro do país.
3. CDBs de liquidez diária: Verifique sempre se o resgate pode ser feito a qualquer momento.''',
        author: 'Blog do Nu',
        readingTime: '4 min',
        publishedAt: DateTime.now().subtract(const Duration(days: 3)),
        imageUrl:
            'https://images.unsplash.com/photo-1567427017947-545c5f8d16ad?q=80&w=2000&auto=format&fit=crop',
      ),
      ArticleModel(
        id: '4',
        title: 'InfoMoney: O Guia Completo dos Fundos Imobiliários',
        content:
            '''Os Fundos Imobiliários se tornaram a "menina dos olhos" dos investidores brasileiros que buscam renda mensal sem a burocracia de comprar um imóvel físico.

Como funcionam os FIIs?
Ao investir em um FII, você compra cotas de um fundo que detém imóveis reais (shoppings, prédios de escritórios, galpões logísticos) ou títulos de crédito imobiliário (LCI, CRI). O lucro obtido com os aluguéis ou juros é distribuído mensalmente entre os cotistas.

Vantagens competitivas:
- Dividendos Mensais: A maioria dos fundos paga rendimentos todos os meses na sua conta.
- Isenção de IR: Atualmente, os dividendos de FIIs são isentos de Imposto de Renda para pessoas físicas.
- Baixo custo: Você consegue investir com cerca de R\$ 100,00, diferente de um apartamento que custa centenas de milhares.
- Liquidez: Você pode vender suas cotas na Bolsa de Valores e ter o dinheiro em conta em 2 dias.

Existem diferentes tipos de fundos: Fundos de Tijolo (imóveis físicos), Fundos de Papel (títulos de dívida) e Fundos de Fundos (que investem em outros FIIs).''',
        author: 'InfoMoney',
        readingTime: '8 min',
        publishedAt: DateTime.now().subtract(const Duration(days: 5)),
        imageUrl:
            'https://images.unsplash.com/photo-1560518883-ce09059eeffa?q=80&w=2073&auto=format&fit=crop',
      ),
      ArticleModel(
        id: '5',
        title: 'Valor Econômico: Estratégias de Diversificação Global',
        content:
            '''Investir apenas no Brasil é um erro comum chamado "Home Bias". Ao fazer isso, você expõe 100% do seu patrimônio ao risco de uma única moeda (o Real) e de uma única economia que representa menos de 2% do PIB mundial.

Por que dolarizar parte do patrimônio?
O dólar é a moeda reserva do mundo. Em momentos de crise global ou incerteza política no Brasil, o dólar tende a subir, protegendo quem possui ativos na moeda americana.

Formas de investir no exterior:
- BDRs (Brazilian Depositary Receipts): Recibos de ações de empresas como Apple, Google e Disney negociados na Bolsa brasileira em reais.
- ETFs Internacionais: Fundos que replicam índices como o S&P 500 (as 500 maiores empresas dos EUA).
- Contas em Corretoras Globais: Investir diretamente nos EUA, tendo acesso a milhares de ações e títulos do tesouro americano.

A recomendação de especialistas é manter entre 10% a 30% do patrimônio em ativos globais, dependendo do seu perfil de risco e objetivos de vida.''',
        author: 'Valor Investe',
        readingTime: '7 min',
        publishedAt: DateTime.now().subtract(const Duration(days: 7)),
        imageUrl:
            'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?q=80&w=2070&auto=format&fit=crop',
      ),
      ArticleModel(
        id: '6',
        title: 'B3: Entenda a diferença entre Dividendos e JCP',
        content:
            '''Um dos grandes atrativos de investir em empresas listadas na B3 é o recebimento de proventos. Mas você sabe a diferença entre eles?

Dividendos:
São a distribuição de parte do lucro líquido da empresa. Por lei, as empresas brasileiras devem distribuir no mínimo 25% do seu lucro anual. Para o investidor pessoa física, os dividendos são isentos de Imposto de Renda.

Juros Sobre Capital Próprio (JCP):
É uma forma diferente de distribuir lucro. Para a empresa, o JCP conta como despesa, o que ajuda a pagar menos impostos. Para o investidor, há uma retenção de 15% de Imposto de Renda na fonte. Ou seja, o valor que cai na conta já é o líquido.

Datas Importantes:
- Data Com: É a data limite para ter a ação e ter direito ao recebimento.
- Data Ex: Se comprar a partir deste dia, você não recebe o provento anunciado.
- Data de Pagamento: O dia em que o dinheiro efetivamente entra na sua conta da corretora.''',
        author: 'Portal B3',
        readingTime: '5 min',
        publishedAt: DateTime.now().subtract(const Duration(days: 10)),
        imageUrl:
            'https://images.unsplash.com/photo-1553729459-efe14ef6055d?q=80&w=2070&auto=format&fit=crop',
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
        videoUrl: 'null',
      ),
      const CourseModel(
        id: 'c3',
        title: 'Criptoativos: O Guia Básico',
        videoUrl: 'null',
      ),
    ];
  }
}
