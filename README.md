## 📝 Descrição das Minhas Alterações

Este projeto foi desenvolvido com base nas especificações do desafio técnico, utilizando **Flutter**, **Provider** e uma arquitetura modular com princípios de separação de responsabilidades. Abaixo detalho o que foi implementado:

-----

### 1\. **Dashboard com Visão Geral das Tarefas**

Implementei a tela `DashboardScreen`, que apresenta:

  * **Resumo do dia:** tarefas pendentes, em progresso e concluídas.
  * **Produtividade da semana:** exibição simples do progresso dos últimos dias.
  * **Próximas tarefas:** organizadas por prioridade.
  * **Sugestões de horários:** integradas com a API `/suggest-time`.

-----

### 2\. **Lista de Tarefas com Filtros e Ordenação**

Na `TaskListScreen`, adicionei:

  * Filtros por **categoria**, **prioridade** e **status**.
  * Ordenação por **prazo**, **prioridade** e **título**.
  * **Cards customizados** (`TaskCard`) com título, prioridade, horário sugerido e status.

-----

### 3\. **Formulário de Tarefa**

A tela `TaskFormScreen` possui:

  * Campos completos (título, descrição, categoria, prioridade, duração, prazo).
  * Integração com a sugestão de horário ao preencher os dados.

-----

### 4\. **Integração com a API de Produtividade**

  * Consumo dos endpoints `/tasks` e `/suggest-time` via `ApiService`.
  * Simulação da API local usando `json-server` com o arquivo `db.json`.
  * Comunicação realizada com `http`, utilizando **Dio** como client.

-----

### 5\. **Temas Claro e Escuro**

  * Implementação completa de **modo claro e escuro** com alternância dinâmica.
  * Gerenciamento via `themeController` com persistência utilizando `shared_preferences`.
  * Definição centralizada no módulo `core/ui/theme`, com:
      * `app_colors.dart`
      * `app_typography.dart`
      * `app_theme.dart`

-----

### 6\. **Arquitetura do Projeto**

Foi aplicada uma **MVC modularizada**, com a seguinte estrutura:

  * **`core/`**: componentes reutilizáveis e isolados da regra de negócio

      * `client/`: camadas de comunicação externa (Dio client)
      * `storage/`: persistência local (`SharedPreferences`)
      * `ui/`: definições visuais globais (temas, tipografia, cores)

  * **`modules/task/`**: módulo completo responsável pelas tarefas

      * `controllers/`: lógica de controle e fluxo das telas
      * `repositories/`: abstrações e implementação para consumo de dados
      * `models/`: entidades e DTOs usados na aplicação
      * `ui/`: telas (`screens`) e widgets específicos

-----

### 7\. **Gerenciamento de Estado e Injeção de Dependências**

  * Utilizei **Provider** e `ChangeNotifier` para controle de estado reativo e injeção de dependências.
  * `TaskController` gerencia as tarefas e sincroniza com os repositórios.
  * `ThemeController` lida com o tema da aplicação e persistência do modo selecionado.

-----

### 8\. **Testes**

Foram criados **testes unitários** cobrindo:

  * A lógica dos **controllers** e **models**.
  * Comportamento da API (`ApiService`) com dados simulados.

-----

### 9\. **APK de Release**

  * Gerado com `flutter build apk --release`.
  * Arquivo disponível na pasta `release/`.

-----

## 📱 Download do APK

  * **APK Release**: [Download aqui](https://www.google.com/search?q=./release/app-release.apk)
  * **Versão mínima do Android**: API 21 (Android 5.0)
  * **Permissões necessárias**: Internet

-----

### Como instalar

1.  Baixe o arquivo APK.
2.  No Android, vá em **Configurações \> Segurança** e habilite "Fontes desconhecidas".
3.  Abra o APK e siga as instruções de instalação.

-----

> ✅ Este fork entrega as principais funcionalidades do desafio, com arquitetura organizada, consumo de API, temas claro/escuro, estado reativo com Provider, testes unitários e APK de release.
> 🚀 Projeto feito com foco em clareza, organização e experiência do usuário.