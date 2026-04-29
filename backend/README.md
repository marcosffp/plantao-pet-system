# Plantão Pet — Backend API

Sistema de matchmaking entre donos de pets e cuidadores de animais.

**Disciplina:** Laboratório de Desenvolvimento de Aplicações Móveis e Distribuídas  
**Instituição:** PUC Minas — 1º Semestre 2026

---

## Arquitetura do Sistema

```mermaid
graph TB
    subgraph "Apps Flutter"
        OA["📱 App Dono\n(Flutter/Dart)\nPorta N/A"]
        CA["📱 App Cuidador\n(Flutter/Dart)\nPorta N/A"]
    end

    subgraph "Backend"
        API["⚙️ API REST\n(Node.js + Express)\nPorta 3000"]
        CRON["⏰ Cron Job\n(node-cron)\nExpira Solicitações"]
    end

    subgraph "Mensageria (MOM)"
        KAFKA["📨 Apache Kafka\nPorta 9092"]
        ZK["🔧 Zookeeper\nPorta 2181"]
    end

    subgraph "Persistência"
        PG[("🗄️ PostgreSQL 15\nPorta 5432")]
    end

    OA -->|"HTTP/REST\nJSON"| API
    CA -->|"HTTP/REST\nJSON"| API
    OA -->|"Polling HTTP\na cada 5s"| API
    CA -->|"Polling HTTP\na cada 5s"| API

    API -->|"Prisma ORM\nTCP"| PG
    API -->|"kafkajs\nProduz Eventos"| KAFKA
    KAFKA -->|"kafkajs\nConsome Eventos"| API
    KAFKA <-->|"Coordenação\nTCP"| ZK

    CRON -->|"Prisma ORM"| PG
    CRON -->|"Produz evento\nservice_request.expired"| KAFKA
```

### Protocolos de Comunicação

| Conexão | Protocolo | Formato | Direção |
|---|---|---|---|
| App Flutter → Backend | HTTP 1.1 / REST | JSON | Síncrono |
| App Flutter → Backend (polling) | HTTP GET | JSON | Síncrono periódico (5s) |
| Backend → PostgreSQL | TCP (Prisma ORM) | SQL | Síncrono |
| Backend → Kafka (producer) | TCP (kafkajs) | JSON | Assíncrono |
| Kafka → Backend (consumer) | TCP (kafkajs) | JSON | Assíncrono |
| Cron Job → PostgreSQL | TCP (Prisma ORM) | SQL | Agendado (1h) |

---

## Schema do Banco de Dados

Banco: **PostgreSQL 15** | ORM: **Prisma 5.x**

### Entidades e Relações

```
Owner (1) ──────── (N) Pet
Owner (1) ──────── (N) ServiceRequest
Owner (1) ──────── (N) Review
Caregiver (1) ──── (N) ServiceRequest
Caregiver (1) ──── (N) Review
Pet (1) ─────────── (N) ServiceRequest
ServiceRequest (1) ─ (1) Review
```

### Enums

| Enum | Valores |
|---|---|
| Species | DOG, CAT, OTHER |
| ServiceType | WALK_30MIN, WALK_1H, HOME_VISIT, HOSTING |
| RequestStatus | OPEN, ACCEPTED, IN_PROGRESS, COMPLETED, CANCELLED, REFUSED |
| CaregiverStatus | ACTIVE, INACTIVE |

### Fluxo de Status da Solicitação

```
OPEN → ACCEPTED → IN_PROGRESS → COMPLETED
  ↓ (dono cancela)    ↓ (cuidador recusa → volta para OPEN)
CANCELLED
```

---

## Como Executar o Projeto

### Pré-requisitos
- Docker e Docker Compose instalados
- Node.js 20+ (apenas para desenvolvimento local)

### Subir com Docker Compose (recomendado)

```bash
# 1. Clonar o repositório
git clone <url-do-repositorio>
cd plantao-pet-backend

# 2. Copiar variáveis de ambiente
cp .env.example .env

# 3. Subir todos os serviços
docker compose up -d

# 4. Aguardar Kafka e Postgres iniciarem (~30 segundos) e aplicar migrations
docker compose exec api npx prisma migrate deploy

# 5. Acessar a API
curl http://localhost:3000/caregivers
```

### Serviços disponíveis após o docker compose up

| Serviço | URL | Descrição |
|---|---|---|
| API REST | http://localhost:3000 | Backend principal |
| Swagger | http://localhost:3000/api-docs | Documentação interativa |
| PostgreSQL | localhost:5432 | Banco de dados |
| Kafka | localhost:9092 | Message broker |

### Variáveis de Ambiente (.env)

```env
DATABASE_URL=postgresql://plantao:plantao123@postgres:5432/plantao_pet
JWT_SECRET=plantao_pet_jwt_secret_2026
JWT_EXPIRES_IN=7d
KAFKA_BROKER=kafka:9092
PORT=3000
```

