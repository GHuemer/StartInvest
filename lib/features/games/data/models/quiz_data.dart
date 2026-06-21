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
  Quiz(
    id: 'q4',
    title: 'Tesouro Direto em Detalhes',
    description: 'Aprofunde seus conhecimentos sobre os títulos do governo.',
    difficulty: QuizDifficulty.conservative,
    iconPath: 'assets/icons/shield.png',
    questions: [
      QuizQuestion(
        question: 'Qual título do Tesouro é ideal para reserva de emergência?',
        options: [
          'Tesouro IPCA+.',
          'Tesouro Prefixado.',
          'Tesouro Selic.',
          'Tesouro Renda+.',
        ],
        correctAnswerIndex: 2,
      ),
      QuizQuestion(
        question: 'O que acontece se você resgatar um Tesouro Prefixado antes do vencimento?',
        options: [
          'Você sempre recebe exatamente o que investiu.',
          'Pode sofrer marcação a mercado e receber menos (ou mais) que o esperado.',
          'O governo confisca 50% do valor.',
          'Não é possível resgatar antes do vencimento.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'Qual o prazo de liquidação do Tesouro Direto (quando o dinheiro cai na conta)?',
        options: [
          'D+0 (no mesmo dia).',
          'D+1 (um dia útil após a solicitação).',
          'D+5 (cinco dias úteis).',
          'D+30 (um mês depois).',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'O Tesouro IPCA+ protege seu dinheiro contra:',
        options: [
          'A queda da Bolsa de Valores.',
          'A inflação.',
          'A variação do dólar.',
          'A falência de bancos privados.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'Quem é o emissor dos títulos do Tesouro Direto?',
        options: [
          'Banco do Brasil.',
          'B3 (Bolsa de Valores).',
          'Tesouro Nacional (Governo Federal).',
          'Comissão de Valores Mobiliários (CVM).',
        ],
        correctAnswerIndex: 2,
      ),
    ],
  ),
  Quiz(
    id: 'q5',
    title: 'Análise de Ações e Dividendos',
    description: 'Entenda como escolher boas empresas na bolsa.',
    difficulty: QuizDifficulty.moderate,
    iconPath: 'assets/icons/balance.png',
    questions: [
      QuizQuestion(
        question: 'O que representa o indicador P/L em uma ação?',
        options: [
          'Preço dividido pelo Lucro.',
          'Patrimônio Líquido.',
          'Percentual de Liquidez.',
          'Preço do Lote padrão.',
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: 'O que é o "Dividend Yield"?',
        options: [
          'A valorização da ação no último ano.',
          'A relação entre os dividendos pagos e o preço da ação.',
          'O lucro total da empresa no trimestre.',
          'A taxa de corretagem paga na compra.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'Uma empresa "Growth" (Crescimento) geralmente:',
        options: [
          'Paga dividendos altíssimos todos os meses.',
          'Reinveste a maior parte do lucro no próprio negócio.',
          'Está em processo de falência.',
          'Opera apenas no setor de mineração.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'O que é o "Tag Along"?',
        options: [
          'Um tipo de imposto sobre grandes fortunas.',
          'Proteção ao acionista minoritário em caso de venda do controle da empresa.',
          'O apelido dado aos investidores iniciantes.',
          'A taxa de custódia da corretora.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'Qual a diferença entre ações ON e PN?',
        options: [
          'ON dá direito a voto; PN tem preferência no recebimento de dividendos.',
          'ON são para estrangeiros; PN são para brasileiros.',
          'ON são baratas; PN são caras.',
          'Não há diferença alguma.',
        ],
        correctAnswerIndex: 0,
      ),
    ],
  ),
  Quiz(
    id: 'q6',
    title: 'Estratégias Avançadas e Risco',
    description: 'Teste seus limites com conceitos complexos do mercado.',
    difficulty: QuizDifficulty.aggressive,
    iconPath: 'assets/icons/rocket.png',
    questions: [
      QuizQuestion(
        question: 'O que é o "VIX" no mercado financeiro?',
        options: [
          'Um novo tipo de criptomoeda estável.',
          'O índice de volatilidade, também conhecido como "índice do medo".',
          'O código de negociação da Vale na bolsa de Nova York.',
          'Uma técnica de análise técnica baseada em cores.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'Na estratégia de "Short Selling", o investidor ganha dinheiro quando:',
        options: [
          'O preço do ativo sobe rapidamente.',
          'O preço do ativo cai.',
          'O ativo permanece com preço estável por anos.',
          'A empresa paga dividendos extraordinários.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'O que é o "Índice Sharpe"?',
        options: [
          'Um indicador que mede o retorno de um investimento em relação ao seu risco.',
          'A velocidade com que uma ordem é executada.',
          'O preço máximo que uma ação atingiu na história.',
          'A quantidade de seguidores de um influenciador financeiro.',
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: 'O que caracteriza um "Circuit Breaker"?',
        options: [
          'A abertura do mercado após um feriado.',
          'A interrupção temporária das negociações na Bolsa após quedas bruscas.',
          'O momento em que todos os investidores decidem comprar.',
          'Uma falha técnica nos servidores da B3.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'O que é correlação negativa entre dois ativos?',
        options: [
          'Quando ambos os ativos caem juntos.',
          'Quando o movimento de um ativo não tem relação com o outro.',
          'Quando os ativos tendem a se mover em direções opostas.',
          'Quando ambos os ativos sobem na mesma proporção.',
        ],
        correctAnswerIndex: 2,
      ),
    ],
  ),
  Quiz(
    id: 'q7',
    title: 'Poupança vs. Inflação',
    description: 'Entenda por que deixar dinheiro parado pode ser perigoso.',
    difficulty: QuizDifficulty.conservative,
    iconPath: 'assets/icons/shield.png',
    questions: [
      QuizQuestion(
        question: 'O que acontece com o seu dinheiro na poupança se a inflação for maior que o rendimento?',
        options: [
          'O saldo aumenta e o poder de compra também.',
          'O saldo aumenta, mas o poder de compra diminui (perda real).',
          'O banco retira dinheiro da sua conta.',
          'Nada acontece, o dinheiro fica protegido.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'Qual a regra atual de rendimento da poupança quando a Selic está acima de 8,5% ao ano?',
        options: [
          '0,5% ao mês + Taxa Referencial (TR).',
          '70% da taxa Selic + TR.',
          '100% do CDI.',
          '1% ao mês fixo.',
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: 'O Fundo Garantidor de Crédito (FGC) protege a poupança em até qual valor por CPF e instituição?',
        options: [
          'R\$ 50.000,00.',
          'R\$ 100.000,00.',
          'R\$ 250.000,00.',
          'R\$ 1.000.000,00.',
        ],
        correctAnswerIndex: 2,
      ),
      QuizQuestion(
        question: 'Por que a poupança é considerada um investimento de baixa eficiência?',
        options: [
          'Porque o risco de quebra do banco é muito alto.',
          'Porque costuma render menos que outros ativos de baixo risco, como o Tesouro Selic.',
          'Porque só pode ser sacada uma vez por ano.',
          'Porque o governo cobra taxas de manutenção altíssimas.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'O que é o "Aniversário da Poupança"?',
        options: [
          'O dia em que o banco dá um brinde ao investidor.',
          'O dia do mês em que o depósito foi feito e no qual o rendimento é creditado.',
          'O dia em que a conta foi aberta.',
          'O feriado bancário que suspende os rendimentos.',
        ],
        correctAnswerIndex: 1,
      ),
    ],
  ),
  Quiz(
    id: 'q8',
    title: 'Fundos de Investimento',
    description: 'Saiba como funcionam as carteiras geridas por profissionais.',
    difficulty: QuizDifficulty.moderate,
    iconPath: 'assets/icons/balance.png',
    questions: [
      QuizQuestion(
        question: 'O que é a "Taxa de Administração" em um fundo?',
        options: [
          'Um bônus pago quando o fundo bate a meta.',
          'O valor pago pelo investidor para cobrir os custos de gestão e operação do fundo.',
          'A multa paga por sair do fundo antes do prazo.',
          'O imposto cobrado pelo Governo Federal.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'O que caracteriza o "Come-cotas"?',
        options: [
          'Um erro no sistema que apaga os investimentos.',
          'A antecipação semestral do Imposto de Renda em alguns tipos de fundos.',
          'A taxa cobrada pela Bolsa de Valores.',
          'O apelido do gestor do fundo.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'Um fundo de investimento de "Gestão Ativa" busca:',
        options: [
          'Apenas replicar um índice de referência (como o Ibovespa).',
          'Superar o desempenho do seu índice de referência (benchmark).',
          'Manter o dinheiro parado em conta corrente.',
          'Comprar apenas títulos públicos.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'O que significa o prazo de resgate "D+30"?',
        options: [
          'O dinheiro cai na conta no mesmo dia.',
          'O dinheiro cai na conta 30 dias após a solicitação do resgate.',
          'O fundo só aceita novos investidores a cada 30 dias.',
          'O investimento é bloqueado por 30 anos.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'Qual a função do Gestor do fundo?',
        options: [
          'Vender cotas para novos clientes.',
          'Decidir quais ativos comprar ou vender dentro da carteira do fundo.',
          'Garantir que ninguém perca dinheiro.',
          'Cobrar os impostos dos investidores.',
        ],
        correctAnswerIndex: 1,
      ),
    ],
  ),
  Quiz(
    id: 'q9',
    title: 'Criptoativos e Blockchain',
    description: 'Explore a tecnologia por trás das moedas digitais.',
    difficulty: QuizDifficulty.aggressive,
    iconPath: 'assets/icons/rocket.png',
    questions: [
      QuizQuestion(
        question: 'O que é o "Bitcoin"?',
        options: [
          'Uma moeda emitida por um banco central digital.',
          'Uma rede de pagamentos descentralizada e uma moeda digital baseada em criptografia.',
          'Um programa de pontos de fidelidade de sites de compras.',
          'Um tipo de vírus que rouba dados bancários.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'O que é a Blockchain?',
        options: [
          'Uma empresa que controla as transações de Bitcoin.',
          'Um livro de registros digital, imutável e distribuído que armazena transações.',
          'Um cadeado digital para proteger o computador.',
          'A sede física das empresas de criptomoedas.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'O que significa o termo "Halving" no Bitcoin?',
        options: [
          'O momento em que o preço do Bitcoin cai pela metade.',
          'A redução programada pela metade na emissão de novos Bitcoins (recompensa dos mineradores).',
          'A divisão de uma conta em duas.',
          'Quando o governo confisca metade das moedas.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'O que é uma "Stablecoin"?',
        options: [
          'Uma criptomoeda cujo valor é pareado a um ativo estável, como o Dólar.',
          'Uma moeda que nunca muda de preço.',
          'Um tipo de investimento em estábulos e agronegócio.',
          'Uma moeda que só pode ser usada em jogos.',
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: 'Qual o principal risco de armazenar criptomoedas em uma Corretora (Exchange)?',
        options: [
          'A corretora pode cobrar muitas taxas.',
          'Se a corretora for hackeada ou falir, você pode perder o acesso aos seus ativos.',
          'O Bitcoin pode ser apagado se a internet cair.',
          'Não há risco, corretoras são como bancos tradicionais.',
        ],
        correctAnswerIndex: 1,
      ),
    ],
  ),
  Quiz(
    id: 'q10',
    title: 'Perfil de Investidor',
    description: 'Descubra como seu comportamento afeta suas escolhas.',
    difficulty: QuizDifficulty.conservative,
    iconPath: 'assets/icons/shield.png',
    questions: [
      QuizQuestion(
        question: 'O que caracteriza um perfil "Arrojado/Agressivo"?',
        options: [
          'Busca segurança absoluta, mesmo que o rendimento seja negativo.',
          'Prioriza a rentabilidade no longo prazo e aceita oscilações bruscas no patrimônio.',
          'Investe apenas na poupança.',
          'Não aceita perder nem 1 real do valor investido.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'O que é o "Horizonte de Investimento"?',
        options: [
          'O local onde os bancos ficam localizados.',
          'O prazo (curto, médio ou longo) que o investidor planeja manter seu dinheiro aplicado.',
          'A linha do mar vista de um iate comprado com lucros.',
          'Um tipo de fundo de investimento em infraestrutura.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'Por que o perfil de investidor deve ser respeitado?',
        options: [
          'Para evitar que o investidor entre em pânico e venda ativos na baixa por falta de estômago.',
          'Porque é uma lei federal que proíbe mudar de perfil.',
          'Porque os bancos cobram multas se você mudar de ideia.',
          'Não é importante, qualquer um pode investir em qualquer coisa.',
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: 'O que é "Liquidez"?',
        options: [
          'A cor do dinheiro impresso.',
          'A facilidade e rapidez com que um ativo pode ser convertido em dinheiro vivo.',
          'O lucro total de uma operação na Bolsa.',
          'A taxa de juros do cheque especial.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'Qual a principal diferença entre Risco e Volatilidade?',
        options: [
          'Não há diferença, são sinônimos.',
          'Risco é a chance de perda permanente; Volatilidade são as oscilações de preço no caminho.',
          'Volatilidade é pior que o risco.',
          'Risco só existe em ações, volatilidade só em renda fixa.',
        ],
        correctAnswerIndex: 1,
      ),
    ],
  ),
  Quiz(
    id: 'q11',
    title: 'ETFs e Índices Mundiais',
    description: 'Aprenda a investir em mercados globais de forma simples.',
    difficulty: QuizDifficulty.moderate,
    iconPath: 'assets/icons/balance.png',
    questions: [
      QuizQuestion(
        question: 'O que o ETF "IVVB11" replica?',
        options: [
          'O índice das 50 maiores empresas do Brasil.',
          'O índice S&P 500, com as 500 maiores empresas dos EUA.',
          'O preço do Ouro no mercado internacional.',
          'A taxa Selic brasileira.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'Qual a principal vantagem de um ETF de Índice?',
        options: [
          'Custo baixo e diversificação automática em dezenas ou centenas de ativos.',
          'Garantia de que o índice nunca vai cair.',
          'Isenção de Imposto de Renda em qualquer venda.',
          'Receber dividendos diários na conta.',
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: 'O que é o "Benchmark"?',
        options: [
          'Um banco digital novo.',
          'Um índice de referência usado para comparar o desempenho de um investimento.',
          'A taxa de corretagem fixa da B3.',
          'O valor máximo que uma ação pode custar.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'Onde são negociadas as cotas dos ETFs?',
        options: [
          'Apenas no balcão de agências bancárias.',
          'Na Bolsa de Valores (B3), como se fossem ações.',
          'Diretamente no site do Tesouro Nacional.',
          'Em casas de câmbio.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'O que acontece se uma empresa sai do índice que o ETF replica?',
        options: [
          'O ETF é encerrado e todos perdem o dinheiro.',
          'O gestor do ETF vende as ações dessa empresa e compra a que entrar no lugar.',
          'O investidor precisa vender suas cotas manualmente.',
          'Nada acontece, a empresa continua no ETF para sempre.',
        ],
        correctAnswerIndex: 1,
      ),
    ],
  ),
  Quiz(
    id: 'q12',
    title: 'Psicologia Financeira e Erros',
    description: 'Entenda como sua mente pode te sabotar nos investimentos.',
    difficulty: QuizDifficulty.aggressive,
    iconPath: 'assets/icons/rocket.png',
    questions: [
      QuizQuestion(
        question: 'O que é o "Efeito Manada"?',
        options: [
          'Investir apenas em empresas do setor agropecuário.',
          'Seguir o comportamento da maioria dos investidores sem análise própria.',
          'Comprar ativos apenas quando eles estão muito baratos.',
          'Um tipo de seguro contra desastres naturais.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'O que caracteriza o "Viés da Confirmação"?',
        options: [
          'Procurar apenas informações que confirmem o que você já acredita sobre um ativo.',
          'Confirmar todos os dados bancários antes de uma transferência.',
          'Acreditar que o mercado sempre vai subir.',
          'Vender um ativo assim que ele sobe 10%.',
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: 'Na "Aversão à Perda", a dor de perder R\$ 1.000,00 é geralmente:',
        options: [
          'Igual ao prazer de ganhar R\$ 1.000,00.',
          'Menor do que o prazer de ganhar R\$ 1.000,00.',
          'Muito maior do que o prazer de ganhar R\$ 1.000,00.',
          'Inexistente para investidores experientes.',
        ],
        correctAnswerIndex: 2,
      ),
      QuizQuestion(
        question: 'O que é o "Custo de Oportunidade"?',
        options: [
          'O valor pago para entrar em uma corretora.',
          'O benefício que você deixa de ganhar ao escolher uma opção em vez de outra.',
          'O lucro máximo de uma operação de Day Trade.',
          'A taxa de juros cobrada em empréstimos.',
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: 'O que é o "Excesso de Confiança" nos investimentos?',
        options: [
          'Acreditar que você tem mais controle sobre os resultados do mercado do que realmente tem.',
          'Ter certeza que o banco não vai falir.',
          'Investir todo o dinheiro em um único título público.',
          'Não conferir o saldo da conta por meses.',
        ],
        correctAnswerIndex: 0,
      ),
    ],
  ),
];
