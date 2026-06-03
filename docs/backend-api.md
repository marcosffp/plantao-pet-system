<img width="1600" style="height:auto; border-radius: 12px;" alt="banner" src="images/banner.png" />

# Backend — Documentação Técnica

> API REST do **Plantão Pet** construída com Node.js + Express, PostgreSQL via Prisma, Apache Kafka (KRaft) e Socket.IO.

---

## Sumário

- [Arquitetura](#arquitetura)
- [Estrutura de módulos](#estrutura-de-módulos)
- [Estrutura de pastas](#estrutura-de-pastas)
- [Modelo de dados](#modelo-de-dados)
- [APIs e endpoints](#apis-e-endpoints)
- [Eventos Kafka](#eventos-kafka)
- [Regras de negócio](#regras-de-negócio)
- [Infraestrutura Docker](#infraestrutura-docker)
- [Variáveis de ambiente](#variáveis-de-ambiente)
- [Instalação e execução](#instalação-e-execução)
- [Testes da API](#testes-da-api)
- [Tecnologias e dependências](#tecnologias-e-dependências)

---

## Arquitetura

A aplicação adota uma **arquitetura orientada a eventos (Event-Driven Architecture)** no backend, com Clean Architecture nas camadas internas. O backend expõe uma API REST consumida pelos apps Flutter e publica eventos de domínio no Kafka; o consumer Kafka recebe esses eventos e os despacha via Socket.IO para os clientes conectados.

```
┌──────────────────────────────────────────────────────────────────┐
│                       Apps Flutter                               │
│           App Dono (Owner)  ·  App Cuidador (Caregiver)          │
└────────────────────────┬────────────────────────┬────────────────┘
                         │  REST HTTP/JSON         │  WebSocket (Socket.IO)
┌────────────────────────▼────────────────────────▼────────────────┐
│                        Backend (Node.js)                         │
│  Routes → Controllers → Services → Repositories                  │
│                  │ Kafka Producer                                 │
└──────────────────┼───────────────────────────────────────────────┘
                   │  Publish/Subscribe
┌──────────────────▼───────────────────────────────────────────────┐
│                      Apache Kafka (KRaft)                        │
│           service_request.* · service.completed · review.*       │
└──────────────────┬───────────────────────────────────────────────┘
                   │  Kafka Consumer → Socket.IO emit
┌──────────────────▼───────────────────────────────────────────────┐
│                  Persistência (PostgreSQL 15)                     │
│              Prisma ORM · Tabela Notification                    │
└──────────────────────────────────────────────────────────────────┘
```

**Diagrama completo:** `docs/images/Arquitetura.jpg`

| Conexão | Protocolo | Formato |
|---|---|---|
| App Flutter → Backend | HTTP/REST | JSON |
| Backend → PostgreSQL | TCP (Prisma ORM) | SQL |
| Backend → Kafka | TCP (kafkajs) | JSON |
| Kafka Consumer → Apps | WebSocket (Socket.IO) | JSON |

---

## Estrutura de módulos

| Módulo | Camada | Responsabilidade |
|---|---|---|
| `routes/` | Apresentação | Definição das rotas Express e aplicação de middlewares |
| `controllers/` | Apresentação | Recebe req/res, delega ao service, serializa resposta |
| `services/` | Domínio | Lógica de negócio, validações e publicação de eventos Kafka |
| `repositories/` | Infraestrutura | Acesso ao banco via Prisma Client |
| `middlewares/` | Transversal | Autenticação JWT, tratamento de erros, validação Zod |
| `kafka/` | Infraestrutura | Producer (publica eventos) e Consumer (recebe e despacha via Socket.IO) |
| `socket/` | Infraestrutura | Configuração do Socket.IO e gerenciamento de salas por usuário |
| `jobs/` | Agendamento | Cron job node-cron para expirar solicitações OPEN vencidas |
| `schemas/` | Validação | Schemas Zod para validação de bodies de requisição |
| `utils/` | Transversal | `AppError` e `asyncHandler` |

---

## Estrutura de pastas

```
backend/
├── src/
│   ├── server.js
│   ├── app.js
│   ├── prisma/
│   │   └── client.js
│   ├── routes/
│   │   ├── auth.routes.js
│   │   ├── owners.routes.js
│   │   ├── pets.routes.js
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
│   └── schema.prisma
├── docker-compose.yml
├── Dockerfile
├── .env               ← não versionado
├── .env.example       ← template público
└── package.json
```

---

## Modelo de dados

Armazenado no **PostgreSQL 15** via **Prisma ORM**.

![Diagrama do Banco de Dados](images/Diagrama_Entidades_Banco_Dados.png)

### Entidades

| Entidade | Descrição | Relações |
|---|---|---|
| `Owner` | Dono do pet: nome, e-mail, telefone, endereço | 1:N com `Pet`, `ServiceRequest`, `Review` |
| `Pet` | Animal do dono: espécie, raça, idade, notas especiais | N:1 com `Owner`, 1:N com `ServiceRequest` |
| `Caregiver` | Cuidador: bairros de atuação, serviços oferecidos, média de avaliações | 1:N com `ServiceRequest`, `Review` |
| `ServiceRequest` | Transação central: relaciona Dono, Cuidador e Pet com status e ciclo de vida completo | N:1 com `Owner`, `Pet`, `Caregiver`; 1:1 com `Review` |
| `Review` | Avaliação pós-serviço: rating numérico e comentário; atualiza `averageRating` do cuidador | N:1 com `Owner`, `Caregiver`; 1:1 com `ServiceRequest` |
| `Notification` | Histórico persistido de todas as notificações despachadas via Kafka + Socket.IO | — |

### Enums

| Enum | Valores |
|---|---|
| `Species` | `DOG`, `CAT`, `OTHER` |
| `ServiceType` | `WALK_30MIN`, `WALK_1H`, `HOME_VISIT`, `HOSTING` |
| `RequestStatus` | `OPEN`, `ACCEPTED`, `IN_PROGRESS`, `COMPLETED`, `CANCELLED`, `REFUSED` |
| `CaregiverStatus` | `ACTIVE`, `INACTIVE` |

---

## APIs e endpoints

Documentação interativa disponível em `http://localhost:3000/api-docs` após subir a aplicação.

### Autenticação (`/auth`)

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| `POST` | `/auth/owner/register` | — | Registrar dono |
| `POST` | `/auth/owner/login` | — | Login do dono → retorna `{ token }` |
| `POST` | `/auth/caregiver/register` | — | Registrar cuidador |
| `POST` | `/auth/caregiver/login` | — | Login do cuidador → retorna `{ token }` |

### Donos (`/owners`)

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| `GET` | `/owners/:id` | JWT | Perfil do dono |

### Pets (`/owners/pets`)

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| `POST` | `/owners/pets` | JWT dono | Cadastrar pet |
| `GET` | `/owners/pets` | JWT dono | Listar pets do dono autenticado |
| `PUT` | `/owners/pets/:petId` | JWT dono | Editar pet (verifica propriedade) |
| `DELETE` | `/owners/pets/:petId` | JWT dono | Deletar pet (verifica propriedade) |
| `GET` | `/pets/:id` | JWT | Detalhe de um pet |

### Cuidadores (`/caregivers`)

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| `GET` | `/caregivers` | — | Listar cuidadores ativos |
| `GET` | `/caregivers/:id` | — | Perfil do cuidador |
| `PATCH` | `/caregivers/:id/status` | JWT cuidador | Atualizar status (`ACTIVE`/`INACTIVE`) |
| `GET` | `/caregivers/:id/reviews` | — | Avaliações recebidas pelo cuidador |

### Solicitações de Serviço (`/service-requests`)

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| `POST` | `/service-requests` | JWT dono | Criar solicitação |
| `GET` | `/service-requests` | JWT cuidador | Listar solicitações `OPEN` |
| `GET` | `/service-requests/my` | JWT | Solicitações do usuário autenticado |
| `GET` | `/service-requests/:id` | JWT | Detalhe de uma solicitação |
| `PATCH` | `/service-requests/:id/accept` | JWT cuidador | Aceitar solicitação |
| `PATCH` | `/service-requests/:id/refuse` | JWT cuidador | Recusar solicitação |
| `PATCH` | `/service-requests/:id/cancel` | JWT dono | Cancelar solicitação |
| `PATCH` | `/service-requests/:id/start` | JWT cuidador | Iniciar serviço |
| `PATCH` | `/service-requests/:id/complete` | JWT cuidador | Concluir serviço |

### Avaliações (`/reviews`)

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| `POST` | `/reviews` | JWT dono | Criar avaliação pós-serviço |

### Notificações (`/notifications`)

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| `GET` | `/notifications` | JWT | Listar notificações do usuário |
| `PATCH` | `/notifications/:id/read` | JWT | Marcar notificação como lida |

---

## Eventos Kafka

O consumer está inscrito no group `plantao-pet-group`. Cada evento é persistido na tabela `Notification` com deduplicação e despachado via Socket.IO para o cliente destinatário.

| Tópico | Produtor | Destinatário Socket.IO | Evento emitido |
|---|---|---|---|
| `service_request.created` | `service-requests.service` → `create()` | Todos os cuidadores ACTIVE | `new_request` |
| `service_request.accepted` | `service-requests.service` → `accept()` | Owner da solicitação | `request_accepted` |
| `service_request.refused` | `service-requests.service` → `refuse()` | Owner da solicitação | `request_refused` |
| `service_request.in_progress` | `service-requests.service` → `start()` | Owner da solicitação | `service_started` |
| `service.completed` | `service-requests.service` → `complete()` | Owner da solicitação | `service_completed` |
| `review.created` | `reviews.service` → `create()` | Cuidador avaliado | `new_review` |

### Fluxo completo ponta a ponta

```
Owner                    Backend                    Kafka              Caregiver
  │                         │                         │                    │
  │── POST /service-requests ▶──── OPEN ──── publish("service_request.created") ──▶ │
  │                         │◀─────────── consume ────┤                    │
  │                         │                    Socket.IO: new_request ──▶│
  │                         │◀── PATCH /:id/accept ───────────────────────│
  │                         │         ACCEPTED         │                    │
  │◀── Socket.IO: request_accepted ─────────────────── │                   │
  │                         │◀── PATCH /:id/start ─────────────────────── │
  │◀── Socket.IO: service_started ──────────────────── │                   │
  │                         │◀── PATCH /:id/complete ──────────────────── │
  │◀── Socket.IO: service_completed ────────────────── │                   │
  │── POST /reviews ────────▶── recalcula averageRating                    │
  │                         │──── publish("review.created") ───────────────┤
  │                         │                    Socket.IO: new_review ───▶│
```

---

## Regras de negócio

| # | Onde | Regra |
|---|---|---|
| RN-01 | `service-requests.service` → `create()` | Pet com solicitação `OPEN` ou `ACCEPTED` ativa bloqueia nova abertura → `409` |
| RN-02 | `service-requests.service` → `create()` | `scheduledAt` deve ser ≥ 2 horas no futuro → `400` |
| RN-03 | `expire-requests.job.js` (cron a cada hora) | Solicitações `OPEN` com `expiresAt` vencido são canceladas automaticamente |
| RN-04 | `service-requests.service` → `cancel()` | Dono só pode cancelar se status for `OPEN` → `403` |
| RN-05 | `service-requests.service` → `accept()` | Cuidador `INACTIVE` não pode aceitar → `403` |
| RN-06 | `service-requests.service` → `accept()` | Limite de 3 solicitações `IN_PROGRESS` simultâneas por cuidador → `409` |
| RN-07 | `service-requests.service` → `refuse()` | Recusa devolve status para `OPEN` |
| RN-08 | `service-requests.service` → `accept()` | Primeiro cuidador a aceitar bloqueia a solicitação → `ACCEPTED` |
| RN-09 | `service-requests.service` → `start()` | Apenas o cuidador atribuído pode mudar `ACCEPTED` → `IN_PROGRESS` → `403` |
| RN-10 | `service-requests.service` → `complete()` | Apenas o cuidador atribuído pode marcar `COMPLETED` → `403` |
| RN-11 | `service-requests.service` → `complete()` | Publica `service.completed` com `{ requestId, completedAt, caregiverId, ownerId }` |
| RN-12 | `reviews.service` → `create()` | Avaliação exige status `COMPLETED` → `400` |
| RN-13 | `reviews.service` → `create()` | Cada solicitação gera no máximo uma avaliação → `409` |
| RN-14 | `reviews.service` → `create()` | Recalcula `averageRating` do cuidador com `AVG(rating)` via Prisma |
| RN-15 | `service-requests.service` → `create()` | Pet deve existir e pertencer ao dono autenticado → `404`/`403` |

---

## Infraestrutura Docker

O `docker-compose.yml` sobe todos os serviços. O Kafka roda no modo **KRaft** (sem Zookeeper).

| Serviço | Imagem | Porta | Função |
|---|---|---|---|
| `plantao-pet-postgres` | `postgres:15` | `5432` | Banco de dados relacional |
| `plantao-pet-kafka` | `apache/kafka:3.7.0` | `9092` | Message broker (KRaft) |
| `plantao-pet-kafka-ui` | `provectuslabs/kafka-ui:latest` | `${KAFKA_UI_PORT}` | Interface web do Kafka |
| `plantao-pet-api` | Build local (Dockerfile) | `${PORT}` | API REST + Socket.IO |

> `postgres` e `kafka` possuem healthcheck configurado. A `api` aguarda ambos estarem saudáveis e executa `prisma migrate deploy` automaticamente na subida.

```bash
# Subir toda a infraestrutura
docker compose up -d

# Verificar status
docker compose ps

# Logs da API
docker compose logs -f api

# Derrubar e remover volumes
docker compose down -v
```

---

## Variáveis de ambiente

Crie `backend/.env` a partir do template:

```bash
cp backend/.env.example backend/.env
```

| Variável | Exemplo | Descrição |
|---|---|---|
| `DATABASE_URL` | `postgresql://plantao:senha@postgres:5432/plantao_pet` | URL de conexão com o PostgreSQL |
| `POSTGRES_DB` | `plantao_pet` | Nome do banco |
| `POSTGRES_USER` | `plantao` | Usuário do banco |
| `POSTGRES_PASSWORD` | `senha_forte` | Senha do banco |
| `JWT_SECRET` | *(string base64 64 bytes)* | Chave de assinatura JWT — nunca commitar |
| `JWT_EXPIRES_IN` | `7d` | Validade do token |
| `PORT` | `3000` | Porta da API |
| `KAFKA_BROKER` | `kafka:29092` (Docker) / `localhost:9092` (local) | Endereço do broker Kafka |
| `KAFKA_UI_PORT` | `8080` | Porta da interface Kafka UI |
| `KAFKA_CLUSTER_NAME` | `plantao-pet` | Nome do cluster no Kafka UI |

Gere o `JWT_SECRET`:
```bash
node -e "console.log(require('crypto').randomBytes(64).toString('base64'))"
```

---

## Instalação e execução

### Com Docker (recomendado)

```bash
# 1. Clone o repositório
git clone <url-do-repositorio>

# 2. Configure o ambiente
cp backend/.env.example backend/.env
# Edite o .env com suas configurações

# 3. Suba todos os serviços
cd backend
docker compose up -d

# 4. Verifique os containers
docker compose ps
```

### Acessos

| Serviço | URL |
|---|---|
| API REST | `http://localhost:3000` |
| Swagger UI | `http://localhost:3000/api-docs` |
| Kafka UI | `http://localhost:8080` |
| Prisma Studio | `http://localhost:5555` (apenas local) |

### Scripts npm

| Script | Descrição |
|---|---|
| `npm start` | Servidor em produção |
| `npm run dev` | Hot reload com nodemon |
| `npm run db:migrate` | Executa migrations Prisma |
| `npm run db:generate` | Regenera o Prisma Client |
| `npm run db:studio` | Abre o Prisma Studio na porta 5555 |

---

## Testes da API

Coleção Postman disponível em `docs/Plantão Pet.postman_collection.json`.

1. Importe o arquivo no Postman
2. Configure a variável `{{baseUrl}}` com `http://localhost:3000`
3. Execute na ordem:

```
1.  Registrar Dono
2.  Login Dono              → preenche {{ownerToken}}
3.  Registrar Cuidador
4.  Login Cuidador          → preenche {{caregiverToken}}
5.  Cadastrar Pet
6.  Criar Solicitação
7.  Listar Solicitações Abertas (Cuidador)
8.  Aceitar Solicitação
9.  Iniciar Serviço
10. Concluir Serviço
11. Avaliar Cuidador
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
| Validação | Zod | 3.x |
| Documentação API | swagger-ui-express + swagger-jsdoc | 5.x / 6.x |
| Agendamento | node-cron | 4.x |
| Variáveis de ambiente | dotenv | 16.x |
| CORS | cors | 2.x |
| Hot reload | nodemon (dev) | 3.x |
| Containerização | Docker + Docker Compose | — |

---

<div align="center">
  <img width="70%" alt="pucminas" src="images/banner-institucional.svg"/>
</div>
<p align="center">Fonte do banner: <a href="https://github.com/joaopauloaramuni">João Paulo Carneiro Aramuni</a></p>