### Desenvolvimento Local (sem Docker)

```bash
npm install
cp .env.example .env
# Editar .env com configurações locais do PostgreSQL e Kafka
npx prisma migrate dev
npm run dev
```

---

## Endpoints da API

### Auth
| Método | Rota | Autenticação | Descrição |
|---|---|---|---|
| POST | /auth/owner/register | Público | Cadastrar dono |
| POST | /auth/owner/login | Público | Login do dono |
| POST | /auth/caregiver/register | Público | Cadastrar cuidador |
| POST | /auth/caregiver/login | Público | Login do cuidador |

### Owners
| Método | Rota | Autenticação | Descrição |
|---|---|---|---|
| GET | /owners/:id | JWT | Buscar dono por ID |

### Pets
| Método | Rota | Autenticação | Descrição |
|---|---|---|---|
| POST | /owners/:ownerId/pets | JWT (dono) | Cadastrar pet |
| GET | /owners/:ownerId/pets | JWT | Listar pets do dono |
| GET | /pets/:id | JWT | Buscar pet por ID |

### Caregivers
| Método | Rota | Autenticação | Descrição |
|---|---|---|---|
| GET | /caregivers | Público | Listar cuidadores ativos |
| GET | /caregivers/:id | Público | Buscar cuidador por ID |
| PATCH | /caregivers/:id/status | JWT (cuidador) | Atualizar status |
| GET | /caregivers/:id/reviews | Público | Listar avaliações |

### ServiceRequests
| Método | Rota | Autenticação | Descrição |
|---|---|---|---|
| POST | /service-requests | JWT (dono) | Criar solicitação |
| GET | /service-requests | JWT (cuidador) | Listar solicitações abertas |
| GET | /service-requests/my | JWT | Minhas solicitações |
| GET | /service-requests/:id | JWT | Buscar por ID |
| PATCH | /service-requests/:id/accept | JWT (cuidador) | Aceitar solicitação |
| PATCH | /service-requests/:id/refuse | JWT (cuidador) | Recusar solicitação |
| PATCH | /service-requests/:id/cancel | JWT (dono) | Cancelar solicitação |
| PATCH | /service-requests/:id/start | JWT (cuidador) | Iniciar serviço |
| PATCH | /service-requests/:id/complete | JWT (cuidador) | Concluir serviço |

### Reviews
| Método | Rota | Autenticação | Descrição |
|---|---|---|---|
| POST | /reviews | JWT (dono) | Criar avaliação |

---

## Stack Tecnológica

| Componente | Tecnologia |
|---|---|
| Runtime | Node.js 20+ |
| Framework | Express 4.x |
| ORM | Prisma 5.x |
| Banco de Dados | PostgreSQL 15 |
| Message Broker | Apache Kafka (kafkajs 2.x) |
| Autenticação | JWT (jsonwebtoken + bcryptjs) |
| Validação | Zod |
| Documentação | Swagger (swagger-ui-express) |
| Agendamento | node-cron |
| Containerização | Docker + Docker Compose |

### Por que Apache Kafka como MOM?

O enunciado aceita "RabbitMQ, Redis Pub/Sub ou solução equivalente documentada". O Kafka foi escolhido porque:

- Implementa nativamente o padrão **Publish/Subscribe** descrito em Hohpe & Woolf (2003)
- **Persistência de mensagens** por padrão — permite reprocessamento de eventos
- Amplamente utilizado em produção (LinkedIn, Uber, Airbnb) — alinhado com Richardson (2018)
- A biblioteca **kafkajs** integra facilmente com Node.js com suporte nativo a async/await
- Suporte a **EDA (Event-Driven Architecture)** sem acoplamento direto entre produtores e consumidores

---

## Eventos Kafka

| Tópico | Produtor | Payload |
|---|---|---|
| service_request.created | service-requests.service.js | { requestId, serviceType, scheduledAt, petName, meetingAddress } |
| service_request.accepted | service-requests.service.js | { requestId, caregiverName, caregiverPhone, ownerId } |
| service_request.refused | service-requests.service.js | { requestId, caregiverId, refusedAt } |
| service_request.in_progress | service-requests.service.js | { requestId, startedAt, ownerId } |
| service.completed | service-requests.service.js | { requestId, completedAt, caregiverId, ownerId } |
| service_request.expired | expire-requests.job.js | { requestId, expiredAt } |
| review.created | reviews.service.js | { caregiverId, newRating, averageRating } |

---

## Referências Bibliográficas

HOHPE, Gregor; WOOLF, Bobby. *Enterprise Integration Patterns*. Boston: Addison-Wesley, 2003.  
RICHARDSON, Chris. *Microservices Patterns*. Shelter Island: Manning, 2018.  
MARTIN, Robert C. *Arquitetura Limpa*. Rio de Janeiro: Alta Books, 2019.
