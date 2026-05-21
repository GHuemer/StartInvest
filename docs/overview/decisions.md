# Registro de Decisões (ADR)

---

## ADR-001: Flutter como plataforma principal

**Status:** Aceito

**Contexto**
Necessidade de atender iOS e Android com um único codebase, dado o tamanho reduzido do time (4 pessoas) e o prazo acadêmico.

**Decisão**
Flutter com Dart como plataforma principal.

**Consequências**
- (+) Um codebase para todas as plataformas
- (+) Hot reload acelera o desenvolvimento
- (-) Curva de aprendizado em Dart para membros sem experiência prévia

---

## ADR-002: Clean Architecture por feature

**Status:** Aceito

**Contexto**
Precisávamos de separação de responsabilidades para permitir que cada membro do time desenvolva features independentes sem conflitos.

**Decisão**
Clean Architecture com três camadas por feature: `domain` (regras de negócio puras), `data` (implementação de repositórios), `presentation` (UI + BLoC).

**Consequências**
- (+) Features isoladas e testáveis independentemente
- (+) `domain` em Dart puro: sem dependência de Flutter ou Firebase
- (-) Mais boilerplate por feature nova

---

## ADR-003: Firebase como backend

**Status:** Aceito

**Contexto**
Time sem experiência em backend e sem tempo para configurar e manter servidor próprio no contexto acadêmico.

**Decisão**
Firebase (Auth, Firestore, Storage, Messaging) como backend completo.

**Consequências**
- (+) SDK Flutter oficial, integração direta
- (+) Zero configuração de infraestrutura
- (-) Dependência de vendor (lock-in no Google)

---

## ADR-004: BLoC como gerência de estado

**Status:** Aceito

**Contexto**
Necessidade de separação clara entre UI e lógica de negócio, com suporte a testes de estado.

**Decisão**
`flutter_bloc` com padrão BLoC: UI dispara Events, BLoC processa e emite States.

**Consequências**
- (+) Testável com `bloc_test` + `mocktail`
- (+) Estados explícitos facilitam debug
- (-) Verboso para features simples

---

## ADR-005: Política de branches e commits

**Status:** Aceito

**Contexto**
Time de 4 pessoas trabalhando em paralelo. Necessidade de rastreabilidade e revisão de código.

**Decisão**
- Branch `main` = produção (nunca commitado diretamente)
- Branch `develop` = integração contínua
- Branches temporárias: `feature/<descricao>`, `improvement/<descricao>`, `bugfix/<descricao>`
- Commits atômicos com mensagem descritiva: ex. `[IMPROVEMENT]-Ajuste no alinhamento da tela de login`
- PR obrigatório para `develop`; aprovação de pelo menos 1 membro diferente do autor

**Consequências**
- (+) Rastreabilidade e revisão garantidas por processo
- (+) Nenhuma quebra direta na main
- (-) Overhead de processo para mudanças pequenas
