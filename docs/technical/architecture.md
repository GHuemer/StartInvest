# Arquitetura

## Padrão: Clean Architecture por Feature

O projeto segue Clean Architecture organizada por features. Cada feature é independente e contém até três camadas.

```
lib/
├── core/                   # Infraestrutura compartilhada (não é uma feature)
│   ├── di/                 # Injeção de dependência (GetIt + injectable)
│   ├── error/              # Tipos de falha (Failures)
│   ├── router/             # Navegação (GoRouter)
│   ├── theme/              # Design system (cores, tipografia)
│   └── widgets/            # Widgets globais reutilizáveis
│
└── features/
    └── <feature>/
        ├── domain/         # Regras de negócio puras (sem Flutter, sem Firebase)
        │   ├── entities/   # Modelos de dados
        │   ├── repositories/ # Contratos (interfaces)
        │   └── usecases/   # Casos de uso (uma ação por arquivo)
        ├── data/           # Implementação dos contratos
        │   └── repositories/
        └── presentation/   # UI e estado
            ├── bloc/       # Eventos, estados e BLoC
            ├── pages/      # Telas
            └── widgets/    # Widgets da feature
```

## Fluxo de Dados

```
UI (Page)
  └─► BLoC (Event)
        └─► UseCase
              └─► Repository (interface, domain)
                    └─► RepositoryImpl (data)
                          └─► Firebase / API / Cache
```

## Regras de Dependência

- `domain` não depende de nada externo (nem Flutter, nem Firebase)
- `data` depende de `domain` (implementa os contratos)
- `presentation` depende de `domain` (via usecases), nunca de `data` diretamente
- `core` é acessível por todas as camadas

## Features Atuais

| Feature | Status | Camadas implementadas |
|---|---|---|
| auth | Completa | domain + data + presentation |
| home | Shell | presentation only |
| profile | Shell | presentation only |
| ranking | Shell | presentation only |
| content | Shell | presentation only |
| news | Shell | presentation only |
| missions | Shell | presentation only |
| games | Shell | presentation only |
