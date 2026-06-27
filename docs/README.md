# Documentação — Plantão Pet

> Índice de navegação do projeto · **Lab. de Desenvolvimento de Aplicações Móveis e Distribuídas** — PUC Minas, 1º Semestre 2026
> Aluno: **Marcos Alberto** · Entrega final: 03/07/2026

---

## Documentos

| Arquivo | Sprint | Conteúdo |
|---|---|---|
| [backend-api.md](backend-api.md) | 1 | Arquitetura em camadas, todos os endpoints REST, modelo de dados, 15 regras de negócio, variáveis de ambiente, infraestrutura Docker |
| [integracao_Mom.md](integracao_Mom.md) | 2 | Configuração do Kafka (KRaft), 6 tópicos com payloads JSON, diagrama de sequência, Socket.IO, deduplicação, logs reais |
| [mobile-owner-app.md](mobile-owner-app.md) | 3–4 | 11+ telas do Dono do Pet, explorar cuidadores, providers, repositórios, fluxos Socket.IO com diagramas de sequência |
| [mobile-caregiver-app.md](mobile-caregiver-app.md) | 3–4 | 5 telas do Cuidador, cancelamento em tempo real, navegação por notificação, Clean Architecture + EDA |
| [Relatório Técnico Final – Sprint 4 – Plantão Pet-3.pdf](Relatório%20Técnico%20Final%20–%20Sprint%204%20–%20Plantão%20Pet-3.pdf) | 4 | Relatório técnico (13 páginas): arquitetura, decisões de design, dificuldades, referências |
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

## Capturas de tela — app real

Arquivos em [`images/telas/`](images/telas/):

| Arquivo | Tela |
|---|---|
| [login_dono.png](images/telas/login_dono.png) | Login — Dono do Pet |
| [login_cuidador.png](images/telas/login_cuidador.png) | Login — Cuidador |
| [cadastro_dono.png](images/telas/cadastro_dono.png) | Cadastro — Dono do Pet |
| [cadastro_cuidador.png](images/telas/cadastro_cuidador.png) | Cadastro — Cuidador |
| [home_dono.png](images/telas/home_dono.png) | Início (Home) — Dono do Pet |
| [criar_solicitacao.png](images/telas/criar_solicitacao.png) | Criar Solicitação |
| [criacao_solicitacao.png](images/telas/criacao_solicitacao.png) | Criação de Solicitação (fluxo) |
| [detalhes_solicitacao.png](images/telas/detalhes_solicitacao.png) | Detalhe da Solicitação — Dono |
| [detalhes_solicitacao_cuidador.png](images/telas/detalhes_solicitacao_cuidador.png) | Detalhe da Solicitação — Cuidador |
| [detalhe_acao.png](images/telas/detalhe_acao.png) | Detalhe com ações contextuais — Cuidador |
| [avaliacao.png](images/telas/avaliacao.png) | Avaliar Cuidador |
| [pets.png](images/telas/pets.png) | Meus Pets |
| [cadastrar_pet.png](images/telas/cadastrar_pet.png) | Cadastrar Pet |
| [editar_excluir_pet.png](images/telas/editar_excluir_pet.png) | Editar / Excluir Pet |
| [explorar_cuidadores.png](images/telas/explorar_cuidadores.png) | Explorar Cuidadores |
| [lista_solicitacoes.png](images/telas/lista_solicitacoes.png) | Lista de Solicitações — Cuidador |
| [meus_atendimentos.png](images/telas/meus_atendimentos.png) | Meus Atendimentos — Cuidador |
| [acompanhamento.png](images/telas/acompanhamento.png) | Acompanhamento do Serviço |
| [notificacoes_dono.png](images/telas/notificacoes_dono.png) | Alertas / Notificações — Dono |
| [notificacoes_cuidador.png](images/telas/notificacoes_cuidador.png) | Alertas / Notificações — Cuidador |
| [tela_perfil_dono.png](images/telas/tela_perfil_dono.png) | Perfil — Dono do Pet |
| [tela_perfil_cuidador.png](images/telas/tela_perfil_cuidador.png) | Perfil — Cuidador |

---

## Diagramas e evidências

Arquivos em [`images/`](images/):

| Arquivo | Conteúdo |
|---|---|
| [Arquitetura.jpg](images/Arquitetura.jpg) | Diagrama de arquitetura do sistema |
| [Diagrama_Entidades_Banco_Dados.png](images/Diagrama_Entidades_Banco_Dados.png) | Diagrama entidade-relacionamento do banco |
| [service_request_created.png](images/service_request_created.png) | Kafka UI — evento `service_request.created` |
| [service_request_accepted.png](images/service_request_accepted.png) | Kafka UI — evento `service_request.accepted` |
| [service_request_refused.png](images/service_request_refused.png) | Kafka UI — evento `service_request.refused` |
| [service_request_in_progress.png](images/service_request_in_progress.png) | Kafka UI — evento `service_request.in_progress` |
| [service_request_cancelled.png](images/service_request_cancelled.png) | Kafka UI — evento `service_request.cancelled` |
| [service_completed.png](images/service_completed.png) | Kafka UI — evento `service.completed` |
| [review_created.png](images/review_created.png) | Kafka UI — evento `review.created` |

---

→ Instruções de execução no [README principal](../README.md)
