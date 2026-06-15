# SafeRoute

## 1. Abertura da apresentacao

### 1.1. Saudacao e contextualizacao

Bom dia/boa tarde. Nesta apresentacao, vamos explicar o projeto **SafeRoute**, um aplicativo mobile desenvolvido em Flutter para auxiliar na organizacao de compromissos, tarefas e eventos academicos.

O foco do sistema e oferecer uma experiencia simples: o usuario faz login, visualiza seus eventos, cadastra novos compromissos, edita informacoes quando necessario e exclui eventos que ja nao fazem sentido manter.

Mesmo sendo um projeto com objetivo direto, a estrutura do codigo foi organizada de forma a separar responsabilidades. Isso facilita a manutencao, a leitura, os testes e futuras expansoes do aplicativo.

### 1.2. Ideia central do projeto

O SafeRoute funciona como uma agenda academica orientada a eventos. Cada evento possui:

- um identificador;
- o nome ou titulo da disciplina/evento;
- uma descricao da atividade;
- uma data de entrega.

A aplicacao tambem possui autenticacao. Isso significa que os eventos nao sao tratados como dados soltos: eles sao vinculados a um usuario logado. Essa decisao aparece claramente no codigo, porque a camada de eventos sempre busca a sessao atual antes de chamar a API.

### 1.3. O que sera apresentado

Neste roteiro, a apresentacao pode seguir a seguinte ordem:

1. Visao geral da arquitetura.
2. Dependencias e tecnologias usadas.
3. Inicializacao do aplicativo.
4. Organizacao da pasta `lib`.
5. Camada `core`: configuracoes, tema, layout, estilos, datas e leitura de JSON.
6. Camada `models`: representacao dos dados principais.
7. Camada `services`: comunicacao com API, autenticacao, eventos e sessao local.
8. Camada `telas`: login, inicio, lista de eventos e cadastro/edicao.
9. Camada `widgets`: componentes reutilizaveis.
10. Fluxos principais do usuario.
11. Tratamento de erros, estados de carregamento e validacoes.
12. Responsividade e experiencia visual.
13. Pontos fortes do projeto.
14. Possibilidades de extensao futura.
15. Conclusao.

## 2. Visao geral tecnica do SafeRoute

### 2.1. Tecnologia principal

O projeto foi desenvolvido com **Flutter**, usando a linguagem **Dart**. Flutter permite criar aplicativos multiplataforma a partir de uma unica base de codigo. Neste projeto, a estrutura inclui suporte para Android, Web e Windows, mas a pasta `lib` concentra a logica principal compartilhada entre essas plataformas.

### 2.2. Padrao geral de organizacao

A pasta `lib` esta dividida em cinco partes principais:

- `main.dart`: ponto de entrada da aplicacao.
- `core`: configuracoes e utilitarios centrais.
- `models`: classes que representam os dados do dominio.
- `services`: servicos responsaveis por API, autenticacao, eventos e sessao.
- `telas`: telas completas da aplicacao.
- `widgets`: componentes visuais reutilizaveis.

Essa divisao ajuda a responder uma pergunta importante durante a apresentacao: **onde fica cada responsabilidade?**

- O que e visual fica em `telas` e `widgets`.
- O que e regra de comunicacao fica em `services`.
- O que e estrutura dos dados fica em `models`.
- O que e configuracao, layout e padronizacao fica em `core`.
- O que inicializa o aplicativo fica em `main.dart`.

### 2.3. Arquitetura em camadas

O projeto nao mistura tudo dentro de uma unica tela. Existe uma arquitetura simples em camadas:

1. **Interface do usuario**: telas e widgets.
2. **Servicos de aplicacao**: classes que executam acoes como login, salvar evento, listar eventos e encerrar sessao.
3. **Comunicacao HTTP**: montagem de URI, envio de requisicoes e decodificacao de respostas.
4. **Modelos**: transformam JSON em objetos Dart tipados.
5. **Core**: apoio transversal usado por varias partes do app.

Essa arquitetura permite explicar que o aplicativo nao apenas mostra telas; ele possui um fluxo bem definido de dados entre usuario, app, armazenamento local e servidor.

## 3. Dependencias e recursos externos

Embora o pedido esteja baseado nos arquivos de `lib`, e importante comentar as dependencias que aparecem no codigo:

- `flutter/material.dart`: base dos componentes visuais Material Design.
- `flutter_localizations`: suporte a localizacao brasileira, usado para datas e textos padrao do sistema.
- `dynamic_color`: permite usar cores dinamicas do sistema, especialmente em dispositivos Android mais recentes.
- `intl`: usado para formatacao de datas no padrao brasileiro.
- `http`: responsavel pelas chamadas HTTP para a API.
- `shared_preferences`: usado para salvar localmente dados simples da sessao.

Essas dependencias mostram que o projeto nao e apenas uma tela estatica. Ele conversa com servidor, persiste sessao, adapta tema e trabalha com localizacao.

## 4. Ponto de entrada: `lib/main.dart`

### 4.1. Papel do arquivo

O arquivo `main.dart` e o ponto inicial do aplicativo. Ele prepara dependencias globais e chama `runApp`, que inicia a interface Flutter.

Esse arquivo tambem define rotas nomeadas, configura tema, localizacao, navegacao global e decide qual tela deve aparecer primeiro.

### 4.2. Funcao `main`

A funcao principal e declarada como `Future<void> main() async`, porque antes de abrir o app ela precisa executar uma operacao assincrona: inicializar dados de formatacao de data para o locale `pt_BR`.

Dentro dela, temos dois passos importantes:

1. `WidgetsFlutterBinding.ensureInitialized()`: garante que o Flutter esteja pronto antes de executar operacoes assincronas ou acessar recursos da plataforma.
2. `initializeDateFormatting('pt_BR')`: carrega os simbolos de data em portugues do Brasil, usados pelo pacote `intl`.

Depois disso, `runApp(const SafeRouteApp())` inicia o aplicativo.

### 4.3. Rotas nomeadas

O arquivo define constantes para as principais rotas:

- `loginRoute = '/login'`
- `homeRoute = '/home'`
- `eventsRoute = '/events'`
- `createEventRoute = '/create-event'`

Essas constantes evitam espalhar strings soltas pelo codigo. Se uma rota precisar mudar, basta alterar em um ponto central.

Durante a apresentacao, e interessante destacar que isso reduz erros de digitacao e melhora a manutencao.

### 4.4. `RouteObserver`

O arquivo cria `appRouteObserver`, um observador de rotas. Ele permite que algumas telas saibam quando o usuario saiu para outra tela e voltou.

Isso e usado principalmente em telas que listam eventos. Quando o usuario cadastra ou edita um evento e retorna, a tela pode recarregar os dados automaticamente.

Essa escolha melhora a experiencia porque o usuario nao precisa fechar e abrir a tela para ver atualizacoes.

### 4.5. Classe `SafeRouteApp`

`SafeRouteApp` e um `StatelessWidget` que monta o `MaterialApp` principal.

Pontos importantes:

- usa `DynamicColorBuilder` para aplicar cores dinamicas quando disponiveis;
- remove a faixa de debug com `debugShowCheckedModeBanner: false`;
- fixa o locale em `pt_BR`;
- registra os delegates de localizacao do Material;
- aplica tema claro e escuro por meio de `AppTheme`;
- usa `ThemeMode.system`, respeitando o tema do dispositivo;
- define a tela inicial como `AppStartScreen`;
- registra as rotas nomeadas.

Essa classe representa o centro de configuracao visual e de navegacao do app.

### 4.6. Classe `AppStartScreen`

`AppStartScreen` decide se o usuario deve ver a tela inicial ou a tela de login.

Ela usa `FutureBuilder<bool>` com `SessionService.hasSession()`.

O fluxo e:

1. Enquanto verifica a sessao, mostra um `CircularProgressIndicator`.
2. Se existir sessao salva, abre `WelcomeScreen`.
3. Se nao existir sessao, abre `LoginPage`.

Esse ponto mostra que o app tem persistencia de sessao: o usuario nao precisa logar novamente toda vez que abrir o aplicativo, desde que a sessao local ainda exista.

## 5. Pasta `core`: base compartilhada do aplicativo

A pasta `core` contem recursos usados por varias partes do sistema. Ela evita repeticao e centraliza decisoes importantes.

Arquivos da pasta:

- `app_config.dart`
- `app_layout.dart`
- `app_styles.dart`
- `app_theme.dart`
- `br_date_formatter.dart`
- `json_reader.dart`

## 6. `lib/core/app_config.dart`

### 6.1. Responsabilidade

`AppConfig` centraliza configuracoes estaticas do aplicativo. Atualmente, a configuracao principal e a URL base da API.

### 6.2. `apiBaseUrl`

A propriedade `apiBaseUrl` e definida com `String.fromEnvironment`.

Isso permite passar uma URL diferente durante a compilacao usando `--dart-define=API_BASE_URL=...`.

Se nenhuma URL for passada, o app usa o valor padrao:

`https://saferoute-production-726a.up.railway.app`

### 6.3. Por que isso e importante

Essa abordagem facilita separar ambientes:

- ambiente local de desenvolvimento;
- ambiente de testes;
- ambiente de producao.

Em uma apresentacao, esse arquivo mostra preocupacao com configuracao por ambiente e evita deixar URLs espalhadas no codigo.

## 7. `lib/core/app_styles.dart`

### 7.1. Responsabilidade

`AppStyles` concentra medidas, espacamentos, tamanhos, raios de borda e constantes visuais.

