## 📌 Pilares do Sistema

* **Desmistificação:** Tradução de conceitos complexos da economia e do mercado de ações para uma linguagem simples e direta.
* **Gamificação:** Engajamento contínuo por meio de missões diárias, rankings entre usuários e recompensas simbólicas.
* **Prática Segura:** Simulador de investimentos utilizando dados reais de mercado, permitindo que o usuário aprenda a investir na prática sem arriscar capital real.

---

## 🛠️ Tecnologias e Ferramentas

* **Framework:** [Flutter](https://flutter.dev/) & [Dart](https://dart.dev/)
* **Gerenciamento de Estado:** [Bloc Pattern](https://pub.dev/packages/flutter_bloc) (Desacoplamento de UI e lógica de negócio)
* **Injeção de Dependências:** [Get_It](https://pub.dev/packages/get_it) + [Injectable](https://pub.dev/packages/injectable)
* **Navegação:** [Go_Router](https://pub.dev/packages/go_router) (Roteamento centralizado e declarativo)
* **Backend & Persistência:** [Firebase](https://firebase.google.com/) (Autenticação, Firestore e Realtime data)
* **Análise de Qualidade:** [SonarCloud / SonarQube](https://sonarcloud.io/)

---

## 📂 Estrutura de Pastas (Arquitetura)

O projeto adota uma abordagem de **Feature-Driven Clean Architecture**, onde o código é modularizado por funcionalidades de negócio, facilitando a escalabilidade, manutenção isolada e testes.

```text
lib/
├── core/                        # Compartilhado por todas as features
│   ├── di/                      # Injeção de dependências (get_it + injectable)
│   ├── error/                   # Classes de falha (Failure)
│   ├── router/                  # Navegação central (go_router)
│   ├── theme/                   # Cores, tipografia e tema visual
│   └── widgets/                 # Widgets reutilizáveis (TopBar, Cards…)
│
└── features/                    # Cada funcionalidade isolada
    ├── auth/                    # Fluxos de Autenticação e Cadastro
    ├── home/                    # Dashboard e tela inicial do usuário
    ├── content/                 # Portal de ensino (cursos, trilhas e artigos)
    ├── games/                   # Simulador de investimentos e jogos educativos
    ├── ranking/                 # Ranking global e ligas de usuários
    ├── missions/                # Sistema de missões e desafios diários
    ├── news/                    # Agregador de notícias do mercado financeiro
    └── profile/                 # Configurações do perfil do usuário
