# Proposta de Domínio — Plantão Pet

**Disciplina:** Laboratório de Desenvolvimento de Aplicações Móveis e Distribuídas  
**Aluno:** Marcos Ferreira Albernaz  
**Matrícula:** [SUA MATRÍCULA]  
**Data:** 29/04/2026  
**Sprint:** 1

---

## 1. Descrição do Domínio

A **Plataforma Plantão Pet** é um sistema de matchmaking que conecta donos de animais
domésticos a cuidadores profissionais para a contratação de serviços como passeios,
visitas domiciliares e hospedagem temporária.

O problema resolvido é a dificuldade enfrentada por donos de pets ao precisar de cuidados
para seus animais em situações de ausência (viagens, trabalho, emergências), sem ter
acesso fácil a profissionais confiáveis e disponíveis na sua região.

---

## 2. Perfis de Usuário

### Cliente — Dono do Pet
O Dono é o usuário que cadastra seus animais na plataforma e abre solicitações de serviço.
Suas principais ações são: cadastrar pets, abrir solicitações, acompanhar o status do
atendimento em tempo real e avaliar o cuidador ao final do serviço.

### Prestador de Serviços — Cuidador
O Cuidador é o profissional que oferece serviços de cuidado animal. Suas principais ações
são: manter seu perfil ativo, visualizar solicitações abertas na sua região, aceitar ou
recusar solicitações, iniciar o atendimento e marcá-lo como concluído.

---

## 3. Principais Funcionalidades

### Funcionalidades do Dono (Cliente)
- Cadastro e autenticação
- Cadastro de pets com espécie, raça, idade e observações especiais
- Abertura de solicitações de serviço (passeio 30min/1h, visita domiciliar, hospedagem)
- Acompanhamento do status da solicitação em tempo real
- Cancelamento de solicitações abertas
- Avaliação do cuidador após conclusão do serviço

### Funcionalidades do Cuidador (Prestador)
- Cadastro e autenticação
- Configuração de bairros atendidos e tipos de serviço oferecidos
- Visualização de solicitações abertas disponíveis
- Aceite ou recusa de solicitações
- Atualização do status (iniciar serviço, concluir serviço)
- Visualização do histórico de atendimentos e avaliações recebidas

---

## 4. Tipos de Serviço

| Tipo | Descrição | Duração |
|---|---|---|
| Passeio 30min | Passeio com o pet em área próxima | 30 minutos |
| Passeio 1h | Passeio com o pet em área próxima | 1 hora |
| Visita domiciliar | Cuidador vai até a casa do dono | Algumas horas |
| Hospedagem | Pet fica na casa do cuidador | Dias |

---

## 5. Fluxo Principal de Uso

1. Dono cadastra conta e seus pets
2. Dono abre uma solicitação especificando pet, tipo de serviço, data/hora e endereço
3. Sistema notifica cuidadores disponíveis via evento assíncrono (Kafka)
4. Cuidador visualiza a solicitação e aceita ou recusa
5. Cuidador inicia o atendimento e atualiza o status
6. Ao concluir, dono é notificado e pode avaliar o cuidador

---

## 6. Justificativa Tecnológica

### Por que Node.js + Express?
Framework minimalista que expõe com clareza a estrutura REST, amplamente utilizado
em sistemas distribuídos de produção e com vasto ecossistema de bibliotecas.

### Por que Apache Kafka como MOM?
O Apache Kafka foi escolhido como solução equivalente ao RabbitMQ/Redis Pub/Sub
pelos seguintes motivos, conforme justificativa detalhada no relatório técnico:
- Implementa nativamente o padrão Publish/Subscribe descrito em Hohpe & Woolf (2003)
- Persistência de mensagens por padrão, permitindo reprocessamento de eventos
- Alinhado com os padrões de EDA descritos em Richardson (2018)
- Amplamente adotado em sistemas distribuídos de produção

### Por que PostgreSQL + Prisma?
PostgreSQL oferece robustez relacional para o domínio estruturado da plataforma.
O Prisma ORM gera o schema de forma declarativa, facilita migrations e documenta
o modelo de dados automaticamente.

---

## 7. Referências

HOHPE, Gregor; WOOLF, Bobby. *Enterprise Integration Patterns*. Boston: Addison-Wesley, 2003.  
RICHARDSON, Chris. *Microservices Patterns*. Shelter Island: Manning, 2018.  
MARTIN, Robert C. *Arquitetura Limpa*. Rio de Janeiro: Alta Books, 2019.