Ele funciona como um pequeno sistema de design do app.

### 7.2. Breakpoints responsivos

O arquivo define pontos de quebra para adaptar o layout:

- `tabletBreakpoint = 720`
- `desktopBreakpoint = 1024`
- `splitLayoutBreakpoint = 760`
- `actionWrapBreakpoint = 560`

Esses valores sao usados para decidir quando o conteudo deve ficar mais largo, quando cards podem ser exibidos em duas colunas e quando botoes podem ficar lado a lado.

### 7.3. Larguras maximas

O arquivo tambem define larguras maximas para formularios, conteudo e listas:

- `contentMaxWidth`
- `contentMaxWidthMedium`
- `contentMaxWidthWide`
- `formMaxWidthWide`
- `listMaxWidthMedium`
- `listMaxWidthWide`

Isso impede que o conteudo fique largo demais em telas grandes, preservando legibilidade.

### 7.4. Tokens visuais

Entre os valores centralizados estao:

- raio de campos (`inputRadius`);
- raio de botoes (`buttonRadius`);
- espessura da borda focada (`focusedBorderWidth`);
- tamanho do indicador de carregamento (`busyIndicatorSize`);
- espacamento entre itens (`itemSpacing`);
- espacamento entre acoes (`actionSpacing`);
- tamanhos de icones;
- tamanhos de titulos e subtitulos.

Isso ajuda a manter unidade visual.

### 7.5. Espacamentos prontos

O arquivo cria `SizedBox` constantes como:

- `gap8`
- `gap16`
- `gap24`
- `gap32`

Esses gaps sao reutilizados nas telas para evitar numeros magicos e manter consistencia.

### 7.6. Importancia para extensibilidade

Se futuramente o grupo quiser alterar o espacamento geral, tamanho de botoes ou comportamento responsivo, varias mudancas podem ser feitas nesse unico arquivo.

Isso torna o app mais facil de evoluir.

## 8. `lib/core/app_layout.dart`

### 8.1. Responsabilidade

`AppLayout` e um componente reutilizavel que aplica largura maxima, padding e responsividade ao conteudo das telas.

Em vez de cada tela decidir sozinha seus limites e espacamentos, elas usam esse wrapper.

### 8.2. Enum `AppLayoutWidth`

O enum possui tres presets:

- `form`: usado em formularios mais estreitos, como login.
- `content`: usado em conteudos gerais, como a tela inicial.
- `list`: usado em listas de eventos, permitindo area mais ampla.

Esse enum torna o codigo mais expressivo. Em vez de passar numeros, a tela declara a intencao de layout.

### 8.3. Metodos utilitarios

O arquivo possui metodos estaticos importantes:

- `isCompact(context)`: verifica se a tela e compacta.
- `isWide(context)`: verifica se a tela e ampla.
- `pagePadding(context)`: calcula o padding com base no tamanho atual.
- `pagePaddingForWidth(width)`: calcula padding para uma largura informada.
- `maxWidthFor(width, preset)`: retorna a largura maxima de acordo com o preset.
- `eventColumnsForWidth(width)`: decide se os cards ficam em uma ou duas colunas.

### 8.4. Construcao do layout

No `build`, o componente usa `LayoutBuilder` para saber a largura disponivel.

Depois calcula:

- `viewportWidth`: largura real da area;
- `resolvedPadding`: padding final;
- `resolvedMaxWidth`: largura maxima final.

Em seguida, o filho e envolvido por:

- `Align`: para alinhar o conteudo;
- `ConstrainedBox`: para aplicar limite de largura;
- `Padding` ou `SingleChildScrollView`, dependendo de `scrollable`.

### 8.5. Vantagem pratica

As telas ficam mais limpas porque nao precisam repetir logica de responsividade. Basta escrever:

`AppLayout(width: AppLayoutWidth.content, scrollable: true, child: ...)`

Isso e uma boa decisao de organizacao de codigo.

## 9. `lib/core/app_theme.dart`

### 9.1. Responsabilidade

`AppTheme` centraliza a identidade visual do aplicativo.

Ele cria os temas claro e escuro e aplica configuracoes padronizadas para varios componentes do Material Design.

### 9.2. Cores base

O tema usa duas cores-semente:

- `_lightSeedColor = Color(0xFF00639A)`
- `_darkSeedColor = Color(0xFF7CCBFF)`

Essas cores sao usadas quando nao ha paleta dinamica disponivel.

### 9.3. Tema claro e escuro

Os metodos principais sao:

- `light([ColorScheme? dynamicColorScheme])`
- `dark([ColorScheme? dynamicColorScheme])`

Se o dispositivo fornecer cores dinamicas, elas sao usadas. Caso contrario, o app cria um `ColorScheme.fromSeed`.

### 9.4. Material 3

Dentro de `_buildTheme`, o app usa `ThemeData(useMaterial3: true)`. Isso mostra que o projeto adota o Material Design 3, com componentes modernos e integracao melhor com o sistema.

### 9.5. Tipografia

O tema ajusta estilos de texto:

- `headlineMedium`: usado em titulos principais, com tamanho e peso definidos em `AppStyles`.
- `titleMedium`: usado em subtitulos.
- `titleLarge`: usado em titulos de cards/listas.

### 9.6. Campos de formulario

`InputDecorationTheme` padroniza campos:

- campos preenchidos;
- cor de fundo baseada no `ColorScheme`;
- bordas arredondadas;
- borda diferente quando focado;
- borda de erro.

Isso afeta login e cadastro de eventos.

### 9.7. Botoes

O tema configura:

- `FilledButtonThemeData`
- `OutlinedButtonThemeData`

Ambos usam:

- tamanho minimo;
- padding padrao;
- raio de borda padronizado.

Assim, botoes de telas diferentes continuam visualmente coerentes.

### 9.8. Snackbars, Cards e ListTiles

O arquivo tambem personaliza:

- `SnackBarThemeData`: snackbars flutuantes, com cor e borda arredondada.
- `CardThemeData`: cards sem elevacao exagerada, com clipping e cor do esquema.
- `ListTileThemeData`: padding e estilo de titulo.

### 9.9. Mensagem para a apresentacao

Ao apresentar esse arquivo, podemos dizer que ele evita que cada tela tenha sua propria configuracao visual. A identidade do app fica centralizada.

## 10. `lib/core/br_date_formatter.dart`

### 10.1. Responsabilidade

`BrDateFormatter` padroniza a exibicao de datas no formato brasileiro.

### 10.2. Formato usado

Ele usa `DateFormat('dd/MM/yyyy', 'pt_BR')`.

O metodo `formatShort(DateTime date)` converte um `DateTime` para algo como:

`14/06/2026`

### 10.3. Onde aparece

Esse formatador e usado nas telas que mostram eventos e no formulario de cadastro/edicao.

Por exemplo, um evento com data de entrega aparece como:

`AtÃ© 14/06/2026`

### 10.4. Importancia

Centralizar o formato evita inconsistencias como uma tela mostrar `2026-06-14` e outra mostrar `14/06/2026`.

## 11. `lib/core/json_reader.dart`

### 11.1. Responsabilidade

`JsonReader` e um utilitario para ler e validar campos vindos da API.

Esse arquivo e muito importante porque a API retorna dados dinamicos, mas o app precisa trabalhar com dados confiaveis.

### 11.2. `requiredInt`

Le um inteiro obrigatorio.

Ele aceita uma lista de chaves alternativas. Isso e util quando a API pode retornar nomes diferentes para o mesmo campo.

Exemplo no projeto: o id do evento pode vir como `evento_id`, `id_evento` ou `id`.

O metodo tambem tenta converter strings numericas em `int`.

### 11.3. `requiredNonEmptyString`

Le uma string obrigatoria e verifica se nao esta vazia.

Ele aplica `trim`, removendo espacos no inicio e no fim.

Se o campo estiver ausente ou vazio, lanca `FormatException`.

### 11.4. `requiredDate`

Le uma data obrigatoria e tenta converter com `DateTime.tryParse`.

Se a data estiver invalida, tambem lanca `FormatException`.

### 11.5. `requiredObject`

Le um objeto JSON obrigatorio e normaliza para `Map<String, dynamic>`.

Isso e usado em respostas de autenticacao, onde os dados do usuario aparecem dentro de um objeto `usuario`.

### 11.6. `_firstValue`

Metodo privado que percorre uma lista de chaves e retorna o primeiro valor nao nulo encontrado.

Isso melhora a compatibilidade com respostas diferentes da API.

### 11.7. Importancia na apresentacao

Esse arquivo demonstra cuidado com robustez. Em vez de presumir que a API sempre retorna dados perfeitos, o app valida os campos e transforma falhas em erros controlados.

## 12. Pasta `models`: representacao dos dados

A pasta `models` contem classes que representam entidades importantes do app.

Arquivos:

- `auth_response.dart`
- `evento.dart`

Esses arquivos transformam JSON em objetos Dart, dando tipo, clareza e seguranca para o restante do codigo.

## 13. `lib/models/auth_response.dart`

### 13.1. Responsabilidade

`AuthResponse` representa os dados de autenticacao que o aplicativo realmente usa apos um login bem-sucedido.

### 13.2. Campos

A classe possui:

- `userId`: identificador do usuario.
- `email`: e-mail do usuario autenticado.
- `message`: mensagem retornada pela API ou mensagem padrao.

### 13.3. Construtor constante

O construtor e `const`, o que permite criar instancias imutaveis quando todos os dados forem conhecidos.

### 13.4. Factory `fromJson`

O factory recebe `Map<String, dynamic>` e extrai o objeto `usuario`.

