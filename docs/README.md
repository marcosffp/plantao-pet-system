# Documentação — Plantão Pet

> Índice de navegação do projeto · **Lab. de Desenvolvimento de Aplicações Móveis e Distribuídas** — PUC Minas, 1º Semestre 2026
> Aluno: **Marcos Alberto** · Entrega final: 03/07/2026

---

## Documentos

| Arquivo | Sprint | Conteúdo |
|---|---|---|
| [backend-api.md](backend-api.md) | 1 | Arquitetura em camadas, todos os endpoints REST, modelo de dados, 15 regras de negócio, variáveis de ambiente, infraestrutura Docker |
| [Integracao_Mom.md](Integracao_Mom.md) | 2 | Configuração do Kafka (KRaft), 6 tópicos com payloads JSON, diagrama de sequência, Socket.IO, deduplicação, logs reais |
| [mobile-owner-app.md](mobile-owner-app.md) | 3 | 10+ telas do Dono do Pet, providers, repositórios, fluxos Socket.IO com diagramas de sequência |
| [mobile-caregiver-app.md](mobile-caregiver-app.md) | 4 | 5 telas do Cuidador, providers, repositórios, listeners Socket.IO, Clean Architecture + EDA |
| [Relatório Técnico Final — Sprint 4.pdf](Relatório%20Técnico%20Final%20—%20Sprint%204.pdf) | 4 | Relatório técnico (13 páginas): arquitetura, decisões de design, dificuldades, referências |
| [Proposta.pdf](Proposta.pdf) | 1 | Domínio escolhido, perfis de usuário, justificativa |
| [Plantão Pet.postman_collection.json](Plantão%20Pet.postman_collection.json) | 1 | Coleção com todos os endpoints documentados e exemplos de request/response |

---

## Protótipos

Arquivos em [`prototype/`](prototype/):

| Arquivo | Tela |
|---|---|
| [login.png](prototype/login.png) | Tela de login |
| [pets.png](prototype/pets.png) | Lista de pets |
| [create.png](prototype/create.png) | Criação de solicitação (formulário) |
| [create_service_request.png](prototype/create_service_request.png) | Criação de solicitação (fluxo) |
| [get_service_request.png](prototype/get_service_request.png) | Detalhes da solicitação |
| [service_request.png](prototype/service_request.png) | Lista de solicitações |

---

## Imagens e diagramas

Arquivos em [`images/`](images/):

| Arquivo | Conteúdo |
|---|---|
| [Arquitetura.jpg](images/Arquitetura.jpg) | Diagrama de arquitetura do sistema |
| [Diagrama_Entidades_Banco_Dados.png](images/Diagrama_Entidades_Banco_Dados.png) | Diagrama entidade-relacionamento do banco |
| [service_request_created.png](images/service_request_created.png) | Kafka UI — evento `service_request.created` |
| [service_request_accepted.png](images/service_request_accepted.png) | Kafka UI — evento `service_request.accepted` |
| [service_request_refused.png](images/service_request_refused.png) | Kafka UI — evento `service_request.refused` |
| [service_request_in_progress.png](images/service_request_in_progress.png) | Kafka UI — evento `service_request.in_progress` |
| [service_completed.png](images/service_completed.png) | Kafka UI — evento `service.completed` |
| [review_created.png](images/review_created.png) | Kafka UI — evento `review.created` |
| [service_request_cancelled.png](images/service_request_cancelled.png) | Kafka UI — evento `service_request.cancelled` |

---

→ Instruções de execução no [README principal](../README.md)
