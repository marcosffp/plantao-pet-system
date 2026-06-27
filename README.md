<img width="1600" style="height:auto; border-radius: 12px;" alt="banner" src="docs/images/banner.png" />

# Plantão Pet

> Plataforma de matchmaking que conecta **donos de pets** a **cuidadores de animais**, com agendamento de serviços, comunicação assíncrona via Apache Kafka e notificações em tempo real via WebSocket.

![Node.js](https://img.shields.io/badge/Node.js-20+-6DA55F?style=for-the-badge&logo=nodedotjs&logoColor=white)
![Express](https://img.shields.io/badge/Express-4.x-404D59?style=for-the-badge&logo=express&logoColor=61DAFB)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Prisma](https://img.shields.io/badge/Prisma-5.x-5A67D8?style=for-the-badge&logo=prisma&logoColor=white)
![Apache Kafka](https://img.shields.io/badge/Apache_Kafka-3.7-E34F26?style=for-the-badge&logo=apachekafka&logoColor=white)
![Socket.IO](https://img.shields.io/badge/Socket.IO-4.x-0D7DC5?style=for-the-badge&logo=socketdotio&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-3.7+-54C5F8?style=for-the-badge&logo=flutter&logoColor=white)
![Docker](https://img.shields.io/badge/Docker_Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)

---

## Documentação

A documentação técnica completa do projeto está organizada em **[docs/README.md](docs/README.md)**, com navegação por critério de avaliação e índice de todos os documentos por sprint.

| Documento | Conteúdo |
|---|---|
| [Índice geral da documentação](docs/README.md) | Navegação por critério de avaliação (Sprint 4), índice completo por sprint, tecnologias |
| [Backend — API REST](docs/backend-api.md) | Arquitetura em camadas, todos os endpoints, modelo de dados, 15 regras de negócio, variáveis de ambiente |
| [Integração MOM — Apache Kafka](docs/Integracao_Mom.md) | 6 tópicos Kafka com payloads, diagrama de sequência, Socket.IO, deduplicação, logs reais |
| [App Mobile — Dono do Pet](docs/mobile-owner-app.md) | 10+ telas, providers, repositórios, fluxos Socket.IO com diagramas de sequência |
| [App Mobile — Cuidador](docs/mobile-caregiver-app.md) | 5 telas, providers, repositórios, listeners Socket.IO, padrões EDA + Clean Architecture |
| [Relatório Técnico Final — Sprint 4](docs/Relatório%20Técnico%20Final%20—%20Sprint%204.pdf) | Arquitetura, decisões de design, dificuldades, reflexão sobre padrões, 5 referências bibliográficas |

---

## Vídeos de apresentação

| Vídeo | Conteúdo |
|---|---|
| [Sprint 2 — Fluxo de mensageria Kafka](https://drive.google.com/file/d/12Vf2aGwrp9X9751zxPZRw6eRGAjnw2HE/view?usp=sharing) | Demonstração dos eventos publicados e consumidos pelo Kafka em tempo real |
| [Sprint 3 — Fluxo do Dono do Pet no app](https://drive.google.com/file/d/1ga2dp3g4hluzhwW6VxaMzs27TPWKo6Uh/view?usp=share_link) | Ciclo completo: cadastro de pet → solicitação → acompanhamento → avaliação |
| Sprint 4 — Screencast ponta a ponta *(link a adicionar)* | Sistema completo com dois simuladores simultâneos: Dono cria solicitação → Kafka → Cuidador recebe em tempo real → aceita → conclui |

---

## O que é o Plantão Pet?

O **Plantão Pet** resolve um problema prático: donos de pets precisam de cuidadores confiáveis para passear, visitar ou hospedar seus animais, e cuidadores precisam de uma forma organizada de encontrar e gerenciar esses serviços.

A plataforma funciona como um marketplace de serviços veterinários domiciliares. O **dono do pet** abre uma solicitação descrevendo o serviço desejado (tipo, data, endereço, qual pet), e os **cuidadores disponíveis** recebem essa solicitação em tempo real via WebSocket. O primeiro cuidador a aceitar assume o atendimento. O ciclo completo — criação, aceitação, início, conclusão e avaliação — é coordenado de forma assíncrona via Apache Kafka.

---

## Os dois perfis do sistema

| Perfil | Responsabilidades |
|---|---|
| **Dono do Pet** | Cadastra seus pets, abre solicitações de serviço, acompanha o status em tempo real, avalia o cuidador após o serviço |
| **Cuidador** | Visualiza solicitações abertas, aceita ou recusa atendimentos, gerencia a fila de serviços em andamento, controla sua disponibilidade (ATIVO/INATIVO) |

---

## Módulos do sistema

| Módulo | Tecnologia | Responsabilidade |
|---|---|---|
| `backend/` | Node.js + Express | API REST, banco de dados, mensageria Kafka e WebSocket |
| `mobile/` | Flutter (único app) | Interface do **Dono do Pet** e do **Cuidador** — o papel do usuário é determinado no cadastro/login |

---

## Arquitetura

O backend utiliza uma **arquitetura orientada a eventos (Event-Driven Architecture)**. Toda mudança de estado relevante — aceitação, início ou conclusão de um serviço — é publicada no Kafka. Um consumer dedicado consome esses eventos e os entrega via Socket.IO para os clientes Flutter conectados, sem que o código de negócio precise saber quem vai receber a mensagem.

![Arquitetura do Sistema](docs/images/Arquitetura.jpg)

**Por que Kafka?** Em vez de o backend chamar diretamente "envie uma notificação para o dono", ele publica um evento `service_request.accepted`. O consumer Kafka, completamente independente, consome esse evento, grava a notificação no banco e a envia via Socket.IO. Isso desacopla a lógica de negócio da entrega de notificações.

---

## Fluxo principal — visão geral

```mermaid
flowchart LR
    subgraph OWNER["Dono do Pet"]
        direction TB
        O1["1. Cadastra seus pets\n(espécie, raça, idade, observações)"]
        O2["2. Abre solicitação\n(pet + tipo + data/hora)"]
        O3["3. Aguarda aceite\n(notificação em tempo real)"]
        O4["4. Acompanha o progresso\naceito → em andamento → concluído"]
        O5["5. Avalia o cuidador\n(1–5 estrelas)"]
        O1 --> O2 --> O3 --> O4 --> O5
    end

    subgraph CAREGIVER["Cuidador"]
        direction TB
        C1["1. Cadastra perfil\n(bairros atendidos + serviços)"]
        C2["2. Recebe solicitações abertas\nem tempo real"]
        C3["3. Aceita ou recusa a solicitação"]
        C4["4. Inicia o serviço na data combinada"]
        C5["5. Conclui o serviço\n(dono pode avaliar)"]
        C6["6. Alterna disponibilidade\nATIVO / INATIVO"]
        C1 --> C2 --> C3 --> C4 --> C5
        C1 -.-> C6
    end

    OWNER <-->|"API REST · Kafka · Socket.IO"| CAREGIVER
```

---

## Requisitos

Antes de começar, certifique-se de ter as seguintes ferramentas instaladas:

| Ferramenta | Versão mínima | Para quê |
|---|---|---|
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | qualquer versão recente | Rodar PostgreSQL, Kafka e a API (tudo em containers) |
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | 3.7+ | Compilar e rodar o app mobile |
| Xcode + iOS Simulator | qualquer versão recente | Rodar o app em simulador iOS (macOS apenas) |

> **Você não precisa instalar Node.js, PostgreSQL ou Kafka localmente.** O backend roda inteiramente dentro do Docker.

---

## Como rodar

### 1. Clone o repositório

```bash
git clone <url-do-repositorio>
cd plantao-pet-system
```

---

### 2. Backend

#### Passo 1 — Crie o arquivo de variáveis de ambiente

```bash
cd backend
cp .env.example .env
```

Abra o arquivo `.env` gerado e ajuste os valores marcados abaixo:

```env
# ─── Banco de Dados ───────────────────────────────────────────
POSTGRES_DB=plantao_pet
POSTGRES_USER=plantao
POSTGRES_PASSWORD=troque_esta_senha        # ← troque por qualquer senha

# Use @postgres quando rodar com Docker (não altere esta linha)
DATABASE_URL=postgresql://plantao:troque_esta_senha@postgres:5432/plantao_pet
#                                ↑ deve ser igual a POSTGRES_PASSWORD acima

# ─── API ──────────────────────────────────────────────────────
JWT_SECRET=cole_o_segredo_aqui             # ← gere um segredo (veja abaixo)
JWT_EXPIRES_IN=7d
PORT=3000

# ─── Kafka ────────────────────────────────────────────────────
KAFKAJS_NO_PARTITIONER_WARNING=1
KAFKA_BROKER=kafka:29092                   # não altere ao rodar com Docker

# ─── Kafka UI ─────────────────────────────────────────────────
KAFKA_UI_PORT=8080
KAFKA_CLUSTER_NAME=plantao-pet
```

**Como gerar o `JWT_SECRET`:** execute o comando abaixo no terminal e cole o resultado no `.env`:

```bash
node -e "console.log(require('crypto').randomBytes(64).toString('base64'))"
```

#### Passo 2 — Suba os containers

```bash
docker compose up -d
```

Esse comando sobe automaticamente quatro serviços: **PostgreSQL**, **Kafka**, **Kafka UI** e a **API** (as migrations do banco são aplicadas automaticamente na primeira vez).

Na primeira execução pode levar até 60 segundos para o Kafka inicializar. Acompanhe com:

```bash
docker compose ps
```

Aguarde todos estarem com status `healthy` ou `running`:

```
NAME                       STATUS
plantao-pet-postgres       healthy
plantao-pet-kafka          healthy
plantao-pet-kafka-ui       running
plantao-pet-api            running
```

#### Passo 3 — Verifique se está funcionando

| Serviço | URL |
|---|---|
| API REST | `http://localhost:3000` |
| Documentação Swagger | `http://localhost:3000/api-docs` |
| Kafka UI (painel de mensagens) | `http://localhost:8080` |

Acesse `http://localhost:3000/api-docs` no navegador — se a página Swagger carregar, o backend está pronto.

---

### 3. App Mobile

#### Passo 1 — Crie o arquivo de variáveis de ambiente

```bash
cd mobile
cp .env.example .env
```

O `.env` do mobile tem apenas dois campos:

```env
# Endereço da API REST
BASE_URL=http://localhost:3000

# Endereço do servidor WebSocket (mesmo endereço da API)
SOCKET_URL=http://localhost:3000
```

> **iOS Simulator:** mantenha `localhost` — funciona direto.
>
> **Android Emulator:** substitua `localhost` por `10.0.2.2`:
> ```env
> BASE_URL=http://10.0.2.2:3000
> SOCKET_URL=http://10.0.2.2:3000
> ```
> O emulador Android trata `localhost` como ele mesmo, não como sua máquina. O IP `10.0.2.2` é o alias que aponta para a sua máquina host.

#### Passo 2 — Instale as dependências

```bash
flutter pub get
```

#### Passo 3 — Rode o app

```bash
flutter run --dart-define-from-file=.env
```

Se houver mais de um dispositivo conectado, o Flutter vai perguntar em qual rodar. Escolha o simulador desejado.

---

### 4. Testando o fluxo completo (dois simuladores)

O Plantão Pet tem dois perfis — Dono e Cuidador. Para testar a comunicação em tempo real entre eles, rode o app **simultaneamente em dois simuladores iOS**, cada um em um terminal separado.

#### Passo 1 — Liste os simuladores disponíveis

```bash
xcrun simctl list devices available
```

#### Passo 2 — Abra dois simuladores

**Via Terminal:**
```bash
# Inicializa o primeiro simulador
xcrun simctl boot "iPhone 17"
# Inicializa o segundo simulador
xcrun simctl boot "iPhone 17 Pro"
# Abre o app Simulator com os dois rodando
open -a Simulator
```

**Via Xcode:** Menu **Xcode → Open Developer Tool → Simulator**, depois **File → Open Simulator** para abrir o segundo.

#### Passo 3 — Confirme que o Flutter enxerga os dois

```bash
flutter devices
```

Saída esperada:
```
Found 4 connected devices:
  iPhone 17 Pro (mobile) • 2D22ACC7-4CC6-48A4-8432-010F8578099B • ios
  iPhone 17 (mobile)     • DE4CF79D-444A-4F30-9C51-FE875EB2B486 • ios
  macOS (desktop)        • macos
  Chrome (web)           • chrome
```

#### Passo 4 — Rode em terminais separados

**Terminal 1 — perfil Dono do Pet:**
```bash
cd mobile
flutter run -d "iPhone 17" --dart-define-from-file=.env
```

**Terminal 2 — perfil Cuidador:**
```bash
cd mobile
flutter run -d "iPhone 17 Pro" --dart-define-from-file=.env
```

#### O que esperar

| Simulador | Perfil | Fluxo para testar |
|---|---|---|
| iPhone 17 | Dono do Pet | Cadastrar pet → abrir solicitação → receber notificação de aceite → avaliar |
| iPhone 17 Pro | Cuidador | Receber nova solicitação em tempo real → aceitar → iniciar → concluir |

Quando o Cuidador aceitar a solicitação no iPhone 17 Pro, o Dono verá o status atualizar **automaticamente** no iPhone 17 — sem nenhuma ação manual. Esse é o fluxo Kafka → Socket.IO funcionando ponta a ponta.

---

## Estrutura do repositório

```
plantao-pet-system/
├── backend/              ← API REST, Kafka, Socket.IO, banco de dados
│   ├── src/              ← Código-fonte (routes, controllers, services, repos...)
│   ├── prisma/           ← Schema do banco e migrations
│   ├── docker-compose.yml
│   └── .env.example      ← Template de variáveis de ambiente
│
├── mobile/               ← App Flutter (Dono e Cuidador no mesmo app)
│   ├── lib/              ← Código-fonte Dart
│   └── .env.example      ← Template de URLs
│
└── docs/                 ← Documentação técnica detalhada
    ├── backend-api.md
    ├── mobile-owner-app.md
    ├── mobile-caregiver-app.md
    └── Integracao_Mom.md
```

---

<div align="center">
  <img width="70%" alt="pucminas" src="docs/images/banner-institucional.svg"/>
</div>
<p align="center">Fonte do banner: <a href="https://github.com/joaopauloaramuni">João Paulo Carneiro Aramuni</a></p>