Depois usa `JsonReader` para validar:

- `usuario.id`
- `usuario.email`

A mensagem vem de `data['mensagem']`, com fallback para:

`Login realizado com sucesso.`

### 13.5. Papel no fluxo

Quando o login ocorre, `AuthService` recebe a resposta da API, converte para `AuthResponse` e depois salva `userId` e `email` na sessao local.

Esse model e a ponte entre a resposta bruta do servidor e o uso seguro dentro do app.

## 14. `lib/models/evento.dart`

### 14.1. Responsabilidade

`Evento` representa um compromisso/tarefa academica exibida e manipulada pelo aplicativo.

### 14.2. Campos

A classe possui:

- `id`: identificador unico do evento.
- `nomeDisciplina`: titulo ou disciplina relacionada.
- `descricaoAtividade`: descricao do que precisa ser feito.
- `dataEntrega`: prazo do evento como `DateTime`.

### 14.3. Factory `fromJson`

O factory usa `JsonReader` para validar o payload vindo da API.

Ele aceita ids com chaves alternativas:

- `evento_id`
- `id_evento`
- `id`

E exige os campos:

- `nome_disciplina`
- `descricao_atividade`
- `data_entrega`

### 14.4. Importancia

Esse model evita que as telas trabalhem diretamente com mapas JSON. Em vez disso, elas recebem objetos `Evento`, com propriedades claras e tipadas.

### 14.5. Relacao com as telas

`Evento` aparece em:

- tela inicial, para destaques;
- tela de lista completa;
- tela de cadastro, quando esta em modo de edicao;
- card de evento, indiretamente por meio dos dados exibidos.

## 15. Pasta `services`: regras de acesso a dados, API e sessao

A pasta `services` contem a parte responsavel por operacoes externas e persistencia local.

Arquivos:

- `api_exception.dart`
- `api_support.dart`
- `api_service.dart`
- `auth_service.dart`
- `event_service.dart`
- `session_service.dart`

Essa camada evita que as telas facam chamadas HTTP diretamente.

## 16. `lib/services/api_exception.dart`

### 16.1. Responsabilidade

`ApiException` representa erros relacionados a API ou a interpretacao das respostas.

### 16.2. Campos

A classe possui:

- `message`: mensagem amigavel ou explicativa.
- `statusCode`: codigo HTTP opcional.

### 16.3. Metodo `toString`

O `toString` retorna uma descricao com codigo HTTP e mensagem.

Isso ajuda em depuracao, porque permite ver o erro completo quando ele e impresso.

### 16.4. Por que criar uma excecao propria

Ter uma excecao especifica permite diferenciar erros de API de outros erros inesperados.

Nas telas, isso aparece em blocos como:

- `on ApiException catch (e)`: mostra mensagem vinda da API.
- `catch (_)`: mostra mensagem generica.

Isso melhora o tratamento de erros para o usuario.

## 17. `lib/services/api_support.dart`

### 17.1. Responsabilidade

Esse arquivo contem funcoes auxiliares para comunicacao HTTP.

Ele nao representa uma tela nem uma entidade do dominio. Ele ajuda a montar URLs e interpretar respostas.

### 17.2. `buildApiUri`

`buildApiUri(String path, [Map<String, String>? queryParameters])` monta a URI final da API.

Ela usa `AppConfig.apiBaseUrl` como base e adiciona:

- caminho do endpoint;
- parametros de query, quando existirem.

Essa funcao preserva protocolo, host e parte base da URL.

### 17.3. Exemplo de uso

Ao listar eventos, o app chama algo como:

`buildApiUri('/listar_eventos', query)`

O resultado e uma URL completa com `usuario_id` e, se necessario, `limit`.

### 17.4. `decodeApiResponse`

Essa funcao recebe `http.Response` e tenta decodificar o corpo como JSON.

Se o corpo nao for JSON valido, ela lanca `ApiException` com mensagem:

`Resposta invalida do servidor.`

Se o status HTTP for maior ou igual a 400, ela tambem lanca `ApiException`, tentando usar a mensagem retornada pela API.

### 17.5. Importancia

Essa funcao evita repeticao. Todos os servicos HTTP podem usar a mesma regra para:

- decodificar JSON;
- tratar resposta invalida;
- tratar erro HTTP;
- extrair mensagem da API.

## 18. `lib/services/api_service.dart`

### 18.1. Responsabilidade

`ApiService` executa chamadas HTTP relacionadas aos eventos.

Ele e a camada mais proxima da API para cadastro, listagem, edicao e exclusao.

### 18.2. Cliente HTTP injetavel

O construtor aceita `http.Client? client`.

Se nenhum cliente for passado, cria `http.Client()`.

Essa escolha facilita testes, porque e possivel passar um cliente falso/mockado.

### 18.3. Metodo `listarEventos`

Responsavel por buscar eventos do usuario autenticado.

Parametros:

- `usuarioId`: obrigatorio.
- `limit`: opcional.

O metodo monta query parameters:

- `usuario_id`
- `limit`, quando informado.

Depois envia uma requisicao `GET` para `/listar_eventos`.

### 18.4. Validacao da listagem

Depois da chamada, usa `decodeApiResponse`.

Em seguida verifica se `data['status']` e `sucesso`.

Se nao for, lanca `ApiException` com mensagem apropriada.

Se for sucesso, pega a lista `eventos` e converte cada item em `Evento.fromJson`.

### 18.5. Tratamento de formato invalido

Se algum item da lista nao puder ser convertido corretamente, o metodo captura `FormatException` e transforma em `ApiException`.

Isso impede que um erro tecnico de parsing chegue cru ate a interface.

### 18.6. Metodo `salvarEvento`

Envia um novo evento para a API usando `POST` em `/salvar_evento`.

O corpo JSON contem:

- `usuario_id`
- `nome_disciplina`
- `descricao_atividade`
- `data_entrega`

Depois valida o status da resposta e retorna o id do evento criado.

### 18.7. Metodo `editarEvento`

Atualiza um evento existente com `POST` em `/editar_evento`.

O corpo JSON contem:

- `evento_id`
- `usuario_id`
- `nome_disciplina`
- `descricao_atividade`
- `data_entrega`

Essa funcao e usada quando a tela de cadastro abre em modo de edicao.

### 18.8. Metodo `excluirEvento`

Solicita exclusao de um evento com `POST` em `/excluir_evento`.

O corpo JSON contem:

- `evento_id`
- `usuario_id`

Retorna o id do evento excluido, quando a API fornece.

### 18.9. Metodos privados

`_parseInt` converte valores dinamicos para inteiro.

`_parseEventoId` tenta obter o id a partir de `evento_id`, `id_evento` ou `id`.

`_asStringDynamicMap` garante que cada item dinamico da lista possa ser tratado como `Map<String, dynamic>`.

### 18.10. Mensagem para a apresentacao

Esse arquivo representa a comunicacao direta com o servidor. Ele conhece endpoints, corpo das requisicoes e formato das respostas.

## 19. `lib/services/auth_service.dart`

### 19.1. Responsabilidade

`AuthService` centraliza a autenticacao remota e a abertura da sessao local.

Ele conversa com a API de autenticacao e, se tudo der certo, salva os dados do usuario.

### 19.2. Cliente HTTP injetavel

Assim como `ApiService`, aceita `http.Client? client` no construtor.

Isso facilita testes de login sem depender da API real.

### 19.3. Metodo `login`

O metodo `login` recebe:

- `email`
- `senha`

Ele envia uma requisicao `POST` para `/auth` com corpo JSON:

- `email`
- `senha`
- `acao: login`

Depois usa `decodeApiResponse` para validar a resposta.

### 19.4. Validacao do status

Se `data['status']` nao for `sucesso`, o metodo lanca `ApiException` com mensagem vinda da API ou mensagem padrao.

Se for sucesso, tenta criar `AuthResponse.fromJson(data)`.

### 19.5. Metodo `signIn`

`signIn` chama `login` e, apos receber `AuthResponse`, salva a sessao com `SessionService.saveUserSession`.

Ele salva:

- `userId`
- `email`

### 19.6. Diferenca entre `login` e `signIn`

Essa diferenca e importante:

- `login` apenas autentica e retorna os dados.
- `signIn` autentica e tambem persiste a sessao.

Na tela de login, o app usa `signIn`, porque a intencao e realmente entrar no sistema.

## 20. `lib/services/session_service.dart`

### 20.1. Responsabilidade

`SessionService` cuida da sessao local do usuario usando `SharedPreferences`.

Ele permite salvar, consultar e limpar os dados minimos da sessao.

### 20.2. Classe `SessionData`

`SessionData` agrupa:

- `userId`
- `email`

Essa classe evita retornar varios valores soltos.

### 20.3. Chaves internas

O servico usa duas chaves privadas:

- `_userIdKey = 'usuario_id'`
- `_userEmailKey = 'usuario_email'`

Essas chaves identificam onde os dados ficam salvos no armazenamento local.

### 20.4. `saveUserSession`

Salva os dados do usuario autenticado.

Usa:

- `prefs.setInt` para o id;
- `prefs.setString` para o email.

O email e salvo com `trim`, removendo espacos desnecessarios.

### 20.5. `getUserId` e `getUserEmail`

Esses metodos retornam apenas partes da sessao.

Internamente, eles chamam `getCurrentSession`.

### 20.6. `getCurrentSession`

Carrega a sessao completa e valida se ela e realmente utilizavel.

Regras:

- `userId` precisa existir;
- `userId` precisa ser maior que zero;
- `email` nao pode estar vazio.

