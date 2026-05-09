# Plantão Pet

O **Plantão Pet** é uma plataforma de matchmaking entre donos de pets e cuidadores de animais, projetada para facilitar o agendamento de serviços como passeios e visitas domiciliaares.

## Arquitetura do Sistema

A arquitetura do sistema adota uma abordagem moderna orientada a eventos (Event-Driven Architecture), com forte separação de responsabilidades. O back-end provê a API, persistência e mensageria assíncrona, enquanto clientes móveis consomem esses serviços.

![Diagrama de Arquitetura](docs/images/Arquitetura.jpg)

### Principais Componentes:
- **Apps Cliente (Flutter):** Temos dois aplicativos nativos em Flutter, um para o **Dono (Owner)** do pet e outro para o **Cuidador (Caregiver)**. Eles se comunicam com a API via HTTP (REST) e recebem eventos assíncronos em tempo real via WebSocket.
- **Node.js (Backend):** A lógica central da aplicação segue a Clean Architecture com camadas bem definidas: Middlewares, Rotas, Controllers, Services e Repositories.
- **Banco de Dados (PostgreSQL):** Banco de dados relacional para persistência estruturada das informações. A manipulação de dados é gerida pelo Prisma ORM.
- **Mensageria (Apache Kafka):** O Kafka é usado para orquestrar os eventos da plataforma de maneira assíncrona, desacoplando os produtores de eventos dos consumidores.
- **WebSocket:** Gerencia conexões persistentes para notificação em tempo real dos aplicativos conectados caso haja mudança no status dos serviços.

---

## Modelo de Dados (Database Schema)

Os dados são armazenados de forma relacional utilizando **PostgreSQL**. O diagrama abaixo ilustra o mapeamento lógico e os relacionamentos do banco de dados:

![Modelo do Banco de Dados](docs/images/Diagrama_Entidades_Banco_Dados.png)

### Entidades e Referências:

1. **Owner (Dono):** Registra informações do cliente como nome, endereço e e-mail. Relaciona-se (1:N) aos seus **Pets** e aos seus **ServiceRequests** (pedidos de serviço) solicitados.
2. **Pet:** Os mascotes pertencentes aos donos de pets, guardando espécies, raças, idades e notas especiais. Cada Pet pertence a um Dono (N:1).
3. **Caregiver (Cuidador):** Registra cuidadores, suas especialidades (serviços ofertados), bairros de atuação e contagem média de notas (*averageRating*). Atendem os serviços.
4. **ServiceRequest (Solicitação de Serviço):** É a transação-alvo do sistema. Relaciona o Dono, o Cuidador e o Pet para um `serviceType` num agendamento futuro (`scheduledAt`). Armazena os diversos ciclos de vida com o campo `status` e validade temporal `expiresAt`.
5. **Review (Avaliação):** Após a conclusão de um Serviço, um Dono avalia o Cuidador. Registra `rating` numérico e comentários, influenciando o perfil do cuidador.
6. **Notification:** Mantém o histórico completo de persistência de notificações despachadas no sistema, registrando que evento ocorreu, seu payload, bem como quando foi lida.

---

## Testes da API

Os endpoints da API foram documentados e organizados em uma coleção do Postman. Você pode importar a coleção para o Postman e realizar testes diretamente.

O arquivo da coleção está disponível em: [Plantão Pet.postman_collection.json](docs/Plantão%20Pet.postman_collection.json)

### Como usar a coleção:
1. Importe o arquivo `.json` no Postman.
2. Configure a variável de ambiente `{{baseUrl}}` com o valor `http://localhost:3000`.
3. Utilize os exemplos de requisição e resposta para testar os endpoints da API.

A coleção inclui exemplos de fluxos completos, como:
- Registro e login de usuários (Dono e Cuidador).
- Cadastro de pets e solicitações de serviço.
- Aceitação, início e conclusão de serviços por cuidadores.
- Avaliação de cuidadores pelos donos.

Certifique-se de que o backend esteja em execução antes de realizar os testes.

## Como Rodar a Aplicação com Docker

Para rodar a aplicação utilizando Docker, siga os passos abaixo:

1. Certifique-se de que o Docker e o Docker Compose estão instalados em sua máquina.
2. No terminal, navegue até o diretório `backend` do projeto:
   ```bash
   cd backend
   ```
3. Execute o comando para iniciar os containers em segundo plano:
   ```bash
   docker-compose up -d
   ```
4. Após a execução do comando, verifique se os containers foram criados e estão em execução:
   ```bash
   docker ps
   ```
   Certifique-se de que os containers necessários estão listados e em execução.
5. Acesse a aplicação no navegador através do seguinte endereço:
   [http://localhost:3000/api-docs/#/](http://localhost:3000/api-docs/#/)

Pronto! A aplicação estará rodando e você poderá acessar a documentação da API no link acima.
