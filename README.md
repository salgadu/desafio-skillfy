## 📝 Descrição das Minhas Alterações

Este projeto foi desenvolvido com base nas especificações do desafio técnico, utilizando Flutter, Provider e uma arquitetura modular com princípios de separação de responsabilidades. Abaixo detalho o que foi implementado:

---

### 1. **Dashboard com visão geral das tarefas**
Implementei a tela `DashboardScreen`, que apresenta:
- **Resumo do dia** (tarefas pendentes, em progresso e concluídas).
- **Produtividade da semana**, com exibição simples de progresso dos últimos dias.
- **Próximas tarefas** organizadas por prioridade.
- **Sugestões de horários** integradas com a API `/suggest-time`.

---

### 2. **Lista de Tarefas com filtros e ordenação**
Na `TaskListScreen`, adicionei:
- Filtros por **categoria**, **prioridade** e **status** (`pending`, `in_progress`, `done`).
- Ordenação por **prazo**, **prioridade** e **título**.
- **Cards customizados** (`TaskCard`) com título, prioridade, horário sugerido e status.

---

### 3. **Formulário de Tarefa**
Tela `TaskFormScreen` com:
- Campos completos (título, descrição, categoria, prioridade, duração, prazo).
- Integração com a sugestão de horário ao preencher os dados.
- Feedback visual de **carregamento** e mensagens de **erro** em falhas de envio.

---

### 4. **Integração com a API de produtividade**
- Consumo do endpoint `/suggest-time` via `ApiService`.
- Simulação da API local usando `json-server` com o arquivo `db.json`.
- Comunicação feita com `http`, usando `dart:convert` para (de)serialização.

---

### 5. **Temas Claro e Escuro**
- Implementação completa de **modo claro e escuro** com alternância dinâmica.
- Gerenciado via `ThemeProvider` com persistência usando `shared_preferences`.
- Definição centralizada no módulo `core/ui/theme`, com:
  - `app_colors.dart`
  - `app_typography.dart`
  - `app_theme.dart`

---

### 6. **Arquitetura do Projeto**
Foi aplicada uma **mescla entre Clean Architecture e MVC modularizado**, com a seguinte estrutura:

- **`core/`**: componentes reutilizáveis e isolados da regra de negócio
  - `client/`: camadas de comunicação externa (Dio client)
  - `storage/`: persistência local (`SharedPreferences`)
  - `ui/`: definições visuais globais (temas, tipografia, cores)

- **`modules/task/`**: módulo completo responsável pelas tarefas
  - `controllers/`: lógica de controle e fluxo das telas
  - `repositories/`: abstrações e implementação para consumo de dados
  - `models/`: entidades e DTOs usados na aplicação
  - `ui/`: telas (`screens`) e widgets específicos

---

### 7. **Gerenciamento de Estado e Injeção de Dependências**
- Utilizei **Provider** para controle de estado reativo e injeção de dependências.
- `TaskProvider` gerencia as tarefas e sincroniza com os repositórios.
- `ThemeProvider` lida com o tema da aplicação e persistência do modo selecionado.

---

### 8. **Testes**
- Foram criados **testes unitários** cobrindo:
  - A lógica dos **controllers** e **models**
  - Comportamento da API (`ApiService`) com dados simulados
  - Mudanças de estado com `Provider` em diferentes cenários

---

### 9. **APK de Release**
- Gerado com `flutter build apk --release`
- Arquivo disponível na pasta `release/`

---

## 📱 Download do APK

- **APK Release**: [Download aqui](./release/app-release.apk)  
- **Versão mínima do Android**: API 21 (Android 5.0)  
- **Tamanho aproximado**: 12 MB  
- **Permissões necessárias**: Internet

### Como instalar

1. Baixe o arquivo APK.
2. No Android, vá em **Configurações > Segurança** e habilite "Fontes desconhecidas".
3. Abra o APK e siga as instruções de instalação.

---

> ✅ Este fork entrega as principais funcionalidades do desafio, com arquitetura organizada, consumo de API, temas claro/escuro, estado reativo com Provider, testes unitários e APK de release.  
> 🚀 Projeto feito com foco em clareza, organização e experiência do usuário.