Se algo estiver invalido, retorna `null`.

### 20.7. `hasSession`

Retorna `true` se existir uma sessao completa.

Esse metodo e usado na inicializacao do app para decidir se mostra login ou home.

### 20.8. `clearSession`

Remove os dados locais da sessao.

Esse metodo e usado no logout da tela inicial.

### 20.9. Importancia

Esse arquivo da continuidade ao uso do app. Sem ele, o usuario precisaria fazer login sempre que abrisse o aplicativo.

## 21. `lib/services/event_service.dart`

### 21.1. Responsabilidade

`EventService` e uma camada intermediaria entre telas e `ApiService`.

Ele expÃµe operacoes de eventos ja vinculadas ao usuario em sessao.

### 21.2. Por que ele existe

As telas nao deveriam ter que buscar `usuario_id` manualmente toda vez.

`EventService` resolve isso: antes de listar, salvar, editar ou excluir, ele chama `_requireSession`.

### 21.3. Injetabilidade

O construtor aceita `ApiService? apiService`.

Se nenhum for passado, cria um `ApiService` padrao.

Isso facilita testes e manutencao.

### 21.4. `listEventos`

Lista eventos do usuario atual.

Pode receber `limit`, usado na tela inicial para carregar apenas os destaques.

### 21.5. `salvarEvento`

Cria um evento usando o usuario da sessao atual.

Recebe:

- nome da disciplina;
- descricao da atividade;
- data de entrega.

Depois repassa para `ApiService.salvarEvento` com `usuarioId`.

### 21.6. `editarEvento`

Atualiza um evento existente do usuario autenticado.

Recebe o `eventoId` e os novos dados.

### 21.7. `excluirEvento`

Exclui um evento do usuario autenticado.

Retorna o id excluido.

### 21.8. `_requireSession`

Metodo privado que garante que existe sessao antes de acessar a API.

Se nao houver sessao, lanca:

`SessÃ£o nÃ£o encontrada. FaÃ§a login novamente.`

### 21.9. Importancia arquitetural

Esse servico protege a regra de que evento pertence a usuario logado.

Ele tambem deixa as telas mais simples, porque elas chamam apenas `listEventos`, `salvarEvento`, `editarEvento` ou `excluirEvento`.

## 22. Pasta `telas`: interfaces completas

A pasta `telas` contem as telas principais do app.

Arquivos:

- `telas.dart`
- `tela_de_login.dart`
- `tela_inicial.dart`
- `tela_de_eventos.dart`
- `tela_cadastrar_evento.dart`

Essas telas representam os fluxos que o usuario realmente percorre.

## 23. `lib/telas/telas.dart`

### 23.1. Responsabilidade

Esse arquivo reexporta as telas principais.

Ele contem:

- `export 'tela_de_login.dart';`
- `export 'tela_inicial.dart';`
- `export 'tela_de_eventos.dart';`
- `export 'tela_cadastrar_evento.dart';`

### 23.2. Vantagem

No `main.dart`, em vez de importar cada tela separadamente, o codigo importa apenas `telas.dart`.

Isso simplifica os imports e organiza melhor a entrada do app.

## 24. `lib/telas/tela_de_login.dart`

### 24.1. Responsabilidade

`LoginPage` exibe o formulario de autenticacao do usuario.

Essa tela valida email e senha, chama `AuthService.signIn`, trata erros e navega para a home quando o login e concluido.

### 24.2. Tipo de widget

`LoginPage` e um `StatefulWidget`, porque precisa controlar estados como:

- texto digitado;
- carregamento;
- visibilidade da senha;
- erro de submissao.

### 24.3. Estado `_LoginPageState`

O estado possui:

- `_formKey`: chave do formulario.
- `_emailController`: controla campo de email.
- `_passwordController`: controla campo de senha.
- `_authService`: servico de autenticacao.
- `_isLoading`: indica envio em andamento.
- `_obscurePassword`: controla se a senha esta oculta.
- `_submitError`: guarda mensagem de erro para mostrar no formulario.

### 24.4. Validacao de email

`_validateEmail` aplica as seguintes regras:

1. O campo nao pode estar vazio.
2. O email precisa combinar com uma expressao regular basica.

Mensagens possiveis:

- `Informe seu e-mail.`
- `Digite um e-mail vÃ¡lido.`

### 24.5. Validacao de senha

`_validatePassword` verifica se a senha foi preenchida.

Mensagem:

`Informe sua senha.`

### 24.6. Formatacao de erros

`_formatAuthError` limpa prefixos tecnicos comuns, como:

- `Exception: `
- `ClientException: `
- `Bad state: `

Isso melhora a mensagem exibida ao usuario.

### 24.7. Exibicao de erro

`_showAuthError` faz duas coisas:

1. Salva o erro em `_submitError`, para aparecer dentro do formulario.
2. Mostra um `SnackBar` com cor de erro.

Assim, o erro fica visivel tanto temporariamente quanto no corpo da tela.

### 24.8. Envio do formulario

`_submit` e o metodo principal da tela.

Fluxo:

1. Fecha o teclado com `FocusScope.of(context).unfocus()`.
2. Valida o formulario.
3. Le email e senha.
4. Ativa `_isLoading`.
5. Chama `_authService.signIn`.
6. Se der certo, mostra mensagem de sucesso.
7. Aguarda `AppStyles.feedbackDelay`.
8. Navega para `homeRoute` usando `Navigator.pushReplacementNamed`.
9. Se der erro, mostra mensagem adequada.
10. Ao final, desativa `_isLoading`.

### 24.9. Protecao com `mounted`

Depois de chamadas `await`, a tela verifica `if (!mounted) return`.

Isso evita tentar atualizar interface depois que a tela foi removida.

Esse e um bom cuidado em Flutter.

### 24.10. Interface visual

A tela usa:

- `Scaffold`;
- `SafeArea`;
- `AppLayout` com `AppLayoutWidth.form`;
- `Form`;
- `TextFormField` para email;
- `TextFormField` para senha;
- `FilledButton` para entrar;
- indicador de carregamento dentro do botao.

### 24.11. Campo de senha

O campo usa `obscureText` e um `IconButton` com:

- `Icons.visibility`
- `Icons.visibility_off`

Isso permite mostrar ou esconder a senha.

### 24.12. Experiencia do usuario

Enquanto esta carregando:

- botao fica desabilitado;
- aparece `CircularProgressIndicator`;
- evita multiplos envios.

Essa tela mostra boas praticas de formulario, feedback e navegacao.

## 25. `lib/telas/tela_inicial.dart`

### 25.1. Responsabilidade

`WelcomeScreen` e a tela inicial apos login.

Ela mostra os destaques de eventos do usuario, oferece atalhos para lista completa e cadastro, e permite logout.

### 25.2. Tipo de widget

E um `StatefulWidget` porque precisa carregar dados assincronamente, controlar atualizacoes e acompanhar eventos em exclusao.

### 25.3. Uso de `RouteAware`

O estado `_WelcomeScreenState` usa `RouteAware`.

Isso permite recarregar os destaques quando o usuario volta de outra tela, como cadastro ou edicao.

### 25.4. Campos principais

O estado possui:

- `_eventService`: servico para buscar e manipular eventos.
- `_busyEventIds`: conjunto de ids em processamento.
- `_route`: referencia da rota atual.
- `_highlightsFuture`: future com eventos em destaque.

### 25.5. Carregamento inicial

No `initState`, a tela chama `_loadHighlights()`.

Esse metodo usa `EventService.listEventos(limit: 3)`.

Portanto, a home mostra apenas ate tres eventos, mantendo a tela objetiva.

### 25.6. Atualizacao ao voltar

`didPopNext` chama `_refreshHighlights()`.

Isso significa que se o usuario abrir o cadastro, criar um evento e voltar, a home pode recarregar os destaques.

### 25.7. Edicao de evento

`_editEvent(Evento event)` abre `CadastrarEventoScreen(evento: event)`.

Quando um evento e passado para a tela de cadastro, ela funciona em modo de edicao.

### 25.8. Exclusao de evento

`_deleteEvent` executa o fluxo:

1. Mostra dialogo de confirmacao com `showDeleteEventDialog`.
2. Se o usuario cancelar, nao faz nada.
3. Se confirmar, adiciona o id em `_busyEventIds`.
4. Chama `_eventService.excluirEvento`.
5. Remove o id ocupado.
6. Recarrega os destaques.
7. Mostra snackbar de sucesso.
8. Em erro, remove o estado ocupado e mostra mensagem.

### 25.9. Logout

`_logout` chama `SessionService.clearSession()`.

Depois navega para a rota de login removendo todas as rotas anteriores:

`Navigator.pushNamedAndRemoveUntil(context, loginRoute, (route) => false)`

Isso impede que o usuario volte para uma tela autenticada pelo botao de voltar.

### 25.10. Construcao dos destaques

`_buildEventHighlights` recebe uma lista de eventos e monta os cards.

Ele usa `LayoutBuilder` e `AppLayout.eventColumnsForWidth`.

Se a tela for estreita:

- exibe uma coluna em `Column`.

Se a tela for larga:

- usa `Wrap` para organizar cards em grade flexivel.

### 25.11. Botoes de acao

`_buildActionButtons` cria dois botoes:

- `Ver tudo`: navega para a lista completa.
- `Adicionar novo`: navega para o formulario de cadastro.

Os botoes ficam lado a lado quando ha espaco e empilhados quando a tela e estreita.

### 25.12. Estados do `FutureBuilder`

