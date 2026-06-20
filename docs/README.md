# Documentação Técnica — Plantão Pet

> Índice de navegação para o projeto integrador da disciplina **Lab. de Desenvolvimento de Aplicações Móveis e Distribuídas** — PUC Minas, 1º Semestre 2026.
>
> Aluno: **Marcos Alberto** · Entrega final: 03/07/2026

---

## Navegação por critério de avaliação — Sprint 4

Use esta seção para ir diretamente ao trecho da documentação que cobre cada critério da rubrica.

### Critério 1 — Funcionalidade do app do prestador (25%)

O aplicativo Flutter do **Cuidador** entrega 4 telas principais (mínimo exigido: 3):

| Tela | Descrição |
|---|---|
| Lista de solicitações abertas | Solicitações `OPEN` disponíveis para aceitar, atualizadas em tempo real |
| Detalhe + ações | Aceitar / Recusar (status `OPEN`), Iniciar (status `ACCEPTED`), Concluir (status `IN_PROGRESS`) |
| Meus atendimentos | Histórico de atendimentos aceitos com filtros por status |
| Perfil + disponibilidade | Dados do cuidador, média de avaliações, toggle ATIVO/INATIVO |

→ **Documentação completa:** [App Mobile — Cuidador](mobile-caregiver-app.md)

---

### Critério 2 — Fluxo completo de ponta a ponta (30%)

Fluxo exigido: *cliente cria solicitação → MOM → prestador notificado → aceita → cliente notificado*

O sistema implementa este fluxo com 6 tópicos Kafka cobrindo todo o ciclo de vida:

```
OPEN → ACCEPTED → IN_PROGRESS → COMPLETED → REVIEW
  ↑        ↑           ↑            ↑          ↑
Kafka    Kafka        Kafka        Kafka      Kafka
```

