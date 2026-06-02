import 'package:injectable/injectable.dart';

abstract class NewsRemoteDataSource {
  Future<List<Map<String, dynamic>>> getNews();
}

@LazySingleton(as: NewsRemoteDataSource)
class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  @override
  Future<List<Map<String, dynamic>>> getNews() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'id': '1',
        'title': 'Ibovespa sobe mais de 1% e dólar cai mesmo com EUA ameaçando novas tarifas',
        'content': 'O mercado acionário brasileiro demonstrou força na sessão de hoje, com o índice Ibovespa registrando alta superior a 1%. O movimento positivo ocorreu em um cenário de otimismo interno com dados fiscais e corporativos, que conseguiram blindar o índice das incertezas vindas do exterior.\n\nParalelamente, o dólar apresentou queda em relação ao Real. A desvalorização da moeda americana surpreendeu alguns analistas, dado que o governo dos Estados Unidos emitiu novos alertas sobre a imposição de tarifas comerciais, o que geralmente gera aversão ao risco e busca por moedas fortes.\n\nEspecialistas apontam que a entrada de fluxo de capital estrangeiro para mercados emergentes e o bom desempenho das empresas de commodities na B3 foram os principais pilares para esse fechamento. A resiliência do mercado doméstico sinaliza uma confiança temporária dos investidores nas políticas econômicas locais.',
        'source': 'InfoMoney',
        'date': '02/06/2026',
        'tag': 'MERCADOS',
        'category': 'stocks',
      },
      {
        'id': '2',
        'title': 'CSN, Usiminas, Gerdau: siderúrgicas sobem até 9% após tarifa menor sobre aço nos EUA',
        'content': 'As ações das grandes siderúrgicas brasileiras, como CSN, Usiminas e Gerdau, dispararam no pregão de hoje, acumulando ganhos que chegaram a 9%. O otimismo foi alimentado pela notícia de que o governo dos Estados Unidos decidiu aplicar tarifas menores sobre a importação de aço brasileiro.\n\nEssa mudança na política tarifária americana é vista como uma vitória para o setor industrial do Brasil, permitindo que as empresas nacionais recuperem margens de lucro e aumentem o volume de exportações para um de seus principais mercados consumidores. A redução das barreiras comerciais facilita a competitividade do produto brasileiro no exterior.\n\nAnalistas de mercado revisaram suas recomendações para o setor, prevendo resultados trimestrais mais robustos para essas companhias. O fluxo de compra foi intenso durante todo o dia, refletindo a visão de que o setor siderúrgico pode ser um dos grandes beneficiários da reconfiguração das rotas comerciais globais em 2026.',
        'source': 'InfoMoney',
        'date': '02/06/2026',
        'tag': 'AÇÕES',
        'category': 'stocks',
      },
      {
        'id': '3',
        'title': 'Wall Street tem leve alta, com otimismo sobre IA superando cautela com Oriente Médio',
        'content': 'As bolsas em Nova York fecharam em leve alta nesta terça-feira, impulsionadas pelo setor de tecnologia. O entusiasmo contínuo em torno dos avanços da Inteligência Artificial (IA) e seu impacto nos balanços das Big Techs foi o principal motor de valorização dos índices Nasdaq e S&P 500.\n\nApesar do desempenho positivo, o dia foi marcado por uma volatilidade latente devido às tensões geopolíticas no Oriente Médio. Investidores monitoram de perto os desdobramentos diplomáticos e militares na região, temendo impactos nos preços do petróleo e na cadeia de suprimentos global.\n\nContudo, o mercado financeiro parece priorizar o potencial de crescimento a longo prazo oferecido pela revolução tecnológica. Enquanto houver entregas de resultados sólidos por parte das empresas de semicondutores e software, a tendência de alta baseada em inovação deve persistir sobre os riscos macroeconômicos.',
        'source': 'InfoMoney',
        'date': '02/06/2026',
        'tag': 'INTERNACIONAL',
        'category': 'tech',
      },
      {
        'id': '4',
        'title': 'PicPay tem lucro de R\$ 169 mi no 1º tri e prevê valor de R\$ 245 mi no 2º tri',
        'content': 'O PicPay reportou um lucro líquido de R\$ 169 milhões no primeiro trimestre de 2026, consolidando sua trajetória de rentabilidade. O resultado é fruto da maturação do seu ecossistema digital, que agora abrange desde serviços bancários tradicionais até seguros e investimentos.\n\nPara o segundo trimestre, a companhia projeta um crescimento ainda mais agressivo, estimando um lucro de R\$ 245 milhões. Essa confiança baseia-se na expansão da sua base de usuários ativos e no aumento do engajamento com produtos de crédito, que possuem margens mais elevadas.\n\nO desempenho do PicPay reflete a tendência de consolidação das fintechs no Brasil. Ao conseguir converter uma base massiva de usuários em clientes rentáveis de serviços financeiros completos, a empresa se posiciona como um competidor de peso frente aos bancos tradicionais.',
        'source': 'InfoMoney',
        'date': '02/06/2026',
        'tag': 'MERCADOS',
        'category': 'economy',
      },
      {
        'id': '5',
        'title': 'Febraban reage a críticas dos EUA e defende PIX como sistema aberto e competitivo',
        'content': 'A Federação Brasileira de Bancos (Febraban) emitiu um comunicado oficial defendendo o sistema PIX após críticas recentes vindas de autoridades financeiras dos Estados Unidos. A entidade brasileira reforçou que o PIX é um exemplo global de eficiência e inclusão financeira.\n\nA resposta da Febraban rebate alegações de que o sistema brasileiro poderia criar barreiras para novos entrantes ou ser menos transparente que modelos adotados em outras economias. Segundo a federação, o PIX estimula a competição ao permitir pagamentos instantâneos com custos drasticamente reduzidos.\n\nO debate ganha relevância em um momento em que vários países tentam implementar seus próprios sistemas de pagamento em tempo real. O sucesso do Banco Central do Brasil com o PIX é visto como um desafio à dominância das bandeiras de cartão internacionais, gerando fricções diplomáticas e econômicas.',
        'source': 'InfoMoney',
        'date': '02/06/2026',
        'tag': 'ECONOMIA',
        'category': 'economy',
      },
      {
        'id': '6',
        'title': 'Copa do Mundo pode tirar até US\$ 17 bi em produtividade das empresas, diz estudo',
        'content': 'Um novo estudo econômico aponta que a realização da próxima Copa do Mundo poderá acarretar uma perda de produtividade global estimada em US\$ 17 bilhões. O relatório analisa como as alterações de horários e a distração da força de trabalho impactam diretamente o PIB de diversas nações.\n\nO setor industrial e de serviços básicos são os que devem sentir o maior peso, devido à dificuldade de pausar operações durante os jogos das seleções nacionais. Em contrapartida, setores como turismo, varejo de alimentos e apostas esportivas devem registrar picos de faturamento, compensando parcialmente a queda geral.\n\nEconomistas sugerem que as empresas adotem modelos de trabalho flexíveis para mitigar esses danos. A integração do evento à cultura corporativa pode ajudar a manter o moral dos funcionários elevado, transformando o período em uma oportunidade de branding interno, apesar da queda momentânea nos números de produtividade.',
        'source': 'InfoMoney',
        'date': '02/06/2026',
        'tag': 'ECONOMIA',
        'category': 'economy',
      },
      {
        'id': '7',
        'title': 'Labotrat, marca que viralizou nas redes, mira R\$ 1 bilhão até 2030 com e-commerce',
        'content': 'A marca de cosméticos Labotrat anunciou uma ambiciosa meta de faturamento de R\$ 1 bilhão até o ano de 2030. O crescimento da empresa é impulsionado por uma forte estratégia de tecnologia e marketing digital, após ganhar enorme visibilidade em redes sociais de vídeos curtos.\n\nA estratégia central da companhia foca na expansão do seu canal de vendas direta ao consumidor através do e-commerce. Ao investir em logística de última geração e análise de dados (Big Data), a Labotrat consegue prever tendências e ajustar seus estoques com uma precisão muito superior à do varejo físico tradicional.\n\nO sucesso da Labotrat exemplifica o novo modelo de negócios "Digital First", onde o engajamento tecnológico é o principal diferencial competitivo. A empresa pretende usar parte do capital para desenvolver novos produtos baseados em inteligência artificial para personalização de cuidados com a pele.',
        'source': 'InfoMoney',
        'date': '02/06/2026',
        'tag': 'NEGÓCIOS',
        'category': 'tech',
      },
      {
        'id': '8',
        'title': 'Assembleia da Venezuela dá aval inicial a investimento privado no setor elétrico',
        'content': 'A Assembleia Nacional da Venezuela aprovou preliminarmente um projeto de lei que autoriza a entrada de capital privado no setor elétrico do país. Esta decisão marca uma mudança significativa na política econômica do país, que tradicionalmente mantinha controle estatal rigoroso sobre serviços essenciais.\n\nA abertura econômica visa atrair investidores estrangeiros para modernizar a infraestrutura energética, que sofre com anos de falta de manutenção e apagões frequentes. A expectativa é que, com capital privado, seja possível estabilizar a rede elétrica e impulsionar outros setores industriais dependentes de energia.\n\nAnalistas internacionais observam o movimento com cautela, citando os riscos jurídicos e políticos que ainda persistem na região. No entanto, se consolidada, essa medida pode representar um dos primeiros passos para uma reforma econômica mais ampla no mercado venezuelano.',
        'source': 'InfoMoney',
        'date': '02/06/2026',
        'tag': 'MUNDO',
        'category': 'economy',
      },
    ];
  }
}
