# Firestore Schemas

Este documento define a estrutura das coleções no Firebase Firestore para a plataforma StartInvest.

## Coleção: `users`
Armazena os dados de perfil e progresso dos usuários.

- **Document ID**: `{user_uid}` (UID do Firebase Auth)
- **Fields**:
    - `name`: `string`
    - `email`: `string`
    - `photoUrl`: `string` (opcional)
    - `xp`: `number` (padrão: 0)
    - `level`: `number` (padrão: 1)
    - `league`: `string` (bronze, prata, ouro, elite)
    - `subtitle`: `string` (ex: "Investidor Iniciante")
    - `completedCoursesCount`: `number`
    - `balance`: `number` (patrimônio simulado)
    - `assetTypesCount`: `number`
    - `loginStreak`: `number`
    - `completedMissionsIds`: `array<string>` (IDs das missões concluídas)

## Coleção: `news`
Armazena o catálogo de notícias.

- **Document ID**: Auto-gerado
- **Fields**:
    - `title`: `string`
    - `content`: `string`
    - `source`: `string`
    - `date`: `string` (formato: "DD/MM/YYYY")
    - `tag`: `string`
    - `category`: `string` (stocks, crypto, economy, tech)
    - `createdAt`: `timestamp`

## Coleção: `missions`
Catálogo estático de missões disponíveis.

- **Document ID**: `{mission_id}`
- **Fields**:
    - `title`: `string`
    - `description`: `string`
    - `icon`: `string` (nome do ícone mapeado no app)
    - `category`: `string` (learning, practice)
    - `requiredLevel`: `number`
    - `requiredCourses`: `number`
    - `order`: `number` (para ordenação na UI)
