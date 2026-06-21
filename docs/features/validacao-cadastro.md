# Validações da Tela de Cadastro

Documentação oficial das regras de validação dos campos do formulário de criação de conta no StartInvest.

---

## Campos do Formulário

### 1. Nome de Usuário (`username`)

Identificador único usado para adicionar amigos na plataforma.

**Regras:**
- Apenas letras (`a-z`, `A-Z`), números (`0-9`), pontos (`.`) e underlines (`_`)
- Mínimo de 3 caracteres
- Não diferencia maiúsculas de minúsculas (salvo em minúsculo internamente)
- Deve ser único — verificado em tempo real no banco de dados

| Exemplo | Válido? | Motivo |
|---|---|---|
| `joao_invest` | ✅ | Letras e underscore |
| `Julia.2024` | ✅ | Letras, ponto e número |
| `jo` | ❌ | Menos de 3 caracteres |
| `joao invest` | ❌ | Espaço não permitido |
| `j@ao` | ❌ | Caractere `@` não permitido |
| `joao_invest` *(já cadastrado)* | ❌ | Nome de usuário já em uso |

---

### 2. Apelido (`name`)

Nome de exibição no perfil e no ranking.

**Regras:**
- Qualquer caractere
- Pelo menos 1 caractere (não pode ser vazio)

| Exemplo | Válido? |
|---|---|
| `João` | ✅ |
| `J` | ✅ |
| `Zé das Couves 🎯` | ✅ |
| *(vazio)* | ❌ |

---

### 3. Data de Nascimento (`birthDate`)

Usada para validar a senha (que não pode conter o ano de nascimento).

**Regras:**
- Selecionada via calendário (`DatePicker`)
- Deve estar no intervalo dos últimos 120 anos: **01/01/1906 → hoje**
- Obrigatória

| Exemplo | Válido? | Motivo |
|---|---|---|
| `15/06/1990` | ✅ | Dentro do intervalo |
| `01/01/1906` | ✅ | Limite inferior |
| Hoje | ✅ | Limite superior |
| `31/12/1905` | ❌ | Anterior a 1906 (bloqueado pelo seletor) |
| Não selecionada | ❌ | Campo obrigatório |

---

### 4. Email (`email`)

**Regras:**
- Formato: `letras/números @ domínio . extensão`
- Extensões aceitas: `.br`, `.com`, `.net`, `.org`

| Exemplo | Válido? | Motivo |
|---|---|---|
| `jul@usp.br` | ✅ | Formato correto, TLD `.br` |
| `teste@gmail.com` | ✅ | TLD `.com` |
| `user@dominio.net` | ✅ | TLD `.net` |
| `maria@empresa.org` | ✅ | TLD `.org` |
| `teste@gmail.io` | ❌ | TLD `.io` não suportado |
| `testegmail.com` | ❌ | Sem `@` |
| `@gmail.com` | ❌ | Sem parte local |
| `teste@gmail` | ❌ | Sem TLD |
| `teste@gmail.edu` | ❌ | TLD `.edu` não suportado |
| *(vazio)* | ❌ | Campo obrigatório |

---

### 5. Senha (`password`)

#### 5.1 Critérios de Validade

Para ser aceita, a senha **deve**:

| Critério | Detalhe |
|---|---|
| Comprimento | Entre **6 e 20** caracteres |
| Caractere especial | Pelo menos **1** dos seguintes: `@`, `#`, `%`, `&`, `!`, `+` |
| Número | Pelo menos **1** dígito (`0-9`) |
| Letra | Pelo menos **1** letra (`a-z` ou `A-Z`) |
| Sem nome | **Não** pode conter o apelido do usuário (sem diferenciar maiúsculas) |
| Sem ano | **Não** pode conter o ano de nascimento do usuário |

Se qualquer critério falhar → mensagem `"Senha inválida."`

#### 5.2 Exemplos de Senhas Inválidas

| Senha | Motivo |
|---|---|
| `abc123` | Sem caractere especial |
| `abc#@%` | Sem número |
| `123#@%!` | Sem letra |
| `Ab#1` | Menos de 6 caracteres |
| `Ab#1234567890123456789` | Mais de 20 caracteres |
| `Amanda@1` *(apelido = Amanda)* | Contém o nome do usuário |
| `#Julian1991` *(ano = 1991)* | Contém o ano de nascimento |

#### 5.3 Níveis de Força

Quando a senha é válida, ela recebe um nível de força exibido visualmente:

| Nível | Cor | Critério |
|---|---|---|
| **Fraca** | 🔴 Vermelho | Comprimento **< 8** caracteres (mas ≥ 6), com ≥ 1 especial e ≥ 1 número |
| **Moderada** | 🟡 Amarelo | Comprimento **> 8** caracteres, com ≥ 1 especial, ≥ 1 número e ≥ 1 letra maiúscula |
| **Forte** | 🟢 Verde | Comprimento **> 12** caracteres, com **> 1** especial, **> 1** número e **> 1** letra maiúscula |

> **Atenção:** Uma senha "fraca" ainda é aceita no cadastro. O nível é apenas informativo.

#### 5.4 Exemplos por Nível de Força

| Senha | Nível | Motivo |
|---|---|---|
| `Ab#172` | 🔴 Fraca | 6 chars, válida mas < 8 |
| `#@49No74` | 🔴 Fraca | 8 chars (não é **>** 8, é igual) |
| `#@49No741` | 🟡 Moderada | 9 chars, tem maiúscula (`N`) |
| `#@49%No74Xyz` | 🟡 Moderada | 12 chars, não excede 12 |
| `#@49%No74Xyz!` | 🟢 Forte | 13 chars, 4 especiais, 4 números, 2 maiúsculas |

---

## Checklist Visual (na tela)

Durante o preenchimento da senha, o app exibe um checklist em tempo real:

```
○ 6 a 20 caracteres
○ Pelo menos 1 caractere especial (@, #, %, &, !, +)
○ Pelo menos 1 número
○ Pelo menos 1 letra (a-z, A-Z)
○ Não contém seu nome ou ano de nascimento   ← só aparece se apelido/data preenchidos
```

Cada item vira **✓ verde** conforme o usuário digita.

---

## Resultado do Cadastro

| Situação | Resultado |
|---|---|
| Todos os campos válidos e usuário criado com sucesso | Navega para a tela inicial |
| Algum campo inválido | Erros exibidos abaixo de cada campo; envio bloqueado |
| Nome de usuário já cadastrado | Mensagem de erro no topo da tela |
| E-mail já cadastrado | Mensagem de erro no topo da tela |
