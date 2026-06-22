import '../models/market_question_model.dart';

abstract class MarketQuestionsDatasource {
  Future<List<MarketQuestionModel>> getQuestionsByDifficulty(String difficulty);
}

class MarketQuestionsDatasourceImpl implements MarketQuestionsDatasource {
  @override
  Future<List<MarketQuestionModel>> getQuestionsByDifficulty(
    String difficulty,
  ) async {
    // Simulando delay de rede
    await Future.delayed(const Duration(milliseconds: 500));

    final questions = {
      'easy': _getEasyQuestions(),
      'medium': _getMediumQuestions(),
      'hard': _getHardQuestions(),
    };

    return questions[difficulty] ?? _getEasyQuestions();
  }

  List<MarketQuestionModel> _getEasyQuestions() {
    return [
      MarketQuestionModel(
        id: 'easy_1',
        story:
            'A Apple anuncia um novo iPhone com bateria que dura 3 dias. É uma inovação revolucionária.',
        company: 'Apple Inc.',
        correctAnswer: true,
        difficulty: 'easy',
        explanation:
            'Inovações significativas tendem a aumentar a demanda e confiança dos investidores.',
      ),
      MarketQuestionModel(
        id: 'easy_2',
        story:
            'Netflix perde 2 milhões de assinantes em um trimestre. A concorrência está aumentando.',
        company: 'Netflix',
        correctAnswer: false,
        difficulty: 'easy',
        explanation:
            'Perda de usuários geralmente indica problemas de negócio e reduz perspectivas futuras.',
      ),
      MarketQuestionModel(
        id: 'easy_3',
        story:
            'Tesla anuncia lucro recorde no trimestre, superando todas as expectativas do mercado.',
        company: 'Tesla',
        correctAnswer: true,
        difficulty: 'easy',
        explanation:
            'Lucros acima das expectativas são um forte indicador positivo para o preço das ações.',
      ),
      MarketQuestionModel(
        id: 'easy_4',
        story:
            'Meta (Facebook) demite 25% de seus funcionários devido a corte de custos.',
        company: 'Meta Platforms',
        correctAnswer: false,
        difficulty: 'easy',
        explanation:
            'Demissões em massa indicam dificuldades financeiras e afetam negativamente a confiança.',
      ),
      MarketQuestionModel(
        id: 'easy_5',
        story:
            'Microsoft assina contrato de bilhões com governo para fornecer software.',
        company: 'Microsoft',
        correctAnswer: true,
        difficulty: 'easy',
        explanation:
            'Grandes contratos garantem receita futura e expandem o negócio.',
      ),
      MarketQuestionModel(
        id: 'easy_6',
        story:
            'Amazon enfrenta investigação antitruste em múltiplos países europeus.',
        company: 'Amazon',
        correctAnswer: false,
        difficulty: 'easy',
        explanation:
            'Investigações antitruste podem resultar em multas e restrições operacionais.',
      ),
      MarketQuestionModel(
        id: 'easy_7',
        story:
            'Google lança novo sistema de IA que melhora significativamente os resultados de busca.',
        company: 'Alphabet',
        correctAnswer: true,
        difficulty: 'easy',
        explanation:
            'Melhorias tecnológicas mantêm a liderança de mercado e aumentam valor.',
      ),
      MarketQuestionModel(
        id: 'easy_8',
        story:
            'Coca-Cola reduz gastos com marketing e promove demissões voluntárias.',
        company: 'Coca-Cola',
        correctAnswer: false,
        difficulty: 'easy',
        explanation:
            'Redução de gastos pode sinalizar problemas de crescimento futuro.',
      ),
    ];
  }

