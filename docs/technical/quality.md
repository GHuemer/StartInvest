# Qualidade de Código

## Análise SonarQube (estado inicial)

| Métrica | Resultado | Severidade |
|---|---|---|
| Security | 0 problemas | A |
| Reliability | 6 issues abertas | A (com 6 issues Major) |
| Maintainability | 867 code smells | - |
| **Coverage** | **0.0%** | **Crítico** |
| Duplications | 4.0% em 1.9k linhas | - |

---

## Mudança 1: Cobertura de Testes (Coverage)

**Problema:** 0% de cobertura. As camadas de BLoC, Repositories e navegação central operam sem validação programática.

**Objetivo:** Cobrir as partes mais críticas do sistema para detectar regressões automaticamente.

**Escopo de implementação (prioridade):**

1. `lib/features/auth/presentation/bloc/auth_bloc.dart` — validar transições de estado (Initial → Loading → Authenticated / Error)
2. `lib/features/auth/data/repositories/auth_repository_impl.dart` — lógica de acesso a dados
3. `lib/features/auth/presentation/pages/sign_in_page.dart` — fluxo de login
4. `lib/features/auth/presentation/widgets/social_sign_in_button.dart` — callback do botão
5. `lib/core/router/app_router.dart` — rotas nomeadas levam às páginas corretas
6. `lib/core/widgets/app_shell.dart` — BottomNavigationBar persiste entre trocas de tela
7. `lib/main.dart` — inicialização de dependências e service locators
8. Pages principais: smoke tests (garantir que as telas carregam sem crash)

**Riscos:**
- Testes de BLoC que dependem de Firebase exigem mocks; implementação incorreta gera falsos positivos
- Widgets com animações assíncronas podem ser não-determinísticos — usar `pumpAndSettle` com cuidado

**Responsáveis:** Gabriel Huemer e Hugo Rubira
**Prazo estimado:** 4 dias

---

## Mudança 2: Construtores `const` em Widgets Imutáveis (Reliability)

**Problema:** 6 Code Smells de severidade Major. Ausência de `const` em widgets imutáveis impede que o Flutter reutilize instâncias, forçando reconstruções desnecessárias a cada ciclo de renderização.

**Arquivos afetados:**
- `lib/features/missions/presentation/pages/missions_page.dart`
- `lib/features/news/presentation/pages/news_page.dart`

**Implementação:** adicionar `const` antes dos construtores de widgets sem dependências dinâmicas.

**Impacto esperado:**
- Redução no consumo de RAM durante navegação
- Interface mais fluida em telas com muitos elementos estáticos

**Riscos:** Aplicar `const` em widgets com parâmetros variáveis gera erro de compilação — verificar antes de aplicar.

**Responsáveis:** João Baratella e Santiago Martins
**Prazo estimado:** 2 dias (estimativa: ~12 minutos de desenvolvimento)

---

## Plano de Validação

**Para Coverage:**
- Tipos: testes unitários (BLoC, usecases) e de widget (pages, widgets)
- Critério de aceite: crescimento percentual positivo nos módulos de autenticação e core

**Para Reliability:**
- Testes manuais: verificação visual no emulador (Pixel 7) — app ultrapassa splash e renderiza temas corretamente
- Testes automatizados: `flutter analyze` sem warnings; novo scan no SonarQube com zero issues de Reliability
- Critério de aceite: SonarQube sem problemas de Reliability nos arquivos citados

---

## Plano de Mudanças (5 semanas)

| Semana | Tarefa | Responsável | Prazo |
|---|---|---|---|
| 1 | Infraestrutura de testes (BLoC, Repositories, core) | Gabriel + Hugo | 7 dias |
| 1 | Correção de `const` em widgets imutáveis | João + Santiago | 7 dias |
| 2-3 | Reestruturação do design system (cores, tipografia, componentes base) | Gabriel + João | 7-10 dias |
| 4-5 | UX/UI: onboarding, autenticação e Home | Hugo | 5 dias |
| 4-5 | UX/UI: Games, Ranking e Missions | Santiago | 5 dias |
| 4-5 | UX/UI: News, Content e Profile | João + Gabriel | 5 dias |

**Ferramenta de gestão:** Kanban com raias: Backlog → Refinamento → Pronto para dev → Em progresso → Code Review → Testes → Concluído