No `build`, a tela usa `FutureBuilder<List<Evento>>`.

Estados tratados:

- carregando: mostra `CircularProgressIndicator`;
- erro: mostra mensagem e botao `Tentar novamente`;
- lista vazia: mostra `Nenhum compromisso prÃ³ximo encontrado.`;
- sucesso: mostra os cards.

### 25.13. Papel na experiencia geral

A tela inicial e o painel rapido do usuario. Ela nao tenta mostrar tudo; ela mostra destaques e caminhos para as acoes principais.

## 26. `lib/telas/tela_de_eventos.dart`

### 26.1. Responsabilidade

`EventListScreen` exibe todos os eventos cadastrados pelo usuario.

Ela permite editar e excluir eventos por meio dos cards.

### 26.2. Estado principal

O estado `_EventListScreenState` possui:

- `_eventService`: servico de eventos.
- `_busyEventIds`: ids de eventos em processamento.
- `_route`: rota atual observada.
- `_isLoading`: indica carregamento da lista.
- `_error`: mensagem de erro.
- `_events`: lista de eventos carregados.

### 26.3. Carregamento inicial

No `initState`, chama `_loadEvents()`.

Esse metodo busca todos os eventos do usuario pela camada `EventService`.

### 26.4. Atualizacao ao retornar

Assim como a home, a tela usa `RouteAware`.

Quando o usuario volta de cadastro ou edicao, `didPopNext` chama `_loadEvents()`.

Isso mantem a lista atualizada.

### 26.5. Metodo `_loadEvents`

Fluxo:

1. Ativa loading.
2. Limpa erro anterior.
3. Chama `_eventService.listEventos()` sem limite.
4. Em sucesso, salva a lista em `_events`.
5. Em `ApiException`, mostra mensagem da API.
6. Em erro inesperado, mostra `Erro ao carregar eventos.`
7. Desativa loading.

### 26.6. Edicao

`_editEvent` abre `CadastrarEventoScreen(evento: event)`.

Assim, a mesma tela de formulario serve para criar e editar.

### 26.7. Exclusao

`_deleteEvent` confirma com o usuario e chama `_eventService.excluirEvento`.

Depois remove o item da lista local.

Existe um fallback interessante:

- se a API retornar id `0`, o app remove pelo id original do evento.

Isso torna a interface mais resiliente a variacoes de resposta.

### 26.8. `_buildEventCard`

Esse metodo cria um `EventCard` para cada evento.

Ele passa:

- data formatada com `BrDateFormatter`;
- titulo;
- descricao;
- estado ocupado;
- acao ao tocar;
- menu de editar/excluir.

### 26.9. Conteudo responsivo

`_buildEventsContent` usa `AppLayout` com `AppLayoutWidth.list`.

Depois decide:

- em telas compactas, `ListView.separated`;
- em telas maiores, `Wrap` dentro de `ListView`, formando uma grade.

### 26.10. Estados da tela

`_buildBody` decide o que mostrar:

- se `_isLoading`, mostra indicador;
- se `_error` existe, mostra mensagem e botao de retry;
- se `_events` esta vazio, mostra `Nenhum evento cadastrado.`;
- caso contrario, mostra lista/grade de eventos.

### 26.11. Papel no sistema

Essa tela e a visao completa da agenda. Enquanto a home mostra apenas destaques, essa tela mostra tudo e permite gestao mais ampla.

## 27. `lib/telas/tela_cadastrar_evento.dart`

### 27.1. Responsabilidade

`CadastrarEventoScreen` e a tela de formulario para criar ou editar eventos.

Ela reutiliza a mesma estrutura para dois casos:

- novo cadastro;
- edicao de evento existente.

### 27.2. Parametro `evento`

A tela recebe `Evento? evento`.

Se `evento` for `null`, esta em modo de cadastro.

Se `evento` existir, esta em modo de edicao.

### 27.3. Getter `_isEditing`

O getter retorna `widget.evento != null`.

Ele simplifica varias decisoes da tela:

- titulo da AppBar;
- texto do botao;
- chamada de salvar ou editar;
- preenchimento inicial dos campos.

### 27.4. Controllers

A tela usa tres controllers:

- `_disciplinaController`
- `_atividadeController`
- `_dateController`

Eles controlam os campos de titulo, descricao e data exibida.

### 27.5. Data selecionada

`_selectedDate` comeca como `DateTime.now()`.

Se estiver editando, recebe `evento.dataEntrega`.

Depois `_syncSelectedDate()` coloca a data no campo visual no formato brasileiro.

### 27.6. Inicializacao em modo de edicao

No `initState`, se `_isEditing` for verdadeiro:

- preenche titulo com `evento.nomeDisciplina`;
- preenche descricao com `evento.descricaoAtividade`;
- define `_selectedDate` com `evento.dataEntrega`.

Isso permite que o usuario edite a partir dos dados existentes.

### 27.7. Escolha de data

`_pickDate` abre `showDatePicker`.

Configuracoes:

- locale `pt_BR`;
- data inicial igual a selecionada;
- primeira data: 2020;
- ultima data: 2030.

Se o usuario escolher uma data, a tela atualiza `_selectedDate` e sincroniza o texto exibido.

### 27.8. Conversao para API

`_toApiDate` converte `DateTime` para formato `yyyy-MM-dd`.

Esse formato e comum em APIs e bancos de dados.

Exemplo:

- exibicao ao usuario: `14/06/2026`
- envio para API: `2026-06-14`

### 27.9. Validacao de campos

`_validateRequired` verifica se o texto nao esta vazio.

Campos validados:

- titulo;
- descricao;
- data.

Mensagens especificas aparecem para orientar o usuario.

### 27.10. Botoes responsivos

`_buildActionButtons` cria:

- `Cancelar`
- `Salvar` ou `Atualizar`

Em telas largas, os botoes ficam lado a lado.

Em telas estreitas, ficam empilhados.

### 27.11. Salvamento

`_saveEvent` executa o fluxo:

1. Fecha teclado.
2. Valida formulario.
3. Remove espacos extras de titulo e descricao.
4. Ativa `_isSaving`.
5. Se estiver editando, chama `_eventService.editarEvento`.
6. Se estiver cadastrando, chama `_eventService.salvarEvento`.
7. Mostra snackbar de sucesso.
8. Volta para a tela anterior com `Navigator.pop(context, true)`.
9. Trata `ApiException` com mensagem da API.
10. Trata erro inesperado com mensagem generica.
11. Desativa `_isSaving` ao final.

### 27.12. Campos reutilizaveis

`_buildInputField` cria um campo com:

- rotulo;
- `TextFormField`;
- hint;
- validador;
- botao de limpar com `Icons.clear`.

Isso reduz repeticao no formulario.

### 27.13. Experiencia do usuario

Durante o salvamento:

- botoes ficam desabilitados;
- o botao principal mostra loading;
- o usuario nao dispara a mesma operacao varias vezes.

### 27.14. Papel no sistema

Essa tela concentra o fluxo de escrita de dados. Ela e usada tanto para criar quanto para editar eventos, reduzindo duplicacao de codigo.

## 28. Pasta `widgets`: componentes reutilizaveis

A pasta `widgets` contem componentes visuais que podem ser usados em mais de uma tela.

Atualmente, o principal arquivo e:

- `event_card.dart`

## 29. `lib/widgets/event_card.dart`

### 29.1. Responsabilidade

`EventCard` exibe um resumo visual de um evento com acoes rapidas.

Ele e usado tanto na tela inicial quanto na tela de lista completa.

### 29.2. Enum `EventCardAction`

O enum define as acoes disponiveis:

- `edit`
- `delete`

Usar enum e melhor do que strings, porque evita erros de digitacao e deixa o codigo mais seguro.

### 29.3. Parametros do `EventCard`

O card recebe:

- `date`: texto da data formatada.
- `title`: titulo do evento.
- `description`: descricao.
- `isBusy`: indica se alguma operacao esta em andamento.
- `onTap`: acao ao tocar no card.
- `onSelectedAction`: callback para menu de editar/excluir.

### 29.4. Estrutura visual

O card usa `Card` com `ListTile`.

O titulo vai em `title`.

Data e descricao aparecem no `subtitle`, separados por quebra de linha.

O `isThreeLine: true` indica que o item pode ocupar mais linhas.

### 29.5. Estado ocupado

Se `isBusy` for verdadeiro:

- o `ListTile` fica desabilitado;
- o menu de acoes e substituido por um `CircularProgressIndicator` pequeno.

Isso comunica que uma acao esta sendo executada naquele item.

### 29.6. Menu de acoes

Quando nao esta ocupado, o card mostra `PopupMenuButton<EventCardAction>`.

Opcoes:

- `Editar`
- `Excluir`

A tela que usa o card decide o que fazer quando a acao e selecionada.

### 29.7. `showDeleteEventDialog`

O arquivo tambem define uma funcao para mostrar confirmacao antes de excluir.

Ela recebe:

- `context`
- `eventTitle`

Mostra um `AlertDialog` com:

- titulo `Excluir evento`;
- texto perguntando se o usuario deseja excluir;
- botao `Cancelar`;
- botao `Excluir`.

Retorna `true` se o usuario confirmou e `false` caso contrario.

### 29.8. Reutilizacao

Como o dialogo e o card ficam no mesmo arquivo, as telas usam o mesmo comportamento de exclusao, mantendo consistencia.

## 30. Fluxo completo de autenticacao

### 30.1. Entrada no app

Quando o app abre, `AppStartScreen` consulta `SessionService.hasSession()`.

