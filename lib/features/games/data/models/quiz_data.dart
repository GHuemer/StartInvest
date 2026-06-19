import '../../domain/entities/quiz_question.dart';

final List<Quiz> allQuizzes = [
  Quiz(
    id: 'q1',
    title: 'Renda Fixa Básica',
    description: 'Aprenda os conceitos fundamentais de investimentos seguros.',
    difficulty: QuizDifficulty.conservative,
    iconPath: 'assets/icons/shield.png',
    questions: [
      QuizQuestion(
        question: 'O que é um investimento em renda fixa?',
        options: [
          'Um investimento em que a rentabilidade varia conforme o mercado de ações.',
          'Um investimento que permite uma remuneração previsível, definida no momento da aplicação.',
          'Um tipo de empréstimo entre investidores.',
          'Um investimento sem risco de perda alguma.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'Qual destes é um exemplo de investimento em renda fixa?',
        options: [
          'Ações da Petrobras.',
          'Fundos Imobiliários.',
          'Tesouro Direto.',
          'Criptomoedas.',
        ],
        correctAnswerIndex: 2,
      ),
      QuizQuestion(
        question: 'O que significa CDB?',
        options: [
          'Crédito do Banco Digital.',
          'Certificado de Depósito Bancário.',
          'Conta de Depósito a Benefício.',
          'Câmara de Débitos Brasileiros.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'Quando um investimento em renda fixa é pós-fixado, o que isso quer dizer?',
        options: [
          'Que o rendimento é definido no futuro e não agora.',
          'Que a rentabilidade depende de um índice, como o CDI ou a Selic.',
          'Que a taxa é fixa e sem juros.',
          'Que o investidor só recebe o valor no fim do contrato.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'Qual é a principal vantagem da renda fixa?',
        options: [
          'Alta volatilidade e ganhos rápidos.',
          'Risco elevado e retorno incerto.',
          'Segurança e previsibilidade nos rendimentos.',
          'Possibilidade de se multiplicar o capital em poucos dias.',
        ],
        correctAnswerIndex: 2,
      ),
    ],
  ),
  Quiz(
    id: 'q2',
    title: 'Fundos Imobiliários (FIIs)',
    description: 'Entenda como funcionam os fundos que investem em imóveis.',
    difficulty: QuizDifficulty.moderate,
    iconPath: 'assets/icons/balance.png',
    questions: [
      QuizQuestion(
        question: 'O que é um Fundo Imobiliário (FII)?',
        options: [
          'Um condomínio de investidores que aplicam recursos no mercado imobiliário.',
          'Uma conta poupança para comprar uma casa própria.',
          'Um empréstimo feito diretamente para uma construtora.',
          'Um tipo de seguro contra incêndio residencial.',
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: 'Como os FIIs costumam distribuir rendimentos aos cotistas?',
        options: [
          'Anualmente, através de bônus.',
          'Mensalmente, através de dividendos (geralmente isentos de IR para pessoa física).',
          'Apenas quando o fundo é encerrado.',
          'Em forma de novas cotas obrigatoriamente.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'O que é a "Vacância" em um fundo imobiliário?',
        options: [
          'O tempo que o gestor tira de férias.',
          'O percentual de imóveis do fundo que não estão alugados.',
          'O valor total em caixa do fundo.',
          'A taxa paga para entrar no fundo.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'O que caracteriza um FII de "Tijolo"?',
        options: [
          'Investe apenas em empresas de construção civil.',
          'Investe em imóveis físicos (shoppings, galpões, escritórios).',
          'Investe apenas em certificados de recebíveis (CRI).',
          'É um fundo que faliu e só sobraram os tijolos.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'Qual o principal risco de investir em FIIs?',
        options: [
          'Risco de o banco central confiscar os imóveis.',
          'Risco de liquidez e variação no preço das cotas na Bolsa.',
          'Nenhum, pois imóveis nunca perdem valor.',
          'Risco de o governo proibir aluguéis.',
        ],
        correctAnswerIndex: 1,
      ),
    ],
  ),
  Quiz(
    id: 'q3',
    title: 'Mercado de Opções e Derivativos',
    description: 'Teste seus conhecimentos sobre instrumentos financeiros de alta volatilidade.',
    difficulty: QuizDifficulty.aggressive,
    iconPath: 'assets/icons/rocket.png',
    questions: [
      QuizQuestion(
        question: 'O que é uma "Call" no mercado de opções?',
        options: [
          'Uma ligação do corretor avisando sobre prejuízos.',
          'Uma opção de compra de um ativo em uma data futura por um preço fixado.',
          'Uma opção de venda de um ativo.',
          'Uma estratégia para zerar a conta bancária.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'O que acontece se uma opção chega ao vencimento "fora do dinheiro" (OTM)?',
        options: [
          'Ela se torna uma ação automaticamente.',
          'Ela perde todo o valor e "vira pó".',
          'O investidor recebe o dinheiro de volta com correção.',
          'Ela é renovada automaticamente para o mês seguinte.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'Qual a principal finalidade do "Hedge"?',
        options: [
          'Maximizar o lucro a qualquer custo.',
          'Proteção contra variações bruscas de preço em um ativo.',
          'Comprar ativos apenas quando estão caros.',
          'Fazer apostas direcionais sem análise.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'O que é a Alavancagem financeira?',
        options: [
          'A técnica de usar recursos de terceiros para aumentar o potencial de retorno (e risco).',
          'O processo de baixar as taxas de corretagem.',
          'Um tipo de investimento em máquinas pesadas.',
          'Apenas a compra de ações à vista.',
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: 'O que é o "Strike Price" em uma opção?',
        options: [
          'O preço de fechamento do mercado no dia.',
          'O preço de exercício fixado para a compra ou venda do ativo objeto.',
          'A taxa de juros do dia do vencimento.',
          'O valor máximo que uma ação pode atingir.',
        ],
        correctAnswerIndex: 1,
      ),
    ],
  ),
];
