# StartInvest

Plataforma gamificada de educação financeira para jovens investidores. Repositório criado para a disciplina SSC0535 - Gerência de Configuração, Manutenção e Evolução de Software (2026).

## Documentação

### Visão Geral
| Documento | Descrição |
|---|---|
| [Project Brief](docs/overview/project-brief.md) | Problema, proposta de valor, público-alvo e funcionalidades |
| [Personas](docs/overview/personas.md) | Perfis de usuário e análise de tarefas |
| [Análise de Concorrentes](docs/overview/competitive-analysis.md) | Fly Invest, O Jogo do Investidor e diferencial do StartInvest |
| [Decisões (ADR)](docs/overview/decisions.md) | Decisões arquiteturais: Flutter, Clean Arch, Firebase, BLoC, branches |

### Técnico
| Documento | Descrição |
|---|---|
| [Tech Stack](docs/technical/tech-stack.md) | Tecnologias utilizadas e justificativas |
| [Arquitetura](docs/technical/architecture.md) | Clean Architecture, fluxo de dados, estrutura de pastas |
| [Qualidade](docs/technical/quality.md) | Análise SonarQube, plano de mudanças e critérios de aceite |

### Features
| Documento | Descrição |
|---|---|
| [Requisitos Funcionais](docs/features/requirements.md) | RF01-RF22: login, home, jogos, vídeo-aulas, ranking, gamificação |

## Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Auth, Firestore, Storage, Messaging)
- **State:** BLoC (flutter_bloc)
- **Navegação:** GoRouter
- **DI:** GetIt + injectable

## Como Rodar

```bash
# Instalar dependências
flutter pub get

# Gerar código (DI, rotas)
dart run build_runner build --delete-conflicting-outputs

# Rodar
flutter run
```

## Qualidade

```bash
# Lint
flutter analyze

# Testes
flutter test

# Formatar
dart format .
```