→ **Diagrama de sequência completo:** [Relatório Técnico Final — seção 6](Relatório%20Técnico%20Final%20—%20Sprint%204.pdf)  
→ **Eventos, payloads e logs de execução:** [Integração MOM — Fluxo ponta a ponta](integracao_Mom.md#fluxo-completo-ponta-a-ponta)

---

### Critério 3 — Notificação assíncrona ao prestador via MOM (20%)

Notificação de novas solicitações ao Cuidador ocorre **sem polling**, via:

```
Dono → POST /service-requests
  → Backend publica service_request.created no Kafka
    → NotificationConsumer persiste notificação no banco
      → Emite Socket.IO new_request
        → ServiceRequestProvider.loadOpen(token)
          → Card aparece na tela do Cuidador sem nenhuma ação manual
```

→ **Arquitetura assíncrona completa:** [Integração MOM — Visão geral](integracao_Mom.md#visão-geral-da-arquitetura-assíncrona)  
→ **Implementação no app:** [App Cuidador — Serviço de Socket.IO](mobile-caregiver-app.md#serviço-de-socketio--tempo-real)  
→ **Desacoplamento producer/consumer:** [Integração MOM — Desafios](integracao_Mom.md#desafios-de-implementação)

---

### Critério 4 — Screencast de demonstração (10%)

Vídeo de 3–5 minutos com dois simuladores iOS rodando simultaneamente (Dono e Cuidador), demonstrando o fluxo completo sem nenhuma atualização manual de tela.

| Vídeo | Link |
|---|---|
| Sprint 2 — Mensageria Kafka | [Assistir](https://drive.google.com/file/d/12Vf2aGwrp9X9751zxPZRw6eRGAjnw2HE/view?usp=sharing) |
| Sprint 3 — App do Dono do Pet | [Assistir](https://drive.google.com/file/d/1ga2dp3g4hluzhwW6VxaMzs27TPWKo6Uh/view?usp=share_link) |
| **Sprint 4 — Sistema completo ponta a ponta** | *(link a adicionar)* |

---

### Critério 5 — Relatório técnico final (15%)

O relatório cobre todos os tópicos exigidos (EDA, MOM, Clean Architecture, REST) com mínimo 4 páginas e 3 referências bibliográficas da ementa.

| Requisito | Entregue |
|---|---|
| Mínimo 4 páginas | 13 páginas |
| Arquitetura implementada | Seção 2 — diagrama de componentes |
| Decisões de design | Seção 8 — 5 decisões documentadas |
| Dificuldades e soluções | Seção 9 — 4 problemas com solução |
| Reflexão EDA / MOM / Clean Architecture / REST | Seção 10 — 4 subseções |
| Mínimo 3 referências | 5 referências (Martin, Hohpe & Woolf, Richardson, Coulouris, Bailey) |

→ **Relatório em PDF:** [Relatório Técnico Final — Sprint 4](Relatório%20Técnico%20Final%20—%20Sprint%204.pdf)  
→ **Versão web (HTML):** [relatorio-sprint4.html](relatorio-sprint4.html)

---

## Índice completo de documentos

### Sprint 1 — Proposta + Backend REST

| Documento | Conteúdo |
|---|---|
| [Proposta.pdf](Proposta.pdf) | Domínio escolhido, perfis de usuário, justificativa |
| [backend-api.md](backend-api.md) | Arquitetura em camadas, todos os endpoints REST, modelo de dados, 15 regras de negócio, variáveis de ambiente, infraestrutura Docker |
| [Plantão Pet.postman_collection.json](Plantão%20Pet.postman_collection.json) | Coleção Postman/Insomnia com todos os endpoints documentados e exemplos de requisição e resposta |

### Sprint 2 — Integração MOM (Apache Kafka)

| Documento | Conteúdo |
|---|---|
| [integracao_Mom.md](integracao_Mom.md) | Configuração do Kafka (KRaft), 6 tópicos com payloads JSON de exemplo, diagrama de sequência, integração Socket.IO, persistência e deduplicação de notificações, logs reais de execução |

### Sprint 3 — App Flutter do Cliente (Dono do Pet)

| Documento | Conteúdo |
|---|---|
| [mobile-owner-app.md](mobile-owner-app.md) | Arquitetura Clean Architecture, 10+ telas (home, pets, cuidadores, solicitações, avaliação, notificações, perfil), todos os providers e repositórios, fluxos Socket.IO com diagramas de sequência |

### Sprint 4 — App Flutter do Prestador + Integração Final

| Documento | Conteúdo |
|---|---|
| [mobile-caregiver-app.md](mobile-caregiver-app.md) | Arquitetura Clean Architecture + EDA, 5 telas do Cuidador, providers, repositórios, listeners Socket.IO, padrões arquiteturais aplicados |
| [Relatório Técnico Final — Sprint 4.pdf](Relatório%20Técnico%20Final%20—%20Sprint%204.pdf) | Relatório técnico completo (13 páginas): arquitetura, decisões de design, dificuldades, reflexão sobre padrões, referências |

---

## Estrutura da pasta `docs/`

```
docs/
├── README.md                              ← este arquivo (índice de navegação)
├── backend-api.md                         ← Sprint 1: documentação da API REST
├── integracao_Mom.md                      ← Sprint 2: integração Kafka + Socket.IO
├── mobile-owner-app.md                    ← Sprint 3: app Flutter do Dono
├── mobile-caregiver-app.md               ← Sprint 4: app Flutter do Cuidador
├── Relatório Técnico Final — Sprint 4.pdf ← Sprint 4: relatório técnico (PDF)
├── relatorio-sprint4.html                 ← Sprint 4: relatório técnico (web)
├── Proposta.pdf                           ← Sprint 1: proposta de domínio
├── Plantão Pet.postman_collection.json    ← Sprint 1: coleção de testes
├── prototype/                             ← protótipos de telas
└── images/                               ← imagens e diagramas
```

---

## Tecnologias do sistema

| Camada | Tecnologia | Versão |
|---|---|---|
| App móvel | Flutter / Dart | 3.7+ |
| Backend | Node.js + Express | 20+ / 4.x |
| Banco de dados | PostgreSQL + Prisma ORM | 15 / 5.x |
| MOM | Apache Kafka (KRaft, sem Zookeeper) | 3.7.0 |
| WebSocket | Socket.IO | 4.x |
| Autenticação | JWT (jsonwebtoken) | 9.x |
| Containerização | Docker Compose | — |

→ Instruções de execução completas no [README principal](../README.md)
