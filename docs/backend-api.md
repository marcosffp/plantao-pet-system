<img width="1600" style="height:auto; border-radius: 12px;" alt="banner" src="images/banner.png" />

# Backend — Documentação Técnica

> API REST do **Plantão Pet** construída com Node.js + Express, PostgreSQL via Prisma, Apache Kafka (KRaft) e Socket.IO.

---

## Sumário

- [Visão geral](#visão-geral)
- [Arquitetura em camadas](#arquitetura-em-camadas)
- [Modelo de dados](#modelo-de-dados)
- [Autenticação e autorização](#autenticação-e-autorização)
- [Endpoints da API](#endpoints-da-api)
  - [Autenticação](#autenticação-auth)
  - [Donos](#donos-owners)
  - [Pets](#pets-ownerspecialpets-e-petsid)
  - [Cuidadores](#cuidadores-caregivers)
  - [Solicitações de serviço](#solicitações-de-serviço-service-requests)
  - [Avaliações](#avaliações-reviews)
  - [Notificações](#notificações-notifications)
- [Regras de negócio](#regras-de-negócio)
- [Eventos Kafka](#eventos-kafka)
- [Tratamento de erros](#tratamento-de-erros)
- [Infraestrutura Docker](#infraestrutura-docker)
- [Variáveis de ambiente](#variáveis-de-ambiente)
- [Scripts disponíveis](#scripts-disponíveis)
- [Tecnologias e dependências](#tecnologias-e-dependências)

---

## Visão geral

O backend é uma API REST que expõe todos os recursos do sistema — cadastro de usuários, gerenciamento de pets, ciclo de vida de solicitações de serviço, avaliações e notificações. Ele não possui interface visual própria; toda interação ocorre via HTTP (com o app Flutter) e via WebSocket (para eventos em tempo real).

Além de servir a API, o backend também atua como **publicador de eventos Kafka** (toda mudança de estado relevante vira um evento) e como **servidor Socket.IO** (onde esses eventos chegam aos clientes em tempo real após processamento pelo consumer Kafka).

---

## Arquitetura em camadas

O backend segue uma separação clara de responsabilidades. Cada camada tem uma função específica e não deve "pular" camadas:

![Arquitetura do Sistema](images/Arquitetura.jpg)

| Camada | Pasta | Responsabilidade |
|---|---|---|
| Rotas | `routes/` | Monta as URLs, aplica `authenticate`, `requireOwner`/`requireCaregiver` e `validate` |
| Controllers | `controllers/` | Extrai dados do `req`, chama o service e retorna JSON via `res` |
| Services | `services/` | Valida regras de negócio, orquestra repositórios, publica eventos Kafka |
| Repositórios | `repositories/` | Executa queries Prisma — SELECT, INSERT, UPDATE, DELETE |
| Middlewares | `middlewares/` | Autenticação JWT, tratamento global de erros, validação com Zod |
| Schemas | `schemas/` | Definições Zod dos bodies de requisição (campos obrigatórios, limites, formatos) |
| Kafka | `kafka/` | Producer (publica eventos) e Consumer (consome, grava notificação, emite via Socket.IO) |
| Socket | `socket/` | Configura o Socket.IO, autentica conexões, gerencia salas por usuário |
| Jobs | `jobs/` | Cron job que cancela automaticamente solicitações expiradas |
| Utils | `utils/` | `AppError` (erro com status HTTP) e `asyncHandler` (wrapper para erros assíncronos) |

### Estrutura de pastas

```
backend/
├── src/
│   ├── server.js                   ← Inicializa HTTP, Socket.IO e Kafka
│   ├── app.js                      ← Configura Express, rotas e middlewares
│   ├── prisma/
│   │   └── client.js               ← Singleton do Prisma Client
│   ├── routes/
│   │   ├── auth.routes.js
│   │   ├── owners.routes.js
│   │   ├── pets.routes.js          ← Rotas sob /owners/pets
│   │   ├── pets-direct.routes.js   ← Rota GET /pets/:id
│   │   ├── caregivers.routes.js
│   │   ├── service-requests.routes.js
│   │   ├── reviews.routes.js
│   │   └── notifications.routes.js
│   ├── controllers/
│   ├── services/
│   ├── repositories/
│   ├── middlewares/
│   │   ├── auth.middleware.js
│   │   ├── error.middleware.js
│   │   └── validate.middleware.js
│   ├── kafka/
│   │   ├── kafka.client.js
│   │   ├── kafka.producer.js
│   │   └── kafka.consumer.js
│   ├── socket/
│   │   └── socket.js
│   ├── jobs/
│   │   └── expire-requests.job.js
│   ├── schemas/
│   └── utils/
│       ├── AppError.js
│       └── asyncHandler.js
├── prisma/
│   └── schema.prisma               ← Modelos do banco de dados
├── docker-compose.yml
├── Dockerfile
├── .env.example
└── package.json
```

---

## Modelo de dados

O banco de dados é PostgreSQL 15, gerenciado pelo Prisma ORM. O diagrama abaixo representa as entidades e seus relacionamentos.

![Diagrama do Banco de Dados](images/Diagrama_Entidades_Banco_Dados.png)

### Entidade: Owner (Dono do Pet)

Representa o usuário que possui animais e abre solicitações de serviço.

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Identificador único gerado automaticamente |
| `name` | String | Nome completo |
| `email` | String (unique) | E-mail, usado como login — não pode repetir |
| `phone` | String (unique) | Telefone — não pode repetir |
| `address` | String | Endereço principal |
| `passwordHash` | String | Senha hasheada com bcrypt (nunca retornada pela API) |
| `createdAt` | DateTime | Data de criação do registro |

**Relacionamentos:** possui vários `Pet`, várias `ServiceRequest` e vários `Review`.

### Entidade: Pet

Representa um animal de estimação cadastrado por um dono.

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Identificador único |
| `name` | String | Nome do pet (máx. 10 caracteres) |
| `species` | Enum | `DOG`, `CAT` ou `OTHER` |
| `breed` | String | Raça do animal |
| `age` | Int | Idade em anos (0 a 30) |
| `specialNotes` | String? | Observações opcionais (alergias, medicamentos, comportamento) |
| `ownerId` | UUID | FK para o dono — campo obrigatório |
| `createdAt` | DateTime | Data de cadastro |

**Relacionamentos:** pertence a um `Owner`; pode estar em várias `ServiceRequest`.

### Entidade: Caregiver (Cuidador)

Representa o prestador de serviços que aceita e executa os atendimentos.

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Identificador único |
| `name` | String | Nome completo |
| `email` | String (unique) | E-mail de login |
| `phone` | String (unique) | Telefone de contato |
| `passwordHash` | String | Senha hasheada |
| `neighborhoods` | String[] | Lista de bairros onde atende (1 a 5) |
| `services` | ServiceType[] | Tipos de serviço oferecidos (1 a 4 opções) |
| `averageRating` | Float | Média de avaliações recebidas (0 a 5, recalculada a cada avaliação) |
| `status` | Enum | `ACTIVE` (disponível) ou `INACTIVE` (fora de serviço) |
| `createdAt` | DateTime | Data de cadastro |

**Relacionamentos:** possui várias `ServiceRequest` aceitas e vários `Review` recebidos.

### Entidade: ServiceRequest (Solicitação de Serviço)

É o recurso central do sistema. Representa um pedido de atendimento criado pelo dono, que passa por estados até a conclusão.

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Identificador único |
| `petId` | UUID | FK para o pet que será atendido |
| `ownerId` | UUID | FK para o dono que criou a solicitação |
| `caregiverId` | UUID? | FK para o cuidador (preenchido após aceitação) |
| `serviceType` | Enum | Tipo de serviço: `WALK_30MIN`, `WALK_1H`, `HOME_VISIT`, `HOSTING` |
| `scheduledAt` | DateTime | Data e hora agendadas para o atendimento |
| `meetingAddress` | String | Endereço de encontro (5 a 200 caracteres) |
| `status` | Enum | Ciclo de vida: `OPEN` → `ACCEPTED` → `IN_PROGRESS` → `COMPLETED` (ou `CANCELLED` / `REFUSED`) |
| `expiresAt` | DateTime | Prazo de expiração: 24 horas após a criação. Solicitações `OPEN` expiradas são canceladas automaticamente |
| `createdAt` | DateTime | Data de criação |

**Ciclo de vida dos status:**

```mermaid
flowchart TD
    OPEN["OPEN\ncriada pelo dono"]
    ACCEPTED["ACCEPTED"]
    CANCELLED["CANCELLED"]
    IN_PROGRESS["IN_PROGRESS"]
    COMPLETED["COMPLETED\ndono pode avaliar"]

    OPEN -->|"aceitar"| ACCEPTED
    OPEN -->|"cancelar / expirar"| CANCELLED
    ACCEPTED -->|"recusar — volta para OPEN"| OPEN
    ACCEPTED -->|"iniciar"| IN_PROGRESS
    IN_PROGRESS -->|"concluir"| COMPLETED
```

### Entidade: Review (Avaliação)

Criada pelo dono após o serviço ser concluído. Cada solicitação tem no máximo uma avaliação.

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Identificador único |
| `serviceRequestId` | UUID (unique) | FK para a solicitação avaliada |
| `ownerId` | UUID | FK para o dono que avaliou |
| `caregiverId` | UUID | FK para o cuidador avaliado |
| `rating` | Int | Nota de 1 a 5 |
| `comment` | String | Comentário (1 a 500 caracteres) |
| `createdAt` | DateTime | Data da avaliação |

**Efeito colateral:** ao criar uma avaliação, o backend recalcula automaticamente o `averageRating` do cuidador com a média de todas as suas avaliações.

### Entidade: Notification

Registra todas as notificações entregues via Kafka + Socket.IO. Permite que o histórico seja consultado mesmo que o usuário não estivesse conectado no momento do evento.

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | UUID | Identificador único |
| `userId` | String | ID do usuário destinatário |
| `userRole` | String | `owner` ou `caregiver` |
| `eventType` | String | Tipo do evento Kafka que originou a notificação |
| `payload` | JSON | Dados completos do evento |
| `requestId` | String? | ID da solicitação relacionada (para deduplicação) |
| `readAt` | DateTime? | Preenchido quando o usuário marca como lida (`null` = não lida) |
| `createdAt` | DateTime | Data de criação |

### Enums

| Enum | Valores | Contexto |
|---|---|---|
| `Species` | `DOG`, `CAT`, `OTHER` | Espécie do pet |
| `ServiceType` | `WALK_30MIN`, `WALK_1H`, `HOME_VISIT`, `HOSTING` | Tipo de serviço |
| `RequestStatus` | `OPEN`, `ACCEPTED`, `IN_PROGRESS`, `COMPLETED`, `CANCELLED`, `REFUSED` | Status da solicitação |
| `CaregiverStatus` | `ACTIVE`, `INACTIVE` | Disponibilidade do cuidador |

---

## Autenticação e autorização

### Como funciona o JWT

O sistema usa **JSON Web Tokens (JWT)** para autenticação. O fluxo é:

1. O usuário faz login ou se cadastra → o backend gera um token JWT assinado com `JWT_SECRET`
2. O token é enviado ao cliente Flutter, que o armazena com segurança (Keychain no iOS / EncryptedSharedPreferences no Android)
3. Em todas as requisições subsequentes, o cliente envia o token no cabeçalho: `Authorization: Bearer <token>`
4. O middleware `authenticate` valida a assinatura e extrai `{ id, role }` do payload — esses dados ficam disponíveis como `req.user`
5. Middlewares adicionais (`requireOwner` ou `requireCaregiver`) verificam o `role` e bloqueiam acesso indevido

**Validade:** O token expira após o prazo configurado em `JWT_EXPIRES_IN` (padrão: 7 dias). Após a expiração, o usuário precisa fazer login novamente.

### Papéis (roles)

| Role | Quem é | Acesso |
|---|---|---|
| `owner` | Dono do pet | Gerencia seus pets, abre e cancela solicitações, avalia cuidadores |
| `caregiver` | Cuidador | Visualiza solicitações abertas, aceita/recusa/inicia/conclui atendimentos, gerencia seu status |

### Respostas de erro de autenticação

| Código | Situação |
|---|---|
| `401` | Token ausente, inválido ou expirado |
| `403` | Token válido, mas role não autorizado para aquele endpoint |

### Autenticação no Socket.IO

A conexão WebSocket também é autenticada. O token JWT é enviado como parâmetro de query:

```
ws://localhost:3000?token=<jwt>
```

O middleware do Socket.IO valida o token e adiciona o cliente à sala `${role}:${userId}` (exemplo: `owner:abc123`). Todos os eventos são emitidos para salas específicas, garantindo que cada usuário receba apenas suas próprias notificações.

---

## Endpoints da API

A documentação interativa completa está disponível em `http://localhost:3000/api-docs` (Swagger UI) após subir a aplicação.

Convenções usadas nesta seção:
- **Auth** indica qual middleware de autorização é exigido
- Os bodies são JSON (`Content-Type: application/json`)
- Respostas de sucesso sempre retornam `{ data: ... }`
- Respostas de erro retornam `{ error: "mensagem" }` ou `{ message: "mensagem" }`

---

### Autenticação (`/auth`)

Estes endpoints não exigem token. São o ponto de entrada para novos usuários e para obter o JWT de sessão.

#### `POST /auth/owner/register` — Cadastro de Dono

Cria uma nova conta de dono do pet. Retorna os dados do perfil e um token JWT pronto para uso.

**Body:**
```json
{
  "name": "João Silva",
  "email": "joao@email.com",
  "phone": "31999990000",
  "address": "Rua das Flores, 123, Centro, BH",
  "password": "minhasenha123"
}
```

| Campo | Validação |
|---|---|
| `name` | 2 a 100 caracteres |
| `email` | Formato de e-mail válido, único no sistema |
| `phone` | 10 a 15 dígitos, único no sistema |
| `address` | 5 a 200 caracteres |
| `password` | Mínimo 6 caracteres |

**Resposta de sucesso — 201:**
```json
{
  "data": {
    "id": "uuid",
    "name": "João Silva",
    "email": "joao@email.com",
    "phone": "31999990000",
    "address": "Rua das Flores, 123, Centro, BH",
    "createdAt": "2026-06-19T10:00:00.000Z",
    "token": "<jwt>"
  }
}
```

**Erros possíveis:** `409` se e-mail ou telefone já existirem, `400` se validação falhar.

---

#### `POST /auth/owner/login` — Login de Dono

Autentica o dono e retorna um novo token JWT.

**Body:**
```json
{
  "email": "joao@email.com",
  "password": "minhasenha123"
}
```

**Resposta de sucesso — 200:**
```json
{
  "token": "<jwt>"
}
```

**Erros possíveis:** `401` se credenciais inválidas.

---

#### `POST /auth/caregiver/register` — Cadastro de Cuidador

Cria uma nova conta de cuidador. O cuidador é criado com status `ACTIVE` por padrão.

**Body:**
```json
{
  "name": "Maria Cuidadora",
  "email": "maria@email.com",
  "phone": "31988880000",
  "neighborhoods": ["Centro", "Savassi"],
  "services": ["WALK_30MIN", "WALK_1H", "HOME_VISIT"],
  "password": "senhasegura456"
}
```

| Campo | Validação |
|---|---|
| `name` | 2 a 100 caracteres |
| `email` | Formato de e-mail válido, único no sistema |
| `phone` | 10 a 15 dígitos, único no sistema |
| `neighborhoods` | Array com 1 a 5 bairros |
| `services` | Array com 1 a 4 valores do enum `ServiceType` |
| `password` | Mínimo 6 caracteres |

**Resposta de sucesso — 201:**
```json
{
  "data": {
    "id": "uuid",
    "name": "Maria Cuidadora",
    "email": "maria@email.com",
    "phone": "31988880000",
    "neighborhoods": ["Centro", "Savassi"],
    "services": ["WALK_30MIN", "WALK_1H", "HOME_VISIT"],
    "averageRating": 0,
    "status": "ACTIVE",
    "createdAt": "2026-06-19T10:00:00.000Z",
    "token": "<jwt>"
  }
}
```

**Erros possíveis:** `409` se e-mail ou telefone já existirem, `400` se validação falhar.

---

#### `POST /auth/caregiver/login` — Login de Cuidador

**Body:**
```json
{
  "email": "maria@email.com",
  "password": "senhasegura456"
}
```

**Resposta de sucesso — 200:**
```json
{
  "token": "<jwt>"
}
```

---

### Donos (`/owners`)

#### `GET /owners/me` — Perfil do Dono Autenticado

Retorna os dados do dono logado.

**Auth:** Bearer token + role `owner`

**Resposta de sucesso — 200:**
```json
{
  "data": {
    "id": "uuid",
    "name": "João Silva",
    "email": "joao@email.com",
    "phone": "31999990000",
    "address": "Rua das Flores, 123, Centro, BH",
    "createdAt": "2026-06-19T10:00:00.000Z"
  }
}
```

---

### Pets (`/owners/pets` e `/pets/:id`)

Endpoints para gerenciamento dos pets do dono. Todos os endpoints de escrita verificam se o pet pertence ao dono autenticado.

#### `POST /owners/pets` — Cadastrar Pet

**Auth:** Bearer token + role `owner`

**Body:**
```json
{
  "name": "Rex",
  "species": "DOG",
  "breed": "Golden Retriever",
  "age": 3,
  "specialNotes": "Alérgico a frango"
}
```

| Campo | Validação |
|---|---|
| `name` | 1 a 10 caracteres |
| `species` | `DOG`, `CAT` ou `OTHER` |
| `breed` | Ao menos 1 caractere |
| `age` | Inteiro de 0 a 30 |
| `specialNotes` | Opcional |

**Resposta de sucesso — 201:** `{ "data": { Pet } }`

---

#### `GET /owners/pets` — Listar Pets do Dono

Retorna todos os pets cadastrados pelo dono autenticado.

**Auth:** Bearer token + role `owner`

**Resposta de sucesso — 200:** `{ "data": [Pet, ...] }`

---

#### `PUT /owners/pets/:petId` — Editar Pet

Atualiza os dados de um pet. Todos os campos são opcionais — apenas os enviados são alterados.

**Auth:** Bearer token + role `owner`

**Erros possíveis:** `403` se o pet não pertencer ao dono, `404` se não existir.

---

#### `DELETE /owners/pets/:petId` — Deletar Pet

Remove o pet permanentemente.

**Auth:** Bearer token + role `owner`

**Resposta de sucesso — 204:** Sem corpo.

**Erros possíveis:** `403` se o pet não pertencer ao dono, `404` se não existir.

---

#### `GET /pets/:id` — Buscar Pet por ID

Retorna os dados de um pet específico pelo ID. Não exige role específico, apenas autenticação.

**Auth:** Bearer token

**Resposta de sucesso — 200:** `{ "data": { Pet } }`

**Erros possíveis:** `404` se não existir.

---

### Cuidadores (`/caregivers`)

#### `GET /caregivers` — Listar Cuidadores Ativos

Retorna todos os cuidadores com status `ACTIVE`. Usado pelo dono para visualizar opções disponíveis.

**Auth:** Bearer token

**Resposta de sucesso — 200:**
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Maria Cuidadora",
      "email": "maria@email.com",
      "phone": "31988880000",
      "neighborhoods": ["Centro", "Savassi"],
      "services": ["WALK_30MIN", "WALK_1H"],
      "averageRating": 4.5,
      "status": "ACTIVE",
      "createdAt": "2026-06-19T10:00:00.000Z"
    }
  ]
}
```

---

#### `GET /caregivers/:id` — Perfil de um Cuidador

Retorna o perfil completo de um cuidador específico, incluindo rating e serviços.

**Auth:** Bearer token

**Erros possíveis:** `404` se não existir.

---

#### `GET /caregivers/:id/reviews` — Avaliações do Cuidador

Retorna todas as avaliações recebidas por um cuidador, ordenadas por data.

**Auth:** Bearer token

**Erros possíveis:** `404` se o cuidador não existir.

---

#### `PATCH /caregivers/status` — Atualizar Status do Cuidador

Permite que o cuidador alterne entre `ACTIVE` (disponível para aceitar solicitações) e `INACTIVE` (não aparece nas listagens, não pode aceitar novos atendimentos).

**Auth:** Bearer token + role `caregiver`

**Body:**
```json
{
  "status": "INACTIVE"
}
```

**Resposta de sucesso — 200:**
```json
{
  "data": {
    "id": "uuid",
    "name": "Maria Cuidadora",
    "status": "INACTIVE"
  }
}
```

**Erros possíveis:** `400` se status inválido, `403` se não for cuidador.

---

### Solicitações de Serviço (`/service-requests`)

Este é o grupo de endpoints mais complexo, pois gerencia o ciclo de vida completo de um atendimento.

#### `POST /service-requests` — Criar Solicitação (Dono)

O dono abre um pedido de atendimento para um de seus pets.

**Auth:** Bearer token + role `owner`

**Body:**
```json
{
  "petId": "uuid-do-pet",
  "serviceType": "WALK_30MIN",
  "scheduledAt": "2026-06-20T10:00:00.000Z",
  "meetingAddress": "Rua das Flores, 123, Centro"
}
```

| Campo | Validação |
|---|---|
| `petId` | UUID válido de um pet existente que pertença ao dono |
| `serviceType` | `WALK_30MIN`, `WALK_1H`, `HOME_VISIT` ou `HOSTING` |
| `scheduledAt` | Data/hora ISO 8601; deve ser pelo menos 2 horas no futuro |
| `meetingAddress` | 5 a 200 caracteres |

**Efeitos:** cria a solicitação com status `OPEN` e `expiresAt` = agora + 24h. Publica evento `service_request.created` no Kafka → todos os cuidadores `ACTIVE` recebem notificação em tempo real.

**Erros possíveis:**
- `400` — `scheduledAt` menor que 2 horas no futuro
- `403` — pet não pertence ao dono autenticado
- `404` — pet não encontrado
- `409` — o pet já possui uma solicitação `OPEN` ou `ACCEPTED` ativa

---

#### `GET /service-requests` — Listar Solicitações Abertas (Cuidador)

Retorna todas as solicitações com status `OPEN`, ordenadas da mais recente para a mais antiga. Usado pelo cuidador para visualizar oportunidades de atendimento.

**Auth:** Bearer token + role `caregiver`

---

#### `GET /service-requests/my` — Minhas Solicitações

Retorna as solicitações do usuário autenticado, com comportamento diferente por role:

- **Dono:** retorna todas as solicitações criadas por ele
- **Cuidador:** retorna as solicitações que ele aceitou (vinculadas ao seu ID)

**Auth:** Bearer token (qualquer role)

---

#### `GET /service-requests/:id` — Detalhes de uma Solicitação

Retorna todos os dados de uma solicitação, incluindo informações do pet, dono, cuidador (se atribuído) e avaliação (se existir).

**Auth:** Bearer token

**Erros possíveis:** `404` se não existir.

---

#### `PATCH /service-requests/:id/accept` — Aceitar Solicitação (Cuidador)

O cuidador aceita uma solicitação `OPEN`. A solicitação muda para `ACCEPTED` e o `caregiverId` é preenchido.

**Auth:** Bearer token + role `caregiver`

**Validações:**
- Solicitação deve estar com status `OPEN`
- Cuidador deve estar `ACTIVE`
- Cuidador não pode ter mais de 3 solicitações `IN_PROGRESS` simultâneas

**Efeito:** publica evento `service_request.accepted` → dono recebe notificação em tempo real com nome e telefone do cuidador.

**Erros possíveis:** `403` cuidador inativo ou limite atingido, `404` solicitação não encontrada, `409` status incorreto.

---

#### `PATCH /service-requests/:id/refuse` — Recusar Solicitação (Cuidador)

O cuidador devolve uma solicitação `ACCEPTED` para o status `OPEN`, liberando-a para outros cuidadores aceitarem.

**Auth:** Bearer token + role `caregiver`

**Efeito:** publica evento `service_request.refused` → dono é notificado.

---

#### `PATCH /service-requests/:id/cancel` — Cancelar Solicitação (Dono)

O dono cancela uma solicitação. Só é possível cancelar quando o status é `OPEN`.

**Auth:** Bearer token + role `owner`

**Efeito:** publica evento `service_request.cancelled` → todos os cuidadores `ACTIVE` recebem notificação e a solicitação é removida de suas listas em tempo real.

**Erros possíveis:** `403` se não for o dono da solicitação ou status não for `OPEN`.

---

#### `PATCH /service-requests/:id/start` — Iniciar Serviço (Cuidador)

O cuidador inicia o atendimento. Muda o status de `ACCEPTED` para `IN_PROGRESS`.

**Auth:** Bearer token + role `caregiver`

**Validação:** apenas o cuidador atribuído à solicitação pode iniciar.

**Efeito:** publica evento `service_request.in_progress` → dono recebe notificação.

---

#### `PATCH /service-requests/:id/complete` — Concluir Serviço (Cuidador)

O cuidador marca o serviço como concluído. Muda o status de `IN_PROGRESS` para `COMPLETED`.

**Auth:** Bearer token + role `caregiver`

**Validação:** apenas o cuidador atribuído pode concluir.

**Efeito:** publica evento `service.completed` → dono recebe notificação e o botão de avaliar é habilitado no app.

---

### Avaliações (`/reviews`)

#### `POST /reviews` — Criar Avaliação (Dono)

O dono avalia o cuidador após o serviço ser concluído.

**Auth:** Bearer token + role `owner`

**Body:**
```json
{
  "serviceRequestId": "uuid-da-solicitacao",
  "rating": 5,
  "comment": "Excelente cuidador, muito atencioso com o Rex!"
}
```

| Campo | Validação |
|---|---|
| `serviceRequestId` | UUID de uma solicitação existente |
| `rating` | Inteiro de 1 a 5 |
| `comment` | 1 a 500 caracteres |

**Validações de negócio:**
- A solicitação deve existir e estar com status `COMPLETED`
- O dono da avaliação deve ser o dono da solicitação
- Cada solicitação pode ter no máximo uma avaliação

**Efeitos:** recalcula o `averageRating` do cuidador (média de todas as suas avaliações). Publica evento `review.created` → cuidador recebe notificação.

**Erros possíveis:** `400` serviço não concluído, `403` não é o dono, `404` solicitação não encontrada, `409` avaliação duplicada.

---

### Notificações (`/notifications`)

As notificações são criadas automaticamente pelo consumer Kafka. O usuário não cria notificações manualmente.

#### `GET /notifications` — Listar Notificações

Retorna todas as notificações do usuário autenticado, da mais recente para a mais antiga.

**Auth:** Bearer token

**Query params opcionais:**
- `?unread=true` → filtra apenas as não lidas

---

#### `PATCH /notifications/:id/read` — Marcar como Lida

Marca uma notificação como lida (preenche o campo `readAt`).

**Auth:** Bearer token

**Erros possíveis:** `403` se a notificação não pertencer ao usuário, `404` se não existir.

---

## Regras de negócio

As regras abaixo são aplicadas nas camadas de service e garantem a consistência do sistema.

| # | Onde | Regra |
|---|---|---|
| RN-01 | `service-requests.service` → `create()` | `scheduledAt` deve ser ≥ agora + 2 horas → `400` |
| RN-02 | `service-requests.service` → `create()` | Pet deve existir e pertencer ao dono autenticado → `404`/`403` |
| RN-03 | `service-requests.service` → `create()` | Pet com solicitação `OPEN` ou `ACCEPTED` ativa bloqueia nova abertura → `409` |
| RN-04 | `expire-requests.job.js` (cron a cada hora) | Solicitações `OPEN` com `expiresAt` vencido são automaticamente canceladas |
| RN-05 | `service-requests.service` → `accept()` | Cuidador `INACTIVE` não pode aceitar → `403` |
| RN-06 | `service-requests.service` → `accept()` | Cuidador com 3 ou mais solicitações `IN_PROGRESS` não pode aceitar mais → `409` |
| RN-07 | `service-requests.service` → `accept()` | Primeiro cuidador a aceitar assume a solicitação — status muda para `ACCEPTED` e não pode ser aceita por outros |
| RN-08 | `service-requests.service` → `refuse()` | Recusa devolve status para `OPEN` e limpa o `caregiverId`, liberando para novos aceites |
| RN-09 | `service-requests.service` → `cancel()` | Dono só pode cancelar se status for `OPEN` → `403` |
| RN-10 | `service-requests.service` → `start()` | Apenas o cuidador atribuído pode iniciar o serviço → `403` |
| RN-11 | `service-requests.service` → `complete()` | Apenas o cuidador atribuído pode concluir o serviço → `403` |
| RN-12 | `reviews.service` → `create()` | Avaliação exige status `COMPLETED` → `400` |
| RN-13 | `reviews.service` → `create()` | Cada solicitação gera no máximo uma avaliação → `409` |
| RN-14 | `reviews.service` → `create()` | `averageRating` do cuidador é recalculado com `AVG(rating)` sobre todas as suas avaliações |
| RN-15 | `notifications.repository` → `existsDuplicate()` | Notificação com mesmo `userId + eventType + requestId` não é recriada (deduplicação) |

---

## Eventos Kafka

Veja a documentação completa dos eventos em [Integração com MOM (Kafka)](integracao_Mom.md).

Resumo dos tópicos publicados:

| Tópico | Publicado quando | Destinatário |
|---|---|---|
| `service_request.created` | Dono cria solicitação | Todos os cuidadores `ACTIVE` |
| `service_request.accepted` | Cuidador aceita | Dono da solicitação |
| `service_request.refused` | Cuidador recusa | Dono da solicitação |
| `service_request.cancelled` | Dono cancela solicitação | Todos os cuidadores `ACTIVE` |
| `service_request.in_progress` | Cuidador inicia | Dono da solicitação |
| `service.completed` | Cuidador conclui | Dono da solicitação |
| `review.created` | Dono avalia | Cuidador avaliado |

---

## Tratamento de erros

Todos os erros passam pelo middleware `error.middleware.js`, que padroniza as respostas.

| Código HTTP | Quando ocorre |
|---|---|
| `400 Bad Request` | Validação Zod falhou, dados inválidos, regra de negócio (ex: data muito próxima) |
| `401 Unauthorized` | Token JWT ausente, inválido ou expirado |
| `403 Forbidden` | Token válido, mas sem permissão (role incorreto, recurso de outro usuário) |
| `404 Not Found` | Recurso não encontrado no banco de dados |
| `409 Conflict` | Duplicidade (e-mail/telefone/avaliação) ou estado inválido (pet já tem solicitação ativa) |
| `500 Internal Server Error` | Erro inesperado no servidor |

**Formato de erro:**
```json
{
  "error": "Mensagem descrevendo o problema"
}
```

---

## Infraestrutura Docker

O `docker-compose.yml` sobe todos os serviços com um único comando. O Kafka roda no modo **KRaft** (sem Zookeeper, simplificando a configuração).

| Serviço | Imagem | Porta | Função |
|---|---|---|---|
| `plantao-pet-postgres` | `postgres:15` | `5432` | Banco de dados relacional |
| `plantao-pet-kafka` | `apache/kafka:3.7.0` | `9092` | Message broker KRaft |
| `plantao-pet-kafka-ui` | `provectuslabs/kafka-ui:latest` | `${KAFKA_UI_PORT}` | Interface web para inspecionar tópicos e mensagens |
| `plantao-pet-api` | Build local (Dockerfile) | `${PORT}` | API REST + Socket.IO |

Os containers `postgres` e `kafka` possuem healthcheck configurado. A `api` aguarda ambos estarem saudáveis e executa `prisma migrate deploy` automaticamente ao subir.

```bash
# Subir toda a infraestrutura
docker compose up -d

# Verificar status dos containers
docker compose ps

# Acompanhar logs da API em tempo real
docker compose logs -f api

# Derrubar e remover volumes (reseta o banco)
docker compose down -v
```

---

## Variáveis de ambiente

Crie o arquivo `backend/.env` a partir do template:

```bash
cp backend/.env.example backend/.env
```

| Variável | Exemplo | Descrição |
|---|---|---|
| `DATABASE_URL` | `postgresql://plantao:senha@postgres:5432/plantao_pet` | URL de conexão com o PostgreSQL |
| `POSTGRES_DB` | `plantao_pet` | Nome do banco de dados |
| `POSTGRES_USER` | `plantao` | Usuário do banco |
| `POSTGRES_PASSWORD` | `senha_forte` | Senha do banco |
| `JWT_SECRET` | *(string base64 de 64 bytes)* | Chave de assinatura dos tokens JWT — nunca versionar |
| `JWT_EXPIRES_IN` | `7d` | Validade do token (ex: `7d`, `24h`, `1h`) |
| `PORT` | `3000` | Porta onde a API escuta |
| `KAFKA_BROKER` | `kafka:29092` (Docker) / `localhost:9092` (local) | Endereço do broker Kafka |
| `KAFKA_UI_PORT` | `8080` | Porta da interface Kafka UI |
| `KAFKA_CLUSTER_NAME` | `plantao-pet` | Nome exibido na Kafka UI |

**Gerando o JWT_SECRET:**
```bash
node -e "console.log(require('crypto').randomBytes(64).toString('base64'))"
```

---

## Scripts disponíveis

```bash
npm start          # Inicia o servidor em modo produção
npm run dev        # Inicia com nodemon (hot reload para desenvolvimento)
npm run db:migrate # Executa as migrations do Prisma
npm run db:generate # Regenera o Prisma Client após mudanças no schema
npm run db:studio  # Abre o Prisma Studio (interface visual do banco) na porta 5555
```

---

## Tecnologias e dependências

| Categoria | Tecnologia | Versão |
|---|---|---|
| Runtime | Node.js | 20+ |
| Framework web | Express | 4.x |
| ORM | Prisma | 5.x |
| Banco de dados | PostgreSQL | 15 |
| Message broker | Apache Kafka (KRaft) | 3.7.0 |
| Cliente Kafka | kafkajs | 2.x |
| WebSocket | Socket.IO | 4.x |
| Autenticação | jsonwebtoken | 9.x |
| Hash de senha | bcryptjs | 2.x |
| Validação de schemas | Zod | 3.x |
| Documentação API | swagger-ui-express + swagger-jsdoc | 5.x / 6.x |
| Agendamento de tarefas | node-cron | 4.x |
| Variáveis de ambiente | dotenv | 16.x |
| CORS | cors | 2.x |
| Hot reload (dev) | nodemon | 3.x |
| Containerização | Docker + Docker Compose | — |

---

<div align="center">
  <img width="70%" alt="pucminas" src="images/banner-institucional.svg"/>
</div>
<p align="center">Fonte do banner: <a href="https://github.com/joaopauloaramuni">João Paulo Carneiro Aramuni</a></p>