Se houver sessao valida, o usuario vai direto para `WelcomeScreen`.

Se nao houver, vai para `LoginPage`.

### 30.2. Login pelo usuario

Na tela de login:

1. Usuario informa email.
2. Usuario informa senha.
3. Formulario valida os campos.
4. `AuthService.signIn` e chamado.
5. `AuthService.login` faz POST em `/auth`.
6. `decodeApiResponse` valida JSON e status HTTP.
7. `AuthResponse.fromJson` extrai dados do usuario.
8. `SessionService.saveUserSession` salva id e email.
9. Tela mostra mensagem de sucesso.
10. Navega para a home.

### 30.3. Falha no login

Se a API retornar erro:

- `ApiException` e lancada;
- a tela mostra mensagem em snackbar;
- tambem mostra bloco de erro no formulario;
- o usuario pode corrigir os dados e tentar novamente.

### 30.4. Logout

Na home, o usuario pode tocar no icone de logout.

O app:

1. chama `SessionService.clearSession()`;
2. remove dados locais;
3. navega para login;
4. limpa historico de rotas.

## 31. Fluxo completo de listagem de eventos

### 31.1. Listagem na home

Na home, o app chama `EventService.listEventos(limit: 3)`.

Isso faz com que apenas destaques aparecam.

Fluxo:

1. Tela chama `EventService`.
2. `EventService` exige sessao.
3. `SessionService.getCurrentSession` retorna usuario.
4. `ApiService.listarEventos` chama `/listar_eventos`.
5. API retorna JSON.
6. `Evento.fromJson` transforma itens em objetos.
7. Tela exibe `EventCard`.

### 31.2. Listagem completa

Na tela `EventListScreen`, o app chama `EventService.listEventos()` sem limite.

O fluxo e parecido, mas a tela mostra todos os eventos.

### 31.3. Estados possiveis

As telas tratam:

- carregando;
- erro;
- lista vazia;
- lista com dados.

Isso e essencial para uma aplicacao real, porque chamadas de rede podem demorar ou falhar.

## 32. Fluxo completo de cadastro de evento

### 32.1. Acesso ao cadastro

O usuario pode acessar pelo botao `Adicionar novo` da home.

A rota usada e `createEventRoute`.

### 32.2. Preenchimento

O formulario solicita:

- titulo;
- descricao da atividade;
- data de entrega.

### 32.3. Validacao

Antes de salvar, a tela valida se todos os campos obrigatorios foram preenchidos.

### 32.4. Envio

Ao salvar:

1. tela formata a data para `yyyy-MM-dd`;
2. chama `EventService.salvarEvento`;
3. servico busca usuario em sessao;
4. `ApiService.salvarEvento` faz POST para `/salvar_evento`;
5. API responde;
6. app mostra snackbar de sucesso;
7. tela volta para a anterior.

### 32.5. Atualizacao da tela anterior

Como home e lista usam `RouteAware`, ao voltar elas podem recarregar os dados.

Isso fecha o ciclo de experiencia: o usuario cria o evento e ve a informacao atualizada.

## 33. Fluxo completo de edicao de evento

### 33.1. Entrada na edicao

O usuario pode editar:

- tocando no card;
- escolhendo `Editar` no menu do card.

### 33.2. Reuso da tela de cadastro

A edicao usa `CadastrarEventoScreen(evento: event)`.

Isso reaproveita o mesmo formulario.

### 33.3. Preenchimento automatico

Quando a tela recebe um evento:

- titulo ja vem preenchido;
- descricao ja vem preenchida;
- data ja vem selecionada;
- titulo da AppBar muda para `Editar evento`;
- botao principal muda para `Atualizar`.

### 33.4. Envio da edicao

Ao atualizar:

1. valida formulario;
2. chama `EventService.editarEvento`;
3. servico adiciona `usuarioId` da sessao;
4. `ApiService.editarEvento` envia POST para `/editar_evento`;
5. app mostra mensagem de sucesso;
6. volta para a tela anterior.

## 34. Fluxo completo de exclusao de evento

### 34.1. Inicio da exclusao

O usuario abre o menu do card e escolhe `Excluir`.

### 34.2. Confirmacao

Antes de excluir, o app chama `showDeleteEventDialog`.

Isso evita exclusao acidental.

### 34.3. Estado ocupado

Enquanto a exclusao acontece:

- o id do evento entra em `_busyEventIds`;
- o card mostra loading;
- o menu fica indisponivel.

### 34.4. Chamada da API

O app chama `EventService.excluirEvento`, que chama `ApiService.excluirEvento`.

O endpoint usado e `/excluir_evento`.

### 34.5. Depois da exclusao

Na home:

- os destaques sao recarregados.

Na lista completa:

- o item e removido da lista local.

### 34.6. Feedback

O usuario recebe snackbar:

`Evento excluÃ­do com sucesso.`

Em caso de erro, recebe mensagem da API ou mensagem generica.

## 35. Tratamento de erros no projeto

### 35.1. Erros de API

Erros de API sao representados por `ApiException`.

Isso permite mostrar mensagens mais claras ao usuario.

### 35.2. Erros HTTP

`decodeApiResponse` trata status HTTP maior ou igual a 400.

Se a API enviar `mensagem`, ela e preservada.

Caso contrario, usa mensagem padrao.

### 35.3. JSON invalido

Se a resposta nao for JSON valido, o app mostra:

`Resposta invalida do servidor.`

### 35.4. Dados incompletos

Se JSON nao contem campos obrigatorios, `JsonReader` lanca `FormatException`, que os servicos transformam em `ApiException` quando apropriado.

### 35.5. Erros inesperados

As telas tambem possuem blocos `catch` genericos.

Isso evita que a interface quebre sem feedback.

### 35.6. Mensagens amigaveis

O login remove prefixos tecnicos comuns de erro.

Isso melhora a experiencia porque o usuario nao precisa ver mensagens internas como `Exception:` ou `ClientException:`.

## 36. Estados de carregamento e bloqueio de acoes

### 36.1. Login

Durante o login:

- `_isLoading` fica verdadeiro;
- botao `Entrar` e desabilitado;
- aparece spinner no botao.

### 36.2. Cadastro/edicao

Durante o salvamento:

- `_isSaving` fica verdadeiro;
- botoes ficam desabilitados;
- aparece spinner no botao principal.

### 36.3. Exclusao

Durante exclusao:

- id entra em `_busyEventIds`;
- apenas aquele card mostra spinner;
- evita clique repetido no mesmo item.

### 36.4. Listagem

Durante busca de dados:

- home usa `FutureBuilder`;
- lista completa usa `_isLoading`;
- ambas mostram `CircularProgressIndicator`.

### 36.5. Importancia

Esses estados tornam a interface mais previsivel e evitam operacoes duplicadas.

## 37. Responsividade

### 37.1. Por que responsividade importa

O Flutter permite executar o app em diferentes tamanhos de tela. O codigo foi preparado para celular, tablet, desktop e web.

### 37.2. `AppLayout`

`AppLayout` controla padding e largura maxima.

Ele impede que formularios fiquem largos demais em telas grandes.

### 37.3. Cards em uma ou duas colunas

`AppLayout.eventColumnsForWidth` retorna:

- 1 coluna para telas estreitas;
- 2 colunas para telas mais largas.

Isso e usado na home e na lista de eventos.

### 37.4. Botoes adaptativos

Em home e formulario, botoes usam `Wrap`.

Quando ha espaco, ficam lado a lado.

Quando nao ha, quebram para a proxima linha.

### 37.5. `SafeArea`

As telas principais usam `SafeArea` para evitar sobreposicao com areas do sistema, como notch, barra de status e gestos.

## 38. Design visual e Material 3

### 38.1. Material Design 3

O app usa `useMaterial3: true`, oferecendo componentes modernos e coerentes.

### 38.2. Tema dinamico

Com `dynamic_color`, o app pode usar cores do sistema quando disponiveis.

Isso deixa a experiencia mais integrada ao dispositivo.

### 38.3. Tema claro e escuro

O app define `theme` e `darkTheme`, com `ThemeMode.system`.

Ou seja, acompanha a preferencia do usuario.

### 38.4. Componentes padronizados

Campos, botoes, cards, snackbars e list tiles seguem regras centralizadas.

Isso evita inconsistencias visuais.

## 39. Localizacao brasileira

### 39.1. Locale do app

O `MaterialApp` usa:

`locale: const Locale('pt', 'BR')`

### 39.2. Datas

Datas sao exibidas em `dd/MM/yyyy`.

### 39.3. DatePicker

O seletor de data tambem usa locale `pt_BR`.

### 39.4. Textos da interface

Os textos visiveis estao em portugues:

- `Entrar`
- `Cadastrar evento`
- `Lista de eventos`
- `Boas-vindas`
- `Tentar novamente`
- `Evento excluÃ­do com sucesso.`

Isso mostra que o app foi pensado para usuarios brasileiros.

## 40. Seguranca e persistencia de sessao

### 40.1. O que e salvo localmente

O app salva apenas:

- id do usuario;
- email.

Nao ha salvamento de senha no codigo.

### 40.2. Uso de `SharedPreferences`

`SharedPreferences` e adequado para dados simples de configuracao/sessao leve.

### 40.3. Validacao da sessao

Antes de considerar sessao valida, o app verifica:

- id existe;
- id e maior que zero;
- email nao esta vazio.

### 40.4. Encerramento de sessao

Ao fazer logout, os dados sao removidos.

Depois o historico de navegacao e limpo.

### 40.5. Observacao para a apresentacao