  List<MarketQuestionModel> _getMediumQuestions() {
    return [
      MarketQuestionModel(
        id: 'medium_1',
        story:
            'JPMorgan eleva taxa de juros esperada, mas mantém posição otimista sobre economia. Analistas debatem impacto em Tech.',
        company: 'JPMorgan Chase',
        correctAnswer: false,
        difficulty: 'medium',
        explanation:
            'Aumento de juros afeta negativamente ações de tech de alta valorização, apesar do otimismo geral.',
      ),
      MarketQuestionModel(
        id: 'medium_2',
        story:
            'Nvidia revela que suas GPUs de IA têm supply limitado para os próximos 2 anos, com demanda em recorde histórico.',
        company: 'NVIDIA',
        correctAnswer: true,
        difficulty: 'medium',
        explanation:
            'Escassez com demanda forte permite preços prêmio e margem maior.',
      ),
      MarketQuestionModel(
        id: 'medium_3',
        story:
            'Banco Central reduz taxa de juros em 0.5%, inesperadamente. Mercado interpreta como sinal de crise.',
        company: 'Bancos',
        correctAnswer: false,
        difficulty: 'medium',
        explanation:
            'Cortes inesperados de juros costumam gerar preocupação sobre saúde econômica.',
      ),
      MarketQuestionModel(
        id: 'medium_4',
        story:
            'Petrobras anuncia descoberta de megajacimento de petróleo, mas enfrenta pressão governamental para não aumentar preços.',
        company: 'Petrobras',
        correctAnswer: false,
        difficulty: 'medium',
        explanation:
            'Embora a descoberta seja positiva, pressão política para conter preços reduz lucratividade.',
      ),
      MarketQuestionModel(
        id: 'medium_5',
        story:
            'McDonald\'s anuncia expansão agressiva na Ásia com investimento de 5 bilhões, mas gasta mais que o esperado.',
        company: 'McDonald\'s',
        correctAnswer: true,
        difficulty: 'medium',
        explanation:
            'Expansão em mercados emergentes oferece crescimento de longo prazo, compensando despesas iniciais.',
      ),
    ];
  }

  List<MarketQuestionModel> _getHardQuestions() {
    return [
      MarketQuestionModel(
        id: 'hard_1',
        story:
            'Um fundo de private equity anuncia que irá deslistar uma companhia de tech de alto crescimento, citando avaliações insustentáveis. A companhia tem margem de EBITDA de 45%.',
        company: 'Tech Company',
        correctAnswer: false,
        difficulty: 'hard',
        explanation:
            'Deslistagem de empresas com altas avaliações geralmente indica preocupação com ciclos de mercado. Mesmo com boa margem, o múltiplo elevado pode se contrair.',
      ),
      MarketQuestionModel(
        id: 'hard_2',
        story:
            'Empresa farmacêutica falha em teste clínico Phase 3, mas tem pipeline robusto com 8 outros medicamentos em desenvolvimento. Ações descem 15%.',
        company: 'Pharma Company',
        correctAnswer: true,
        difficulty: 'hard',
        explanation:
            'Um fracasso isolado com pipeline forte pode ser oportunidade de compra, pois risco é precificado.',
      ),
      MarketQuestionModel(
        id: 'hard_3',
        story:
            'Empresa de renewable energy obtém subsídios governamentais de longo prazo, mas relatórios indicam que tecnologia concorrente é mais eficiente. Valor de mercado duplica.',
        company: 'Renewable Energy Co',
        correctAnswer: false,
        difficulty: 'hard',
        explanation:
            'Subsídios criam bolha artificial. Tecnologia superior concorrente pode fazer subsídios serem revistos.',
      ),
      MarketQuestionModel(
        id: 'hard_4',
        story:
            'Empresa de semicondutores aumenta capex em 50% para novas fábricas, reduzindo lucro de curto prazo, mas analistas projetam ROI de 35% em 3 anos.',
        company: 'Semiconductor Co',
        correctAnswer: true,
        difficulty: 'hard',
        explanation:
            'Alto capex com ROI projetado positivo indica investimento inteligente em crescimento futuro.',
      ),
      MarketQuestionModel(
        id: 'hard_5',
        story:
            'Banco revela que 30% de sua carteira de crédito está em setores economicamente deprimidos, mas mantém ratings AAA. Rating agencies mantêm classificação.',
        company: 'Bank Corp',
        correctAnswer: false,
        difficulty: 'hard',
        explanation:
            'Concentração em setores fracos com ratings mantidos é sinal de risco não precificado adequadamente.',
      ),
    ];
  }
}
