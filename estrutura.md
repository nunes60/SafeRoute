# Estrutura da pasta `lib`

A pasta `lib` e onde fica o codigo principal do app Flutter. Ela concentra a inicializacao do aplicativo, as telas, os servicos que falam com a API, os modelos de dados e os widgets reutilizaveis.

## Visao geral

```text
lib/
|- main.dart
|- core/
|- models/
|- services/
|- telas/
`- widgets/
```

## O que cada pasta significa

### `main.dart`

E a porta de entrada do app.

- Inicializa o Flutter e a formatacao de datas em `pt_BR`.
- Sobe o `SafeRouteApp`.
- Define as rotas nomeadas principais: login, inicio, lista de eventos e cadastro de evento.
- Cria o `appRouteObserver`, usado para atualizar telas quando o usuario volta de outra rota.
- Decide a primeira tela com `AppStartScreen`: se existir sessao salva, entra na home; senao, vai para o login.

### `core/`

Guarda a base compartilhada do aplicativo: configuracao, layout, estilo, tema e utilitarios.

- `app_config.dart`: centraliza a configuracao fixa do app. Hoje define a URL base da API e permite sobrescrever via `API_BASE_URL`.
- `app_layout.dart`: cria um layout responsivo reaproveitavel, com largura maxima, padding e comportamento para telas compactas, medias e largas.
- `app_styles.dart`: junta os tokens visuais do projeto, como espacamentos, breakpoints, tamanhos, bordas, paddings e duracoes.
- `app_theme.dart`: monta os temas claro e escuro do app com Material 3, cores dinamicas quando disponiveis e personalizacao de campos, botoes, cards e snackbars.
- `br_date_formatter.dart`: formata datas para o padrao brasileiro `dd/MM/yyyy`.
- `json_reader.dart`: le e valida dados JSON vindos da API, ajudando os modelos a aceitar campos obrigatorios com seguranca.

### `models/`

Fica com os modelos de dados que representam informacoes da API dentro do app.

- `auth_response.dart`: representa a resposta de login, com `userId`, `email` e `message`.
- `evento.dart`: representa um evento academico, com identificador, disciplina, descricao da atividade e data de entrega.

### `services/`

Concentra a regra de comunicacao com a API e a sessao local do usuario.

- `api_exception.dart`: excecao customizada para erros de API ou respostas invalidas.
- `api_support.dart`: funcoes auxiliares para montar URLs da API e decodificar respostas JSON, transformando falhas HTTP em `ApiException`.
- `api_service.dart`: camada HTTP de eventos. Faz listar, salvar, editar e excluir eventos na API.
- `auth_service.dart`: cuida do login. Chama a autenticacao na API e, no fluxo `signIn`, grava a sessao local.
- `event_service.dart`: camada de eventos ligada ao usuario autenticado. Busca a sessao atual e repassa as operacoes ao `ApiService`.
- `session_service.dart`: salva, recupera, valida e limpa a sessao do usuario com `SharedPreferences`.

### `telas/`

Aqui ficam as telas do aplicativo, ou seja, as paginas que o usuario realmente ve.

- `telas.dart`: arquivo de reexportacao. Serve para importar varias telas por um unico ponto.
- `tela_de_login.dart`: tela de login com formulario, validacao de e-mail e senha, tratamento de erro e redirecionamento apos autenticacao.
- `tela_inicial.dart`: tela inicial do usuario. Mostra destaques dos proximos eventos, permite abrir a lista completa, cadastrar novo evento e sair da sessao.
- `tela_de_eventos.dart`: tela com a lista completa de eventos. Tambem permite editar e excluir.
- `tela_cadastrar_evento.dart`: formulario para criar ou editar evento, com seletor de data e envio para a API.

### `widgets/`

Guarda componentes reutilizaveis que aparecem em mais de uma tela ou que merecem ficar isolados.

- `event_card.dart`: card visual de evento com titulo, data, descricao, menu de acoes e indicador de carregamento.
- `event_card.dart` tambem contem o dialogo de confirmacao `showDeleteEventDialog`, usado antes de excluir um evento.

## O que cada arquivo faz na pratica

### Entrada e navegacao

- `lib/main.dart`: inicializa o app, aplica localizacao, tema e rotas, e escolhe a tela inicial com base na sessao salva.

### Base compartilhada

- `lib/core/app_config.dart`: guarda configuracoes globais, principalmente a URL base da API.
- `lib/core/app_layout.dart`: padroniza largura, alinhamento, scroll e espacamento das telas.
- `lib/core/app_styles.dart`: define medidas e constantes visuais reaproveitadas no projeto.
- `lib/core/app_theme.dart`: define a aparencia geral do aplicativo.
- `lib/core/br_date_formatter.dart`: converte `DateTime` para texto no formato brasileiro.
- `lib/core/json_reader.dart`: protege a leitura de JSON para evitar quebrar o app com dados malformados.

### Modelos de dados

- `lib/models/auth_response.dart`: transforma o JSON de login em um objeto Dart.
- `lib/models/evento.dart`: transforma o JSON de evento em um objeto Dart.

### Servicos e dados

- `lib/services/api_exception.dart`: representa erros que o app entende e pode exibir ao usuario.
- `lib/services/api_support.dart`: oferece utilitarios comuns para todas as chamadas HTTP.
- `lib/services/api_service.dart`: conversa diretamente com os endpoints de eventos.
- `lib/services/auth_service.dart`: conversa com o endpoint de autenticacao e abre sessao.
- `lib/services/event_service.dart`: evita repetir `usuarioId` nas telas, porque usa a sessao atual automaticamente.
- `lib/services/session_service.dart`: gerencia persistencia local do usuario logado.

### Telas

- `lib/telas/telas.dart`: simplifica imports das telas.
- `lib/telas/tela_de_login.dart`: controla o acesso do usuario ao app.
- `lib/telas/tela_inicial.dart`: mostra um resumo rapido e atalhos principais.
- `lib/telas/tela_de_eventos.dart`: mostra todos os eventos cadastrados.
- `lib/telas/tela_cadastrar_evento.dart`: cria ou atualiza eventos.

### Widget reutilizavel

- `lib/widgets/event_card.dart`: encapsula o visual e as acoes de um evento em um card reaproveitavel.

## Fluxo resumido do app

1. `main.dart` inicia o aplicativo.
2. `AppStartScreen` verifica se existe sessao salva em `SessionService`.
3. Se houver sessao, o usuario vai para `tela_inicial.dart`; se nao houver, vai para `tela_de_login.dart`.
4. As telas usam `AuthService` e `EventService` para executar a regra de negocio.
5. Os servicos usam `ApiService` para falar com a API.
6. Os dados recebidos sao convertidos em objetos pelos arquivos de `models/`.
7. Os componentes visuais reaproveitaveis ficam em `widgets/`, e a base de layout/tema fica em `core/`.

## Em resumo

Se pensar a `lib` por responsabilidade:

- `main.dart`: inicio e navegacao.
- `core/`: infraestrutura visual e utilitarios.
- `models/`: formato dos dados.
- `services/`: regras de acesso a API e sessao.
- `telas/`: paginas do app.
- `widgets/`: pecas visuais reutilizaveis.