O app nao guarda a senha localmente, o que e positivo. Para evolucao futura, poderia ser estudado uso de token JWT, refresh token e armazenamento seguro.

## 41. Comunicacao com API

### 41.1. Endpoints usados

O codigo usa os seguintes endpoints:

- `/auth`: login.
- `/listar_eventos`: listagem.
- `/salvar_evento`: cadastro.
- `/editar_evento`: edicao.
- `/excluir_evento`: exclusao.

### 41.2. Padrao de resposta

Os servicos esperam que a API retorne JSON com campo `status`.

Quando `status` e `sucesso`, o app continua.

Quando nao e, o app mostra mensagem de erro.

### 41.3. Conteudo das requisicoes

Login envia:

- email;
- senha;
- acao `login`.

Cadastro envia:

- usuario_id;
- nome_disciplina;
- descricao_atividade;
- data_entrega.

Edicao envia tambem:

- evento_id.

Exclusao envia:

- evento_id;
- usuario_id.

### 41.4. Separacao importante

As telas nao conhecem endpoints. Elas chamam servicos.

Isso deixa a interface mais independente da API.

## 42. Reutilizacao de codigo

### 42.1. Reutilizacao visual

`EventCard` e usado em mais de uma tela.

`AppLayout` e usado em quase todas as telas.

`AppStyles` e usado para gaps, paddings e tamanhos.

### 42.2. Reutilizacao de regra

`EventService` centraliza eventos com sessao.

`ApiService` centraliza chamadas de eventos.

`JsonReader` centraliza validacao de JSON.

`BrDateFormatter` centraliza exibicao de datas.

### 42.3. Reutilizacao de tela

`CadastrarEventoScreen` serve para criar e editar.

Isso evita duplicar dois formularios quase iguais.

## 43. Pontos fortes do codigo

### 43.1. Separacao de responsabilidades

Cada arquivo tem uma funcao clara.

Isso facilita entender, explicar e manter o projeto.

### 43.2. Camada de servicos

As telas nao fazem HTTP diretamente.

Isso e positivo para testes e organizacao.

### 43.3. Validacao de dados

O app valida formularios e tambem valida JSON recebido da API.

### 43.4. Feedback ao usuario

O usuario recebe indicadores de carregamento, snackbars, mensagens de erro e confirmacao de exclusao.

### 43.5. Responsividade

O layout se adapta a diferentes tamanhos de tela.

### 43.6. Tema centralizado

Visual do app esta concentrado em `AppTheme` e `AppStyles`.

### 43.7. Localizacao

O app esta configurado para portugues do Brasil.

### 43.8. Sessao local

O app reconhece usuario ja autenticado e evita login repetido.

## 44. Possibilidades de extensao futura

### 44.1. Cadastro de usuarios

Atualmente, o codigo da `lib` mostra fluxo de login, mas nao uma tela de cadastro de usuario.

Uma extensao possivel seria criar:

- tela de registro;
- endpoint de cadastro;
- validacao de senha forte;
- confirmacao de email.

### 44.2. Recuperacao de senha

Poderia ser adicionada uma tela de recuperacao de senha com envio de email.

### 44.3. Ordenacao e filtros

A lista de eventos poderia ganhar:

- filtro por disciplina;
- filtro por data;
- busca textual;
- ordenacao por prazo;
- visualizacao de eventos vencidos e futuros.

### 44.4. Marcacao de concluido

O model `Evento` poderia incluir um campo `concluido`.

Com isso, o usuario poderia marcar tarefas como finalizadas.

### 44.5. Notificacoes

O app poderia enviar notificacoes proximas da data de entrega.

Isso aumentaria o valor pratico do projeto.

### 44.6. Calendario

Uma visualizacao em calendario poderia complementar a lista.

### 44.7. Armazenamento seguro

Se futuramente houver tokens, o ideal seria usar armazenamento seguro da plataforma, nao apenas `SharedPreferences`.

### 44.8. Internacionalizacao completa

Hoje o app esta fixo em portugues do Brasil.

Poderia ser criado um sistema de arquivos de traducao para multiplos idiomas.

### 44.9. Melhorias de API

A API poderia retornar contratos mais padronizados, reduzindo a necessidade de aceitar chaves alternativas como `evento_id`, `id_evento` e `id`.

### 44.10. Estado global

Para crescimento do app, poderia ser avaliado o uso de gerenciamento de estado, como Provider, Riverpod, Bloc ou outro padrao.

No momento, o estado local das telas e suficiente para o tamanho do projeto.

### 44.11. Testes ampliados

O projeto ja possui estrutura de testes fora da pasta `lib`. Uma evolucao seria ampliar testes para:

- telas;
- fluxos completos;
- casos de erro;
- responsividade;
- integracao com API mockada.

### 44.12. Modo offline

Outra extensao seria permitir que eventos fossem armazenados localmente e sincronizados depois.

## 45. Como apresentar cada camada de forma didatica

### 45.1. Comecar pelo usuario

Uma boa forma de apresentar e iniciar pelo fluxo visivel:

1. O usuario abre o app.
2. Se ja estiver logado, vai para inicio.
3. Se nao estiver logado, faz login.
4. Visualiza destaques.
5. Abre lista completa.
6. Cadastra um evento.
7. Edita ou exclui quando necessario.

Depois disso, explicar como o codigo implementa cada etapa.

### 45.2. Relacionar fluxo e arquivos

Para cada etapa, citar os arquivos envolvidos:

- abertura: `main.dart`, `session_service.dart`;
- login: `tela_de_login.dart`, `auth_service.dart`, `auth_response.dart`;
- home: `tela_inicial.dart`, `event_service.dart`, `event_card.dart`;
- lista: `tela_de_eventos.dart`, `event_service.dart`, `evento.dart`;
- cadastro/edicao: `tela_cadastrar_evento.dart`, `api_service.dart`;
- tema/layout: `app_theme.dart`, `app_styles.dart`, `app_layout.dart`.

### 45.3. Explicar a separacao

Mensagem-chave:

O projeto separa interface, regra de servico, comunicacao com API, modelos e utilitarios. Isso melhora manutencao e extensibilidade.

## 46. Roteiro de fala sugerido

### 46.1. Introducao

"O SafeRoute e um aplicativo desenvolvido em Flutter com foco em organizacao de eventos e tarefas academicas. A ideia e permitir que o usuario acesse sua conta, visualize compromissos, cadastre novos eventos, edite informacoes e exclua itens quando necessario."

### 46.2. Tecnologias

"A aplicacao usa Flutter e Dart. Tambem utiliza Material Design 3 para a interface, `http` para comunicacao com a API, `shared_preferences` para manter a sessao local, `intl` para formatacao de datas brasileiras e `dynamic_color` para integrar o tema as cores do sistema."

### 46.3. Arquitetura

"A pasta `lib` foi organizada em camadas. Temos `core`, que concentra configuracoes e padroes; `models`, que representa os dados; `services`, que faz autenticacao, sessao e comunicacao com API; `telas`, que contem as interfaces completas; e `widgets`, com componentes reutilizaveis."

### 46.4. Inicializacao

"O app comeca em `main.dart`. Antes de renderizar a interface, ele inicializa recursos de data em portugues do Brasil. Depois, cria o `SafeRouteApp`, que configura tema, localizacao, rotas e decide a tela inicial."

### 46.5. Sessao

"A primeira decisao do app e verificar se existe uma sessao salva. Isso acontece em `AppStartScreen`, usando `SessionService.hasSession()`. Se existir sessao, o usuario vai direto para a tela inicial. Caso contrario, vai para o login."

### 46.6. Login

"A tela de login valida email e senha. Quando o usuario envia o formulario, ela chama `AuthService.signIn`. Esse servico faz a requisicao para `/auth`, interpreta a resposta com `AuthResponse` e salva a sessao local com `SessionService`."

### 46.7. Tela inicial

"Depois do login, a tela inicial mostra uma saudacao, os principais eventos do usuario e dois atalhos: ver tudo e adicionar novo. Os destaques sao carregados com limite de tres eventos, o que deixa a tela mais objetiva."

### 46.8. Lista de eventos

"A tela de lista carrega todos os eventos do usuario. Ela trata carregamento, erro, lista vazia e sucesso. Cada evento aparece em um card com opcoes de editar e excluir."

### 46.9. Cadastro e edicao

"A mesma tela serve para cadastrar e editar eventos. Quando nenhum evento e passado, ela funciona como cadastro. Quando recebe um `Evento`, preenche os campos e muda para modo de edicao. Essa reutilizacao evita duplicacao de codigo."

### 46.10. Exclusao

"A exclusao sempre pede confirmacao antes de prosseguir. Durante o processo, o card mostra um carregamento, evitando clique duplo. Depois, a tela atualiza os dados e mostra feedback ao usuario."

### 46.11. API

"A comunicacao com a API e centralizada. `ApiService` conhece os endpoints de eventos, enquanto `api_support.dart` monta URLs e decodifica respostas. Isso evita repetir regras de HTTP nas telas."

### 46.12. Modelos

"Os modelos `AuthResponse` e `Evento` transformam JSON em objetos Dart. Eles usam `JsonReader`, que valida campos obrigatorios e aceita algumas chaves alternativas, tornando o app mais resistente a variacoes da API."

### 46.13. Tema e layout

"O visual do projeto e centralizado em `AppTheme` e `AppStyles`. O app usa Material 3, tema claro e escuro, cores dinamicas quando disponiveis, campos e botoes padronizados. O `AppLayout` garante que as telas se adaptem bem a celular, tablet e desktop."

