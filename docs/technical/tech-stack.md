# Tech Stack

## Plataforma

| Tecnologia | Versão | Motivo da Escolha |
|---|---|---|
| Flutter | >= 3.x | <!-- Ex: Cross-platform (iOS, Android, Web) com um único codebase --> |
| Dart | >= 3.x | <!-- Ex: Linguagem fortemente tipada, obrigatória para Flutter --> |

## Backend / Infraestrutura

| Tecnologia | Uso | Motivo |
|---|---|---|
| Firebase Auth | Autenticação | <!-- Ex: Integração nativa com Flutter, suporte a Google Sign-In --> |
| Cloud Firestore | Banco de dados | <!-- Ex: NoSQL em tempo real, SDK Flutter oficial --> |
| Firebase Storage | Upload de mídia | <!-- --> |
| Firebase Messaging | Notificações push | <!-- --> |

## State Management

| Tecnologia | Uso | Motivo |
|---|---|---|
| flutter_bloc + BLoC | Gerência de estado | <!-- Ex: Separação clara de eventos/estados, testável, padrão consolidado --> |

## Navegação

| Tecnologia | Uso | Motivo |
|---|---|---|
| GoRouter | Roteamento declarativo | <!-- Ex: Suporte a deep links, sintaxe declarativa, recomendado pelo Flutter team --> |

## Injeção de Dependência

| Tecnologia | Uso | Motivo |
|---|---|---|
| GetIt + injectable | DI container | <!-- Ex: Service locator simples, geração de código com injectable reduz boilerplate --> |

## Rede e Armazenamento Local

| Tecnologia | Uso | Motivo |
|---|---|---|
| Dio | HTTP Client | <!-- Ex: Interceptors, suporte a cancelamento, mais recursos que http padrão --> |
| Hive | Cache local | <!-- Ex: Banco NoSQL local rápido, sem dependência nativa --> |
| flutter_secure_storage | Dados sensíveis | <!-- Ex: Armazenamento seguro (Keychain/Keystore) para tokens --> |

## UI / UX

| Tecnologia | Uso |
|---|---|
| fl_chart | Gráficos financeiros |
| Lottie | Animações |
| Shimmer | Loading skeleton |
| cached_network_image | Cache de imagens |

## Qualidade e CI/CD

| Tecnologia | Uso |
|---|---|
| GitHub Actions | CI: build, test, lint |
| SonarCloud | Análise estática de qualidade |
| flutter_test + BlocTest + Mocktail | Testes unitários e de widget |
