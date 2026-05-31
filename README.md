# Plantão Pet

> Plataforma de matchmaking entre donos de pets e cuidadores de animais, com agendamento de serviços, comunicação assíncrona via Apache Kafka e notificações em tempo real via WebSocket.

---

## 🛠️ Stack Principal

![Node.js](https://img.shields.io/badge/Node.js-20+-6DA55F?style=for-the-badge&logo=nodedotjs&logoColor=white)
![Express](https://img.shields.io/badge/Express-4.x-404D59?style=for-the-badge&logo=express&logoColor=61DAFB)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Prisma](https://img.shields.io/badge/Prisma-5.x-5A67D8?style=for-the-badge&logo=prisma&logoColor=white)
![Apache Kafka](https://img.shields.io/badge/Apache_Kafka-3.7-E34F26?style=for-the-badge&logo=apachekafka&logoColor=white)
![Socket.IO](https://img.shields.io/badge/Socket.IO-4.x-0D7DC5?style=for-the-badge&logo=socketdotio&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-3.10+-54C5F8?style=for-the-badge&logo=flutter&logoColor=white)
![Docker](https://img.shields.io/badge/Docker_Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)

---

## 📑 Sumário

- [Sobre o projeto](#-sobre-o-projeto)
- [Vídeo de apresentação do fluxo mom](#-vídeo-de-apresentação)
- [Arquitetura](#-arquitetura)
- [Estrutura de módulos](#-estrutura-de-módulos)
- [Estrutura de pastas](#-estrutura-de-pastas)
- [Modelo de dados](#-modelo-de-dados)
- [APIs e endpoints](#-apis-e-endpoints)
- [Eventos Kafka](#-eventos-kafka)
- [Regras de negócio](#-regras-de-negócio)
- [Infraestrutura Docker](#-infraestrutura-docker)
- [Variáveis de ambiente](#-variáveis-de-ambiente)
- [Instalação e execução](#-instalação-e-execução)
- [Testes da API](#-testes-da-api)
- [Tecnologias e dependências](#-tecnologias-e-dependências)

---

## 📖 Sobre o projeto

O **Plantão Pet** conecta donos de pets a cuidadores de animais. Donos cadastram seus pets, abrem solicitações de serviço (passeios, visitas domiciliares, hospedagem) e aguardam que um cuidador disponível aceite. Todo o ciclo de vida da solicitação — criação, aceitação, início, conclusão e avaliação — é orquestrado de forma assíncrona via Apache Kafka, com notificações entregues em tempo real aos apps Flutter via Socket.IO.

O projeto é composto por três repositórios integrados:

| Repositório | Tecnologia | Descrição |
|---|---|---|
| `backend/` | Node.js + Express | API REST, PostgreSQL, Kafka, WebSocket |
| `plantao-pet-owner-app/` | Flutter/Dart | App do Dono (cliente) |
| `plantao-pet-caregiver-app/` | Flutter/Dart | App do Cuidador (prestador) |

---

## 🎥 Vídeo de Apresentação

> **Professor, para facilitar a avaliação do projeto, a demonstração do fluxo das mensagens pode ser acessada pelo link abaixo:**

### 👉 [Assistir Vídeo de Apresentação](https://drive.google.com/file/d/12Vf2aGwrp9X9751zxPZRw6eRGAjnw2HE/view?usp=sharing)

---

## 🏛️ Arquitetura

A aplicação adota uma arquitetura orientada a eventos (Event-Driven Architecture) no backend, com Clean Architecture nas camadas de cada app Flutter. O backend expõe uma API REST consumida pelos apps e publica eventos de domínio no Kafka; o consumer Kafka recebe esses eventos e os despacha via Socket.IO para os clientes conectados.

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

**Diagrama completo:**

![Diagrama de Arquitetura](docs/images/Arquitetura.jpg)

**Protocolos por camada:**

| Conexão | Protocolo | Formato |
|---|---|---|
| App Flutter → Backend | HTTP/REST | JSON |
| Backend → PostgreSQL | TCP (Prisma ORM) | SQL |
| Backend → Kafka | TCP (kafkajs) | JSON |
| Kafka Consumer → Apps | WebSocket (Socket.IO) | JSON |

Para detalhes completos da integração com o Kafka, consulte a [documentação de integração com o MOM](docs/Integracao_Mom.md).

---

## 🧩 Estrutura de módulos

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

## 📁 Estrutura de pastas

```
plantao-pet-system/
├── backend/
│   ├── src/
│   │   ├── server.js
│   │   ├── app.js
│   │   ├── prisma/
│   │   │   └── client.js
│   │   ├── routes/
│   │   │   ├── auth.routes.js
│   │   │   ├── owners.routes.js
│   │   │   ├── pets.routes.js
│   │   │   ├── caregivers.routes.js
│   │   │   ├── service-requests.routes.js
│   │   │   ├── reviews.routes.js
│   │   │   └── notifications.routes.js
│   │   ├── controllers/
│   │   │   ├── auth.controller.js
│   │   │   ├── owners.controller.js
│   │   │   ├── pets.controller.js
│   │   │   ├── caregivers.controller.js
│   │   │   ├── service-requests.controller.js
│   │   │   ├── reviews.controller.js
│   │   │   └── notifications.controller.js
│   │   ├── services/
│   │   │   ├── auth.service.js
│   │   │   ├── owners.service.js
│   │   │   ├── pets.service.js
│   │   │   ├── caregivers.service.js
│   │   │   ├── service-requests.service.js
│   │   │   ├── reviews.service.js
│   │   │   └── notifications.service.js
│   │   ├── repositories/
│   │   │   ├── owners.repository.js
│   │   │   ├── pets.repository.js
│   │   │   ├── caregivers.repository.js
│   │   │   ├── service-requests.repository.js
│   │   │   ├── reviews.repository.js
│   │   │   └── notifications.repository.js
│   │   ├── middlewares/
│   │   │   ├── auth.middleware.js
│   │   │   ├── error.middleware.js
│   │   │   └── validate.middleware.js
│   │   ├── kafka/
│   │   │   ├── kafka.client.js
│   │   │   ├── kafka.producer.js
│   │   │   └── kafka.consumer.js
│   │   ├── socket/
│   │   │   └── socket.js
│   │   ├── jobs/
│   │   │   └── expire-requests.job.js
│   │   ├── schemas/
│   │   │   ├── owner.schema.js
│   │   │   ├── pet.schema.js
│   │   │   ├── caregiver.schema.js
│   │   │   ├── service-request.schema.js
│   │   │   └── review.schema.js
│   │   └── utils/
│   │       ├── AppError.js
│   │       └── asyncHandler.js
│   ├── prisma/
│   │   └── schema.prisma
│   ├── docker-compose.yml
│   ├── Dockerfile
│   ├── .env
│   ├── .env.example
│   └── package.json
└── docs/
    ├── images/
    │   ├── Arquitetura.jpg
    │   └── Diagrama_Entidades_Banco_Dados.png
    ├── Integracao_Mom.md
    └── Plantão Pet.postman_collection.json
```

---

## 🗄️ Modelo de dados

Os dados são armazenados de forma relacional no **PostgreSQL 15**, gerenciado pelo **Prisma ORM**.

![Diagrama do Banco de Dados](docs/images/Diagrama_Entidades_Banco_Dados.png)

### Entidades

| Entidade | Descrição | Relações |
|---|---|---|
| `Owner` | Dono do pet: nome, e-mail, telefone, endereço | 1:N com `Pet`, `ServiceRequest`, `Review` |
| `Pet` | Animal do dono: espécie, raça, idade, notas especiais | N:1 com `Owner`, 1:N com `ServiceRequest` |
| `Caregiver` | Cuidador: bairros de atuação, serviços oferecidos, média de avaliações | 1:N com `ServiceRequest`, `Review` |
| `ServiceRequest` | Transação central do sistema: relaciona Dono, Cuidador e Pet com status e ciclo de vida completo | N:1 com `Owner`, `Pet`, `Caregiver`; 1:1 com `Review` |
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

## 🌐 APIs e endpoints

Documentação interativa disponível em `http://localhost:3000/api-docs/#/` após subir a aplicação.

### Autenticação (`/auth`)

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| `POST` | `/auth/owner/register` | — | Registrar dono (nome, e-mail, telefone, endereço, senha) |
| `POST` | `/auth/owner/login` | — | Login do dono → retorna `{ token }` |
| `POST` | `/auth/caregiver/register` | — | Registrar cuidador (nome, e-mail, telefone, bairros, serviços, senha) |
| `POST` | `/auth/caregiver/login` | — | Login do cuidador → retorna `{ token }` |

### Donos (`/owners`)

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| `GET` | `/owners/:id` | JWT | Perfil do dono |

### Pets (`/owners/:ownerId/pets` e `/pets`)

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| `POST` | `/owners/:ownerId/pets` | JWT dono | Cadastrar pet |
| `GET` | `/owners/:ownerId/pets` | JWT | Listar pets do dono |
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
| `POST` | `/service-requests` | JWT dono | Criar solicitação (aplica RN-01 e RN-02) |
| `GET` | `/service-requests` | JWT cuidador | Listar solicitações com status `OPEN` |
| `GET` | `/service-requests/my` | JWT | Solicitações do usuário autenticado |
| `GET` | `/service-requests/:id` | JWT | Detalhe de uma solicitação |
| `PATCH` | `/service-requests/:id/accept` | JWT cuidador | Aceitar solicitação (aplica RN-05 e RN-06) |
| `PATCH` | `/service-requests/:id/refuse` | JWT cuidador | Recusar solicitação (status volta para `OPEN`) |
| `PATCH` | `/service-requests/:id/cancel` | JWT dono | Cancelar solicitação (aplica RN-04) |
| `PATCH` | `/service-requests/:id/start` | JWT cuidador | Iniciar serviço (aplica RN-09) |
| `PATCH` | `/service-requests/:id/complete` | JWT cuidador | Concluir serviço (aplica RN-10) |

### Avaliações (`/reviews`)

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| `POST` | `/reviews` | JWT dono | Criar avaliação (aplica RN-12 e RN-13) |

### Notificações (`/notifications`)

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| `GET` | `/notifications` | JWT | Listar notificações do usuário autenticado |
| `PATCH` | `/notifications/:id/read` | JWT | Marcar notificação como lida |

---

## 📨 Eventos Kafka

O consumer está inscrito no group `plantao-pet-group`. Cada evento é persistido na tabela `Notification` com deduplicação e despachado via Socket.IO para o cliente destinatário.

| Tópico | Produtor | Destinatário Socket.IO | Evento emitido |
|---|---|---|---|
| `service_request.created` | `service-requests.service.js` → `create()` | Todos os cuidadores ACTIVE | `new_request` |
| `service_request.accepted` | `service-requests.service.js` → `accept()` | Owner da solicitação | `request_accepted` |
| `service_request.refused` | `service-requests.service.js` → `refuse()` | Owner da solicitação | `request_refused` |
| `service_request.in_progress` | `service-requests.service.js` → `start()` | Owner da solicitação | `service_started` |
| `service.completed` | `service-requests.service.js` → `complete()` | Owner da solicitação | `service_completed` |
| `review.created` | `reviews.service.js` → `create()` | Cuidador avaliado | `new_review` |

### Fluxo completo de ponta a ponta

```
Owner                    Backend                    Kafka              Caregiver
  │                         │                         │                    │
  │── POST /service-requests ▶──── OPEN ──── publish("service_request.created") ──▶ │
  │                         │                         │                    │
  │                         │◀─────────── consume ────┤                    │
  │                         │                    Socket.IO: new_request ──▶│
  │                         │                         │                    │
  │                         │◀── PATCH /:id/accept ───────────────────────│
  │                         │         ACCEPTED         │                    │
  │                         │──── publish("service_request.accepted") ─────┤
  │◀── Socket.IO: request_accepted ─────────────────── │                   │
  │                         │                         │                    │
  │                         │◀── PATCH /:id/start ─────────────────────── │
  │                         │        IN_PROGRESS       │                   │
  │◀── Socket.IO: service_started ──────────────────── │                   │
  │                         │                         │                    │
  │                         │◀── PATCH /:id/complete ──────────────────── │
  │                         │        COMPLETED         │                   │
  │◀── Socket.IO: service_completed ────────────────── │                   │
  │                         │                         │                    │
  │── POST /reviews ────────▶── recalcula averageRating                    │
  │                         │──── publish("review.created") ───────────────┤
  │                         │                    Socket.IO: new_review ───▶│
```

---

## 📋 Regras de negócio

| # | Onde | Regra |
|---|---|---|
| RN-01 | `service-requests.service.js` → `create()` | Pet com solicitação `OPEN` ou `ACCEPTED` ativa bloqueia nova abertura → `409` |
| RN-02 | `service-requests.service.js` → `create()` | `scheduledAt` deve ser ≥ 2 horas no futuro → `400` |
| RN-03 | `expire-requests.job.js` (cron a cada hora) | Solicitações `OPEN` com `expiresAt` vencido são canceladas automaticamente; publica `service_request.expired` |
| RN-04 | `service-requests.service.js` → `cancel()` | Dono só pode cancelar se status for `OPEN` → `403` |
| RN-05 | `service-requests.service.js` → `accept()` | Cuidador `INACTIVE` não pode aceitar → `403` |
| RN-06 | `service-requests.service.js` → `accept()` | Limite de 3 solicitações `IN_PROGRESS` simultâneas por cuidador → `409` |
| RN-07 | `service-requests.service.js` → `refuse()` | Recusa devolve status para `OPEN`; publica `service_request.refused` |
| RN-08 | `service-requests.service.js` → `accept()` | Primeiro cuidador a aceitar bloqueia a solicitação → `ACCEPTED` |
| RN-09 | `service-requests.service.js` → `start()` | Apenas o cuidador atribuído pode mudar `ACCEPTED` → `IN_PROGRESS` → `403` |
| RN-10 | `service-requests.service.js` → `complete()` | Apenas o cuidador atribuído pode marcar `COMPLETED` → `403` |
| RN-11 | `service-requests.service.js` → `complete()` | Publicar `service.completed` com `{ requestId, completedAt, caregiverId, ownerId }` |
| RN-12 | `reviews.service.js` → `create()` | Avaliação exige status `COMPLETED` → `400` |
| RN-13 | `reviews.service.js` → `create()` | Cada solicitação gera no máximo uma avaliação → `409` |
| RN-14 | `reviews.service.js` → `create()` | Recalcula `averageRating` do cuidador com `AVG(rating)` via Prisma após cada avaliação |
| RN-15 | `service-requests.service.js` → `create()` | Pet deve existir e pertencer ao dono autenticado → `404`/`403` |

---

## 🐳 Infraestrutura Docker

O `docker-compose.yml` sobe todos os serviços de infraestrutura. O Kafka roda no modo **KRaft** (sem Zookeeper).

| Serviço | Imagem | Porta | Função |
|---|---|---|---|
| `plantao-pet-postgres` | `postgres:15` | `5432` | Banco de dados relacional |
| `plantao-pet-kafka` | `apache/kafka:3.7.0` | `9092` | Message broker (KRaft) |
| `plantao-pet-kafka-ui` | `provectuslabs/kafka-ui:latest` | `${KAFKA_UI_PORT}` | Interface web de administração do Kafka |
| `plantao-pet-api` | Build local (Dockerfile) | `${PORT}` | API REST + Socket.IO |

> `postgres` e `kafka` possuem healthcheck configurado. A `api` aguarda ambos estarem saudáveis antes de iniciar e executa `prisma migrate deploy` automaticamente na subida.

```bash
# Subir toda a infraestrutura
docker-compose up -d

# Verificar status dos containers
docker-compose ps

# Acompanhar logs da API
docker-compose logs -f api

# Derrubar e remover volumes
docker-compose down -v
```

---

## 🔑 Variáveis de ambiente

Crie um arquivo `.env` dentro de `backend/` com as variáveis abaixo. **Nunca versionar em produção.**

```dotenv
# ── Banco de Dados ──────────────────────────────
DATABASE_URL=postgresql://user:password@localhost:5432/plantao_pet
POSTGRES_DB=plantao_pet
POSTGRES_USER=user
POSTGRES_PASSWORD=password

# ── JWT ────────────────────────────────────────
JWT_SECRET=sua_chave_secreta_minimo_256_bits
JWT_EXPIRES_IN=7d

# ── Kafka ──────────────────────────────────────
KAFKA_BROKER=localhost:9092
KAFKA_CLUSTER_NAME=plantao-pet-cluster
KAFKA_UI_PORT=8080

# ── Servidor ───────────────────────────────────
PORT=3000
```

---

## 🚀 Instalação e execução

### Pré-requisitos

- Docker + Docker Compose
- Node.js 20+ e npm (apenas para desenvolvimento local sem Docker)

### Com Docker (recomendado)

```bash
# 1. Clone o repositório
git clone <url-do-repositorio>
cd plantao-pet-system/backend

# 2. Crie o arquivo de variáveis de ambiente
cp .env.example .env
# Edite o .env com suas configurações

# 3. Suba todos os serviços (postgres, kafka, kafka-ui, api)
docker-compose up -d

# 4. Verifique se todos os containers estão em execução
docker-compose ps

# 5. Acesse a documentação da API
# http://localhost:3000/api-docs/#/

# 6. Acesse a interface do Kafka
# http://localhost:8080
```

### Local (sem Docker)

```bash
# 1. Instale as dependências
cd backend
npm install

# 2. Configure o .env apontando para postgres e kafka locais

# 3. Execute as migrations do banco
npm run db:migrate

# 4. Inicie a aplicação em modo desenvolvimento
npm run dev
```

### Scripts disponíveis

| Script | Descrição |
|---|---|
| `npm start` | Inicia o servidor em produção |
| `npm run dev` | Inicia com nodemon (hot reload) |
| `npm run db:migrate` | Executa migrations Prisma |
| `npm run db:generate` | Regenera o Prisma Client |
| `npm run db:studio` | Abre o Prisma Studio na porta 5555 |

### Acessos após subir

| Serviço | URL |
|---|---|
| API REST | `http://localhost:3000` |
| Swagger UI | `http://localhost:3000/api-docs/#/` |
| Kafka UI | `http://localhost:8080` |
| Prisma Studio | `http://localhost:5555` (apenas local) |

---

## 🧪 Testes da API

Os endpoints estão documentados em uma coleção Postman disponível em [`docs/Plantão Pet.postman_collection.json`](docs/Plantão%20Pet.postman_collection.json).

### Como usar

1. Importe o arquivo `.json` no Postman.
2. Configure a variável de ambiente `{{baseUrl}}` com o valor `http://localhost:3000`.
3. Execute o fluxo completo na ordem sugerida pelos nomes dos requests:

```
1. Registrar Dono
2. Login Dono              → preenche {{ownerToken}} automaticamente
3. Registrar Cuidador
4. Login Cuidador          → preenche {{caregiverToken}} automaticamente
5. Cadastrar Pet
6. Criar Solicitação
7. Listar Solicitações Abertas (Cuidador)
8. Aceitar Solicitação
9. Iniciar Serviço
10. Concluir Serviço
11. Avaliar Cuidador
```

---

## 📦 Tecnologias e dependências

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
| Apps mobile | Flutter / Dart | 3.10+ |

---
<div align="center">
  <img width="70%" alt="pucminas" src="docs/images/banner-institucional.svg"/>
</div>
<p align="center">Fonte do banner: <a href="https://github.com/joaopauloaramuni">João Paulo Carneiro Aramuni</a></p>

---