### 46.14. Tratamento de erros

"O projeto trata erros de forma controlada. Erros de API viram `ApiException`; respostas invalidas geram mensagens especificas; telas mostram snackbars, mensagens de retry e indicadores de carregamento."

### 46.15. Encerramento

"Como resultado, o SafeRoute apresenta uma base organizada, funcional e extensivel. Ele ja cobre autenticacao, persistencia de sessao, CRUD de eventos, responsividade, tema centralizado e comunicacao com API. A estrutura permite evoluir para novas funcionalidades, como notificacoes, filtros, calendario e cadastro de usuarios."

## 47. Sequencia recomendada para demonstracao pratica

### 47.1. Demonstracao 1: abertura do app

Mostrar que o app abre verificando sessao.

Explicar que essa decisao esta em `AppStartScreen`.

### 47.2. Demonstracao 2: login

Digitar email e senha.

Mostrar validacao caso o campo esteja vazio.

Depois realizar login e mostrar redirecionamento.

### 47.3. Demonstracao 3: tela inicial

Mostrar destaques de eventos.

Explicar que o limite e tres eventos.

Mostrar botoes `Ver tudo` e `Adicionar novo`.

### 47.4. Demonstracao 4: cadastrar evento

Abrir formulario.

Preencher titulo, descricao e data.

Salvar.

Mostrar snackbar de sucesso.

### 47.5. Demonstracao 5: lista completa

Abrir lista completa.

Mostrar que o novo evento aparece.

Explicar que a tela recarrega ao retornar.

### 47.6. Demonstracao 6: editar evento

Tocar no card ou escolher `Editar`.

Mostrar campos preenchidos.

Alterar dados e salvar.

### 47.7. Demonstracao 7: excluir evento

Abrir menu.

Escolher `Excluir`.

Mostrar dialogo de confirmacao.

Confirmar e mostrar feedback.

### 47.8. Demonstracao 8: logout

Tocar no botao de logout.

Mostrar retorno ao login.

Explicar que a sessao local foi removida.

## 48. Mapa arquivo por arquivo da pasta `lib`

### 48.1. `main.dart`

- Inicializa Flutter.
- Inicializa formatacao de datas brasileiras.
- Define rotas.
- Configura `MaterialApp`.
- Aplica tema dinamico, claro e escuro.
- Configura localizacao.
- Decide tela inicial com base na sessao.
- Cria `RouteObserver` para atualizacao de telas.

### 48.2. `core/app_config.dart`

- Centraliza URL base da API.
- Permite configurar ambiente via `--dart-define`.
- Define fallback de producao.

### 48.3. `core/app_styles.dart`

- Centraliza breakpoints.
- Centraliza larguras maximas.
- Centraliza espacamentos.
- Centraliza tamanhos de componentes.
- Define gaps reutilizaveis.
- Define delay de feedback.

### 48.4. `core/app_layout.dart`

- Cria wrapper responsivo.
- Aplica padding padrao.
- Aplica largura maxima por tipo de conteudo.
- Permite conteudo rolavel.
- Decide colunas de cards.

### 48.5. `core/app_theme.dart`

- Cria tema claro.
- Cria tema escuro.
- Usa Material 3.
- Usa cores dinamicas ou cores-semente.
- Padroniza campos, botoes, cards e snackbars.

### 48.6. `core/br_date_formatter.dart`

- Formata datas em `dd/MM/yyyy`.
- Usa locale `pt_BR`.
- Mantem exibicao de datas consistente.

### 48.7. `core/json_reader.dart`

- Le inteiros obrigatorios.
- Le textos obrigatorios.
- Le datas obrigatorias.
- Le objetos obrigatorios.
- Aceita chaves alternativas.
- Lanca erro quando dados estao invalidos.

### 48.8. `models/auth_response.dart`

- Representa resposta de login.
- Guarda id do usuario, email e mensagem.
- Converte JSON em objeto tipado.
- Usa `JsonReader` para validar dados.

### 48.9. `models/evento.dart`

- Representa um evento.
- Guarda id, disciplina/titulo, descricao e data.
- Converte JSON da API em objeto Dart.
- Aceita nomes alternativos para id.

### 48.10. `services/api_exception.dart`

- Representa erros de API.
- Guarda mensagem e status HTTP.
- Facilita tratamento diferenciado nas telas.

### 48.11. `services/api_support.dart`

- Monta URLs da API.
- Decodifica respostas JSON.
- Trata erro HTTP.
- Converte respostas invalidas em `ApiException`.

### 48.12. `services/api_service.dart`

- Lista eventos.
- Salva eventos.
- Edita eventos.
- Exclui eventos.
- Conhece endpoints da API.
- Converte respostas em models.

### 48.13. `services/auth_service.dart`

- Faz login remoto.
- Valida resposta da API.
- Converte resposta em `AuthResponse`.
- Salva sessao local no `signIn`.

### 48.14. `services/event_service.dart`

- Intermedia telas e `ApiService`.
- Busca sessao antes de operar eventos.
- Garante que eventos estejam vinculados ao usuario logado.
- Simplifica chamadas das telas.

### 48.15. `services/session_service.dart`

- Salva sessao local.
- Recupera usuario atual.
- Verifica se ha sessao.
- Limpa sessao no logout.
- Usa `SharedPreferences`.

### 48.16. `telas/telas.dart`

- Reexporta telas principais.
- Simplifica imports no `main.dart`.

### 48.17. `telas/tela_de_login.dart`

- Mostra formulario de login.
- Valida email e senha.
- Permite mostrar/esconder senha.
- Chama autenticacao.
- Mostra erros e loading.
- Navega para home apos sucesso.

### 48.18. `telas/tela_inicial.dart`

- Mostra boas-vindas.
- Lista eventos em destaque.
- Permite acessar lista completa.
- Permite cadastrar novo evento.
- Permite editar/excluir destaques.
- Permite logout.
- Atualiza dados ao retornar de outras telas.

### 48.19. `telas/tela_de_eventos.dart`

- Mostra todos os eventos.
- Trata loading, erro, vazio e sucesso.
- Permite editar e excluir.
- Usa layout responsivo em lista ou grade.
- Atualiza ao retornar de cadastro/edicao.

### 48.20. `telas/tela_cadastrar_evento.dart`

- Cria eventos.
- Edita eventos existentes.
- Valida campos obrigatorios.
- Usa seletor de data.
- Formata data para exibicao e envio.
- Mostra feedback de sucesso ou erro.

### 48.21. `widgets/event_card.dart`

- Exibe card de evento.
- Mostra data, titulo e descricao.
- Oferece menu de editar/excluir.
- Mostra loading por item.
- Contem dialogo de confirmacao de exclusao.

## 49. Perguntas que podem surgir na banca ou apresentacao

### 49.1. Por que usar Flutter?

Porque permite desenvolver uma interface moderna e multiplataforma com uma unica base de codigo.

### 49.2. Por que separar em `services`?

Para que as telas nao precisem conhecer detalhes de API, endpoints e persistencia.

### 49.3. Por que existe `EventService` se ja existe `ApiService`?

Porque `EventService` adiciona a regra de sessao. Ele garante que as operacoes de eventos sempre usem o usuario logado.

### 49.4. Por que usar `SharedPreferences`?

Porque a sessao salva apenas dados simples: id e email. Para dados sensiveis futuros, seria melhor armazenamento seguro.

### 49.5. Como o app evita dados quebrados da API?

Usando `JsonReader`, `Evento.fromJson`, `AuthResponse.fromJson` e `decodeApiResponse`.

### 49.6. Como o app se adapta a telas maiores?

Usando `AppLayout`, breakpoints em `AppStyles`, `LayoutBuilder` e `Wrap`.

### 49.7. Como o app sabe que precisa atualizar a lista quando volta de outra tela?

Usando `RouteObserver` em `main.dart` e `RouteAware` nas telas de home e lista.

### 49.8. Por que o formulario de cadastro tambem edita?

Porque os campos sao praticamente os mesmos. Reutilizar a tela reduz duplicacao e facilita manutencao.

### 49.9. O app salva senha?

Nao. O codigo salva apenas id do usuario e email.

### 49.10. O que poderia melhorar no futuro?

Filtros, notificacoes, calendario, cadastro de usuarios, recuperacao de senha, armazenamento seguro, modo offline e testes mais amplos.

## 50. Conclusao da apresentacao

O SafeRoute apresenta uma estrutura consistente para um aplicativo de gestao de eventos academicos. Ele possui autenticacao, persistencia de sessao, listagem de eventos, cadastro, edicao e exclusao.

Do ponto de vista tecnico, o projeto se destaca por separar responsabilidades em pastas claras. A camada `core` padroniza configuracao, layout, tema e utilitarios. A camada `models` define os dados usados pelo app. A camada `services` concentra comunicacao com API e sessao. As telas implementam os fluxos do usuario, e o widget `EventCard` reaproveita a exibicao de eventos.

Do ponto de vista da experiencia, o app oferece mensagens de erro, feedback de sucesso, indicadores de carregamento, confirmacao antes de excluir, layout responsivo e tema integrado ao sistema.

Como trabalho academico, o projeto demonstra dominio de Flutter, organizacao de codigo, consumo de API, persistencia local, validacao de formularios, tratamento de estados e preocupacao com extensibilidade.

Uma frase final possivel:

"Portanto, o SafeRoute nao e apenas uma tela de cadastro de tarefas; ele e uma aplicacao estruturada em camadas, preparada para evoluir e para oferecer ao usuario uma experiencia simples, organizada e coerente."

