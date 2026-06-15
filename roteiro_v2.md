# Roteiro de apresentação v2 - SafeRoute em funcionamento

Este roteiro foi feito para acompanhar a demonstração real do aplicativo. A ideia é mostrar a tela funcionando e, ao mesmo tempo, explicar o que acontece por trás: navegação, validação, sessão local, chamadas para a API, conversão dos dados, atualização da interface e tratamento de erros.

Use como fala guiada. Em cada etapa, primeiro aparece o que deve ser mostrado na tela e depois uma sugestão do que falar.

Para diminuir o peso dos termos técnicos, os blocos "O que acontece no fundo" usam este formato: explicação simples | detalhe técnico. Na apresentação, fale principalmente a primeira parte. O detalhe depois da barra serve como cola caso você queira mostrar que sabe exatamente onde aquilo acontece no código.

Nesta versão, alguns tópicos também trazem um bloco "Trecho direto do código". A ideia é que você possa literalmente apontar para um recorte real do arquivo enquanto explica o fluxo.

---

## 1. Abertura do aplicativo

### O que mostrar

Abrir o SafeRoute no navegador, emulador ou dispositivo.

### Fala sugerida

"Ao abrir o SafeRoute, a primeira coisa que o aplicativo faz não é simplesmente jogar o usuário numa tela fixa. Ele verifica se já existe uma sessão salva localmente. Enquanto essa leitura está acontecendo, o app pode mostrar um indicador de carregamento. Tecnicamente, essa decisão fica numa tela de partida chamada `AppStartScreen`."

"Por trás disso, uma classe de sessão consulta o armazenamento local do aparelho. Tecnicamente, isso é `SessionService.hasSession()` usando `SharedPreferences`. Se existir um `usuario_id` válido e um e-mail salvo, o usuário entra direto na tela inicial. Se não existir sessão, ele cai na tela de login."

"Um ponto importante é que o app não salva senha localmente. Ele salva apenas o id do usuário e o e-mail, que são os dados mínimos para saber quem está usando o aplicativo depois do login."

### O que acontece no fundo

- O app prepara a base antes de mostrar qualquer tela | `main.dart` inicializa o Flutter, a localização brasileira e o `SafeRouteApp`.
- O app define tema, idioma e caminhos de navegação | `MaterialApp` configura tema, locale, rotas nomeadas e `appRouteObserver`.
- Uma tela de decisão verifica se já existe usuário logado | `AppStartScreen` usa um `FutureBuilder` esperando `SessionService.hasSession()`.
- Se encontrar uma sessão válida, entra direto na home | abre `WelcomeScreen`.
- Se não encontrar sessão, manda o usuário para o login | abre `LoginPage`.

### Trecho direto do código

```dart
return FutureBuilder<bool>(
  future: SessionService.hasSession(),
  builder: (context, snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (snapshot.data == true) {
      return const WelcomeScreen();
    }

    return const LoginPage();
  },
);
```

---

## 2. Tela de login

### O que mostrar

Mostrar os campos de e-mail e senha. Se quiser, clicar no ícone de visibilidade da senha antes de entrar.

### Fala sugerida

"Aqui temos a tela de login. Ela é um formulário que guarda o que o usuário digita nos campos. Tecnicamente, esses campos usam `TextEditingController`. Antes de chamar qualquer API, o app valida os dados: o e-mail precisa ter formato de e-mail e a senha não pode estar vazia."

"Esse ícone no campo de senha só muda o estado visual do campo. Internamente, uma variável controla se a senha aparece ou fica escondida. Tecnicamente, essa variável é `_obscurePassword`."

"Quando eu clico em Entrar, o teclado é fechado, o formulário é validado e o botão fica desabilitado com um spinner. Isso evita que o usuário clique várias vezes e dispare várias tentativas de login ao mesmo tempo."

### O que acontece no fundo

- Ao clicar em Entrar, uma função da tela assume o envio | `_submit()` é chamado.
- Antes de falar com o servidor, o formulário confere os campos | `_submit()` valida o `Form` com `_formKey.currentState.validate()`.
- Se houver erro nos campos, a requisição nem acontece | o método retorna antes de chamar a API.
- Se estiver tudo certo, a tela entra em modo de carregamento | `_isLoading` vira `true`.
- O botão mostra que está processando | exibe `CircularProgressIndicator`.
- Uma classe de autenticação tenta entrar com e-mail e senha | `AuthService.signIn(email: email, senha: senha)`.

---

## 3. Login com sucesso

### O que mostrar

Digitar credenciais válidas e clicar em Entrar.

### Fala sugerida

"Agora, quando eu faço o login com dados válidos, uma classe responsável pela autenticação envia os dados para o servidor. Essa chamada é uma requisição do tipo `POST` para o endpoint `/auth`. O corpo da requisição vai em JSON com e-mail, senha e a ação `login`."

"A resposta do servidor passa por uma função que confere se veio um JSON válido e se não houve erro de comunicação. Depois disso, a classe de autenticação verifica se a resposta veio marcada como sucesso. Tecnicamente, essa validação passa por `decodeApiResponse` e pelo `AuthService`."

"Se a API confirmou o login, a resposta é convertida para um objeto de autenticação, que guarda o id do usuário, o e-mail e a mensagem de retorno. Tecnicamente, esse objeto é `AuthResponse`. Em seguida, o app salva a sessão local com `SessionService.saveUserSession()`."

"Depois de salvar a sessão, a tela mostra uma mensagem rápida de confirmação e troca o login pela home. Tecnicamente, essa navegação usa `Navigator.pushReplacementNamed`. Esse detalhe é importante porque o usuário não volta para o login apertando voltar logo depois de entrar."

### O que acontece no fundo

- Uma função de autenticação manda os dados para o endpoint de login | `AuthService.login()` faz `POST /auth`.
- O servidor recebe as credenciais em formato JSON | o corpo contém `email`, `senha` e `acao: login`.
- Uma função central confere se a resposta é válida | `decodeApiResponse()` valida JSON e status HTTP.
- A resposta vira um objeto organizado para o app usar | `AuthResponse.fromJson()` transforma o JSON em model tipado.
- O app guarda os dados mínimos da sessão no dispositivo | `SessionService.saveUserSession()` salva `usuario_id` e `usuario_email`.
- A tela mostra uma confirmação rápida para o usuário | exibe um `SnackBar` com a mensagem da API.
- Depois da confirmação, o app troca login pela home | navega para `homeRoute` com `pushReplacementNamed`.

### Trecho direto do código

```dart
final response = await _client.post(
  buildApiUri('/auth'),
  headers: const {'Content-Type': 'application/json'},
  body: jsonEncode({'email': email, 'senha': senha, 'acao': 'login'}),
);

final data = decodeApiResponse(response);

await SessionService.saveUserSession(
  userId: authResponse.userId,
  email: authResponse.email,
);
```

---

## 4. Login com erro ou dados inválidos

### O que mostrar

Opcional: tentar entrar com campo vazio, e-mail inválido ou credenciais incorretas.

### Fala sugerida

"Se eu tentar entrar com um campo vazio ou com e-mail inválido, o app nem chama a API. A validação acontece no próprio formulário. Isso economiza requisição e dá uma resposta imediata para o usuário."

"Se os campos estão válidos, mas a API rejeita as credenciais, o erro é tratado de forma controlada. Tecnicamente, ele vira uma `ApiException`. A tela formata a mensagem para não exibir prefixos técnicos e mostra o problema de duas formas: dentro do formulário e também em um `SnackBar`."

"Esse tratamento deixa a experiência mais clara, porque o usuário entende o que aconteceu sem ver uma mensagem crua de exceção ou erro técnico."

### O que acontece no fundo

- Uma validação local confere se o e-mail foi preenchido corretamente | `_validateEmail()` verifica preenchimento e formato.
- Outra validação local confere se a senha foi informada | `_validatePassword()` verifica campo vazio.
- Erros vindos do servidor são tratados de forma controlada | falhas viram `ApiException`.
- A tela guarda e mostra a mensagem de erro ao usuário | `_showAuthError()` salva em `_submitError` e mostra `SnackBar`.
- Quando a tentativa termina, o botão é liberado de novo | `_isLoading` volta para `false`.

---

## 5. Entrada na tela inicial

### O que mostrar

Depois do login, mostrar a tela "Início" com "Boas-vindas", destaques e botões "Ver tudo" e "Adicionar novo".

### Fala sugerida

"Depois do login, chegamos na tela inicial. Essa tela não mostra todos os eventos de uma vez. Ela carrega apenas os três eventos de destaque para manter a home mais limpa."

"Por trás da tela, assim que ela é criada, o app já prepara a busca desses destaques. Em termos técnicos, isso começa no `initState`, que prepara `_highlightsFuture` e chama `EventService.listEventos(limit: 3)`."

"Então o fluxo é: a interface pede os destaques, uma camada de serviço confere qual usuário está logado, pega o id salvo na sessão local e chama a API. Tecnicamente, o `EventService` pega o `usuario_id` e o `ApiService` chama `/listar_eventos` com `limit=3`."

"Quando a API responde, cada item recebido é transformado em um objeto de evento. Tecnicamente, esse objeto é `Evento`. Ele garante que o app trabalhe com campos organizados, como id, título, descrição e data, em vez de ficar manipulando o JSON direto na tela."

### O que acontece no fundo

- A home prepara a busca assim que abre | `WelcomeScreen.initState()` prepara `_highlightsFuture`.
- A busca pede somente três eventos | `_loadHighlights()` chama `EventService.listEventos(limit: 3)`.
- Antes de buscar eventos, o app confirma quem está logado | `EventService` chama `_requireSession()`.
- A sessão local informa o id do usuário | `_requireSession()` usa `SessionService.getCurrentSession()`.
- A API recebe o id do usuário e o limite de três itens | `ApiService.listarEventos()` faz `GET /listar_eventos?usuario_id=...&limit=3`.
- A resposta é conferida antes de virar tela | `decodeApiResponse()` valida a resposta.
- Cada item recebido vira um evento organizado | `Evento.fromJson()` converte cada evento recebido.
- A tela escolhe se mostra loading, erro, vazio ou cards | `FutureBuilder` decide o estado visual.

### Trecho direto do código

```dart
void initState() {
  super.initState();
  _highlightsFuture = _loadHighlights();
}

Future<List<Evento>> _loadHighlights() async {
  return _eventService.listEventos(limit: 3);
}

Future<List<Evento>> listEventos({int? limit}) async {
  final session = await _requireSession();
  return _apiService.listarEventos(usuarioId: session.userId, limit: limit);
}
```

---

## 6. Carregamento dos três eventos na home

### O que mostrar

Apontar para os cards de evento que aparecem na tela inicial.

### Fala sugerida

"Aqui estão os três eventos que a tela principal puxou da API. Cada cartão é um componente reutilizável que recebe a data formatada, o título, a descrição e as ações disponíveis. Tecnicamente, esse componente é o `EventCard`."

"A data não é exibida diretamente no formato da API. A API trabalha com data em formato técnico, mas a tela usa um formatador para mostrar no padrão brasileiro, como dia, mês e ano. Tecnicamente, esse formatador é `BrDateFormatter`."

"Se a tela estiver pequena, os cards aparecem em uma coluna. Se estiver em uma tela maior, o layout calcula quantas colunas cabem e usa uma grade flexível. Tecnicamente, essa adaptação vem de `AppLayout` e `AppStyles`, que centralizam regras de responsividade e espaçamento."

### O que acontece no fundo

- Uma função monta os cards depois que os eventos chegam | `_buildEventHighlights()` recebe a lista carregada.
- O layout calcula se cabe uma ou mais colunas | `AppLayout.eventColumnsForWidth()` decide a quantidade de colunas.
- A data é convertida para o padrão brasileiro | `BrDateFormatter.formatShort()` formata `dataEntrega`.
- Um componente reutilizável mostra cada evento | `EventCard` renderiza título, data, descrição e menu de ações.
- Se um item está sendo alterado ou excluído, ele mostra carregamento | o card troca o menu por um spinner quando `isBusy` é `true`.

---

## 7. Navegação para "Ver tudo"

### O que mostrar

Clicar em "Ver tudo" na tela inicial.

### Fala sugerida

"Quando eu clico em Ver tudo, o app muda da tela inicial para a lista completa de eventos. Tecnicamente, essa navegação usa uma rota nomeada: `Navigator.pushNamed(context, eventsRoute)`."

"A diferença aqui é que a tela inicial pediu só três eventos, mas a lista completa usa a busca sem limitar a quantidade. Então ela carrega todos os eventos do usuário logado. Tecnicamente, essa chamada é `EventService.listEventos()` sem `limit`."

"Assim que a tela abre, ela dispara uma função para carregar os eventos. Tecnicamente, o `initState` chama `_loadEvents()`. Enquanto os dados estão vindo da API, a tela mostra um loading. Se houver erro, aparece a mensagem e um botão de tentar novamente. Se a lista estiver vazia, aparece a mensagem de nenhum evento cadastrado. Se der certo, os cards são renderizados."

### O que acontece no fundo

- O botão abre a tela da lista completa | "Ver tudo" chama `Navigator.pushNamed(context, eventsRoute)`.
- A lista começa a buscar dados assim que abre | `EventListScreen.initState()` chama `_loadEvents()`.
- A tela entra em modo de carregamento e limpa erro antigo | `_isLoading` vira `true` e `_error` é limpo.
- O serviço busca todos os eventos do usuário logado | `EventService.listEventos()` busca eventos da sessão.
- A API recebe só o id do usuário, sem limite de quantidade | `ApiService.listarEventos()` faz `GET /listar_eventos?usuario_id=...`.
- Quando a resposta chega, a tela guarda os eventos e tira o loading | atualiza `_events` e desliga `_isLoading`.

---

## 8. Estados da lista completa

### O que mostrar

Mostrar a lista completa de eventos. Se aplicável, mencionar os estados mesmo que eles não apareçam na execução.

### Fala sugerida

"Essa tela foi pensada para quatro estados principais. Primeiro, carregamento, enquanto a requisição está acontecendo. Segundo, erro, caso a API falhe ou a resposta não venha como esperado. Terceiro, lista vazia, quando o usuário ainda não cadastrou nada. E quarto, sucesso, que é o estado em que os cards aparecem."

"Isso é importante porque uma tela real não pode depender só do caminho feliz. Ela precisa responder bem quando a rede demora, quando o servidor falha ou quando ainda não há dados."

### O que acontece no fundo

- Uma função decide qual versão da tela aparece | `_buildBody()` escolhe o estado visual.
- Enquanto carrega, aparece um indicador | `_isLoading == true` mostra `CircularProgressIndicator`.
- Se der erro, aparece mensagem e opção de tentar de novo | `_error != null` mostra texto e botão "Tentar novamente".
- Se não houver eventos, aparece o estado vazio | `_events.isEmpty` mostra "Nenhum evento cadastrado.".
- Se houver eventos, a tela monta a lista ou grade | `_buildEventsContent()` renderiza o conteúdo.

### Trecho direto do código

```dart
Widget _buildBody() {
  if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (_error != null) {
    return AppLayout(
      width: AppLayoutWidth.content,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error!, textAlign: TextAlign.center),
          AppStyles.gap12,
          OutlinedButton(
            onPressed: _loadEvents,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  if (_events.isEmpty) {
    return const AppLayout(
      width: AppLayoutWidth.content,
      child: Center(child: Text('Nenhum evento cadastrado.')),
    );
  }

  return _buildEventsContent();
}
```

---

## 9. Voltar da lista para a home

### O que mostrar

Voltar da lista completa para a tela inicial.

### Fala sugerida

"Ao voltar, a navegação normal do Flutter remove a tela de lista e retorna para a home. A home fica registrada em um observador de navegação, então ela sabe quando outra tela que estava por cima foi fechada. Tecnicamente, esse observador é o `RouteObserver`."

"Quando isso acontece, uma função de retorno é chamada e a tela recarrega os destaques. Tecnicamente, o método `didPopNext()` executa `_refreshHighlights()`. Ou seja, quando eu volto para a home, ela pode buscar novamente os três destaques para refletir alguma alteração recente."

### O que acontece no fundo

- A home fica atenta quando outra tela fecha por cima dela | a tela inicial usa `RouteAware`.
- Um observador registra essa tela na navegação | `appRouteObserver.subscribe()` registra a home.
- Quando a lista fecha e a home volta a aparecer, uma função é disparada | `didPopNext()` executa.
- A busca dos destaques é refeita | `_refreshHighlights()` recria `_highlightsFuture`.
- A home puxa novamente só os três eventos principais | chama `listEventos(limit: 3)`.

---

## 10. Abrir cadastro de evento pela home

### O que mostrar

Clicar em "Adicionar novo".

### Fala sugerida

"Agora vou cadastrar um novo evento. Ao clicar em Adicionar novo, o app abre a tela de cadastro. Tecnicamente, ele navega para a rota de cadastro usando `Navigator.pushNamed(context, createEventRoute)`."

"A tela que abriu é a tela de cadastro de evento. Tecnicamente, ela é `CadastrarEventoScreen`. Ela serve para duas situações: cadastro e edição. Quando recebe um evento existente, entra em modo de edição. Quando não recebe evento nenhum, como agora, entra em modo de cadastro."

"Repare que os campos estão vazios e o botão principal aparece como Salvar. Isso acontece porque a tela não recebeu nenhum evento para editar. Tecnicamente, `widget.evento` é nulo e `_isEditing` é falso."

### O que acontece no fundo

- O botão abre a tela de cadastro | "Adicionar novo" chama `Navigator.pushNamed(context, createEventRoute)`.
- A tela abre vazia, sem evento selecionado | a rota cria `CadastrarEventoScreen()` sem evento.
- O app entende que é um cadastro novo | `_isEditing` retorna `false`.
- A interface mostra os campos principais | monta título, descrição e data.
- O botão indica criação, não edição | o botão principal mostra "Salvar".

---

## 11. Preenchimento do formulário

### O que mostrar

Preencher título, descrição e abrir o seletor de data.

### Fala sugerida

"O formulário tem três informações principais: título, descrição da atividade e data de entrega. Os campos de texto usam controllers para guardar temporariamente o que foi digitado."

"A data é escolhida por um calendário do próprio Flutter, configurado em português do Brasil. Tecnicamente, esse calendário é o `showDatePicker` com locale `pt_BR`. Quando eu escolho a data, o app guarda esse valor e atualiza o texto visível no campo."

"O usuário vê a data em formato amigável, mas na hora de enviar para a API o app converte para um formato mais técnico, usado na comunicação entre sistemas. Esse formato é `yyyy-MM-dd`."

### O que acontece no fundo

- O app guarda temporariamente o texto do título | usa `_disciplinaController`.
- O app guarda temporariamente o texto da descrição | usa `_atividadeController`.
- O campo de data mostra a data escolhida | usa `_dateController`.
- Ao tocar na data, abre o calendário | `_pickDate()` chama `showDatePicker()`.
- A data escolhida fica guardada como data real, não só texto | `_selectedDate` guarda o `DateTime`.
- O texto visível é atualizado no padrão brasileiro | `_syncSelectedDate()` usa `BrDateFormatter.formatShort()`.
- Antes de enviar, a data vira formato aceito pela API | `_toApiDate()` converte para `yyyy-MM-dd`.

### Trecho direto do código

```dart
final picked = await showDatePicker(
  context: context,
  locale: const Locale('pt', 'BR'),
  initialDate: _selectedDate,
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
);

String _toApiDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
```

---

## 12. Validação do cadastro

### O que mostrar

Opcional: tentar salvar com algum campo vazio. Depois preencher corretamente.

### Fala sugerida

"Antes de salvar, o app valida os campos obrigatórios. Se o título ou a descrição estiver vazio, ele mostra a mensagem no próprio formulário e não chama a API."

"Essa validação evita enviar dados incompletos para o servidor e melhora a experiência, porque o usuário recebe o aviso imediatamente."

### O que acontece no fundo

- Ao tentar salvar, o app fecha o teclado para focar no envio | `_saveEvent()` chama `FocusScope.of(context).unfocus()`.
- Antes de enviar, todos os campos passam pela validação | o formulário usa `_formKey.currentState.validate()`.
- Campos obrigatórios precisam ter texto | `_validateRequired()` verifica valores vazios.
- Se faltar alguma informação, nada é enviado ao servidor | `_saveEvent()` termina sem chamar serviço.

---

## 13. Salvar novo evento

### O que mostrar

Com os campos preenchidos, clicar em "Salvar".

### Fala sugerida

"Agora, ao clicar em Salvar, o botão entra em estado de carregamento e os botões são desabilitados. O app remove espaços extras do começo e do fim dos textos e decide qual operação chamar. Como estamos criando um evento novo, ele usa uma função de serviço para salvar o evento. Tecnicamente, essa chamada é `EventService.salvarEvento()`."

"Essa camada de serviço primeiro busca a sessão atual. Isso é necessário porque todo evento precisa estar vinculado ao usuário logado. Depois, outra classe monta a chamada para a API, enviando o id do usuário, o título, a descrição e a data no formato esperado. Tecnicamente, isso passa por `EventService` e `ApiService.salvarEvento()`."

"A API recebe uma requisição para salvar o evento. Tecnicamente, é um `POST` para o endpoint `/salvar_evento`. Se a resposta vier com sucesso, a tela mostra uma mensagem de confirmação e fecha o formulário. Essa mensagem é um `SnackBar`, e o fechamento acontece com `Navigator.pop(context, true)`."

### O que acontece no fundo

- A tela bloqueia o formulário enquanto salva | `_isSaving` vira `true`.
- O botão principal mostra que está processando | exibe spinner no botão.
- O serviço confirma qual usuário está logado antes de salvar | `EventService.salvarEvento()` exige sessão válida.
- Uma classe de API envia o novo evento ao servidor | `ApiService.salvarEvento()` faz `POST /salvar_evento`.
- Os dados vão em JSON com usuário, título, descrição e data | corpo contém `usuario_id`, `nome_disciplina`, `descricao_atividade` e `data_entrega`.
- A resposta do servidor é conferida | `decodeApiResponse()` valida a resposta.
- Se der certo, o usuário recebe confirmação | a tela mostra `SnackBar`.
- O formulário fecha e volta para a tela anterior | `Navigator.pop(context, true)`.

### Trecho direto do código

```dart
if (_isEditing) {
  final evento = widget.evento;
  if (evento == null) {
    throw const FormatException('Evento ausente para edicao.');
  }

  await _eventService.editarEvento(
    eventoId: evento.id,
    nomeDisciplina: nomeDisciplina,
    descricaoAtividade: descricaoAtividade,
    dataEntrega: _toApiDate(_selectedDate),
  );
} else {
  await _eventService.salvarEvento(
    nomeDisciplina: nomeDisciplina,
    descricaoAtividade: descricaoAtividade,
    dataEntrega: _toApiDate(_selectedDate),
  );
}

final response = await _client.post(
  buildApiUri('/salvar_evento'),
  headers: const {'Content-Type': 'application/json'},
  body: jsonEncode({
    'usuario_id': usuarioId,
    'nome_disciplina': nomeDisciplina,
    'descricao_atividade': descricaoAtividade,
    'data_entrega': dataEntrega,
  }),
);
```

---

## 14. Atualização automática ao voltar do cadastro

### O que mostrar

Depois de salvar, observar a volta para a home ou para a lista.

### Fala sugerida

"Depois que o formulário fecha, a tela anterior volta a aparecer. Se eu tinha vindo da home, ela percebe esse retorno e recarrega os três destaques. Se eu tinha vindo da lista completa, a lista também percebe o retorno e busca os eventos de novo. Tecnicamente, isso usa `RouteAware`; na lista, a função chamada de novo é `_loadEvents()`."

"Isso é o que faz o evento recém-cadastrado aparecer sem precisar fechar e abrir o aplicativo. A navegação e o recarregamento estão conectados."

### O que acontece no fundo

- O formulário avisa que terminou e fecha | `Navigator.pop(context, true)`.
- A tela anterior volta a ficar visível | a navegação retorna o controle para ela.
- Uma função de retorno é disparada automaticamente | `didPopNext()` roda na tela anterior.
- Se a tela anterior for a home, ela recarrega os destaques | `_refreshHighlights()` busca novamente os três eventos.
- Se a tela anterior for a lista, ela recarrega tudo | `_loadEvents()` busca todos os eventos.

---

## 15. Editar evento pela home ou pela lista

### O que mostrar

Clicar em um card ou abrir o menu de ações e escolher "Editar".

### Fala sugerida

"Para editar, posso tocar diretamente no card ou usar o menu de ações e escolher Editar. O card chama uma função que abre a mesma tela de cadastro, mas agora passando o evento selecionado. Tecnicamente, esse objeto é um `Evento`."

"Como a tela recebe um evento, ela entra em modo de edição. Assim que abre, ela preenche automaticamente os campos com o título, a descrição e a data existentes. Tecnicamente, isso acontece no `initState`, que preenche os controllers e a data selecionada."

"Também dá para perceber que o título da tela muda para Editar evento e o botão principal muda para Atualizar. Tecnicamente, essa mudança vem da variável `_isEditing`."

### O que acontece no fundo

- Tocar no card ou escolher Editar abre a edição | `EventCard.onTap` ou o menu chama `_editEvent(event)`.
- A mesma tela de formulário abre recebendo o evento escolhido | `_editEvent()` abre `CadastrarEventoScreen(evento: event)`.
- A tela entende que agora é edição, não cadastro | `_isEditing` retorna `true`.
- Os campos já aparecem preenchidos com os dados atuais | `initState()` copia dados do evento para os controllers.
- A data atual do evento também é carregada | `_selectedDate` recebe `evento.dataEntrega`.
- A interface muda os textos para edição | mostra "Editar evento" e botão "Atualizar".

### Trecho direto do código

```dart
bool get _isEditing => widget.evento != null;

void initState() {
  super.initState();
  if (_isEditing) {
    final evento = widget.evento;
    if (evento != null) {
      _disciplinaController.text = evento.nomeDisciplina;
      _atividadeController.text = evento.descricaoAtividade;
      _selectedDate = evento.dataEntrega;
    }
  }
  _syncSelectedDate();
}
```

---

## 16. Atualizar evento existente

### O que mostrar

Alterar título, descrição ou data e clicar em "Atualizar".

### Fala sugerida

"Agora, quando eu altero o evento e clico em Atualizar, a validação é a mesma do cadastro. A diferença está na operação chamada depois da validação. Como a tela está em modo de edição, ela usa uma função de serviço para editar o evento existente. Tecnicamente, essa função é `EventService.editarEvento()`."

"Essa chamada envia o id do evento, o id do usuário logado e os novos dados. Uma classe de API transforma isso em uma requisição `POST` para o endpoint `/editar_evento`. Tecnicamente, essa parte fica em `ApiService.editarEvento()`."

"O uso do id do evento é o que permite a API saber exatamente qual registro deve ser alterado. O uso do id do usuário garante que a operação continue associada ao usuário autenticado."

"Quando a edição termina com sucesso, a tela mostra uma mensagem de confirmação e volta para a tela anterior. A tela anterior recarrega os dados e mostra o card já atualizado."

### O que acontece no fundo

- A tela percebe que está atualizando um evento existente | `_saveEvent()` detecta `_isEditing == true`.
- Uma função de serviço cuida da edição | a tela chama `EventService.editarEvento()`.
- O serviço confirma o usuário logado | `EventService` recupera a sessão local.
- A API recebe uma requisição para alterar o evento | `ApiService.editarEvento()` faz `POST /editar_evento`.
- O JSON identifica o evento, o usuário e os novos dados | contém `evento_id`, `usuario_id`, `nome_disciplina`, `descricao_atividade` e `data_entrega`.
- Se der certo, o usuário recebe confirmação | mostra `SnackBar` com "Evento atualizado com sucesso.".
- O formulário fecha e retorna para a tela anterior | `Navigator.pop(context, true)`.
- A tela anterior atualiza os dados automaticamente | `RouteAware` recarrega home ou lista.

---

## 17. Cancelar cadastro ou edição

### O que mostrar

Abrir o formulário e clicar em "Cancelar".

### Fala sugerida

"Se eu clicar em Cancelar, o app simplesmente fecha o formulário. Tecnicamente, ele usa `Navigator.pop(context)`. Nenhuma chamada para a API é feita, porque o usuário desistiu da operação."

"Esse comportamento separa bem intenção de navegação e intenção de salvar. Só o botão Salvar ou Atualizar executa o serviço de eventos."

### O que acontece no fundo

- O botão apenas fecha a tela atual | Cancelar chama `Navigator.pop(context)`.
- A função de salvar não roda | `_saveEvent()` não é executado.
- O app não fala com o servidor | nenhum endpoint é chamado.
- A tela anterior permanece como estava | os dados não são alterados.

---

## 18. Remover evento

### O que mostrar

No card de um evento, abrir o menu e escolher "Excluir".

### Fala sugerida

"Para remover um evento, eu abro o menu do card e escolho Excluir. Antes de apagar, o aplicativo abre uma caixa de confirmação. Isso evita exclusões acidentais."

"Esse diálogo vem de uma função reutilizável. Tecnicamente, ela se chama `showDeleteEventDialog`. Ela recebe o título do evento e pergunta se o usuário realmente deseja excluir aquele item."

"Se eu cancelar, nada acontece. Se eu confirmar, o card entra em estado ocupado: o menu é substituído por um spinner e as ações ficam bloqueadas para impedir clique duplo durante a exclusão."

### O que acontece no fundo

- O menu do card identifica que a ação escolhida foi excluir | `EventCard` dispara `EventCardAction.delete`.
- A tela inicia o fluxo de remoção daquele evento | chama `_deleteEvent(event)`.
- Antes de apagar, aparece uma confirmação | `_deleteEvent()` chama `showDeleteEventDialog()`.
- Se o usuário cancelar, o app para ali | a função retorna sem chamar serviço.
- Se confirmar, o app marca aquele evento como ocupado | o id entra em `_busyEventIds`.
- O card mostra que a exclusão está em andamento | exibe `CircularProgressIndicator` no lugar do menu.

### Trecho direto do código

```dart
final shouldDelete = await showDialog<bool>(
  context: context,
  builder: (context) {
    return AlertDialog(
      title: const Text('Excluir evento'),
      content: Text('Deseja excluir "$eventTitle" da sua lista?'),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Excluir'),
        ),
      ],
    );
  },
);
```

---

## 19. Confirmar exclusão

### O que mostrar

Confirmar a exclusão no diálogo.

### Fala sugerida

"Quando eu confirmo a exclusão, uma função de serviço remove o evento do usuário logado. Assim como nas outras operações, o app primeiro garante que existe uma sessão válida. Depois, uma classe de API envia uma requisição `POST` para o endpoint `/excluir_evento` com o id do evento e o id do usuário. Tecnicamente, isso passa por `EventService.excluirEvento()` e `ApiService.excluirEvento()`."

"Se a exclusão está acontecendo na tela inicial, depois do sucesso a home recarrega os três destaques. Isso é importante porque, ao remover um dos três, pode existir outro evento que agora precisa aparecer no lugar."

"Na lista completa, o comportamento é um pouco diferente: depois que a API confirma a exclusão, o evento é removido da lista local. Assim a interface responde rápido sem precisar esperar uma nova listagem completa."

"Nos dois casos, o usuário recebe uma mensagem dizendo que o evento foi excluído com sucesso. Tecnicamente, essa mensagem é um `SnackBar`. Se a API falhar, o app remove o estado ocupado do card e mostra a mensagem de erro."

### O que acontece no fundo

- O serviço confirma qual usuário está logado | `EventService.excluirEvento(eventoId: event.id)` recupera a sessão.
- A API recebe o pedido de exclusão | `ApiService.excluirEvento()` faz `POST /excluir_evento`.
- A requisição informa qual evento e qual usuário estão envolvidos | JSON contém `evento_id` e `usuario_id`.
- A resposta é conferida antes da tela mudar | `decodeApiResponse()` valida JSON e status HTTP.
- Na home, os três destaques são buscados de novo | `_highlightsFuture = _loadHighlights()`.
- Na lista completa, o item sai da lista local | `_events` é filtrado para remover o excluído.
- O card deixa de ficar ocupado | `_busyEventIds.remove(event.id)` libera o item.
- O usuário recebe feedback da operação | a tela mostra `SnackBar` de sucesso ou erro.

---

## 20. Navegação entre telas e rotas

### O que mostrar

Transitar entre login, home, lista, cadastro, edição e voltar.

### Fala sugerida

"A navegação do SafeRoute usa duas estratégias. Para telas principais, como login, home, lista e cadastro, existem caminhos fixos definidos em um arquivo central. Tecnicamente, são rotas nomeadas definidas no `main.dart`. Isso evita espalhar nomes de rota pelo código."

"Para edição de evento, o app usa uma navegação direta, porque precisa levar o evento selecionado junto para a tela de formulário. Tecnicamente, isso usa `MaterialPageRoute` passando um objeto `Evento`. Então, quando vou editar, a tela não abre vazia; ela recebe o evento selecionado e monta o formulário em cima dele."

"Também existem diferenças importantes entre os tipos de navegação. No login, o app substitui a tela de login pela home. Tecnicamente, usa `pushReplacementNamed`. No logout, ele limpa todo o histórico autenticado. Tecnicamente, usa `pushNamedAndRemoveUntil`. Já no cadastro, lista e edição, ele apenas abre uma tela por cima, porque faz sentido voltar para a tela anterior."

### O que acontece no fundo

- Os caminhos principais do app ficam definidos em um lugar só | `loginRoute`, `homeRoute`, `eventsRoute` e `createEventRoute` ficam em `main.dart`.
- Depois do login, o app troca a tela de login pela home | usa `Navigator.pushReplacementNamed(context, homeRoute)`.
- O botão Ver tudo empilha a lista completa sobre a home | usa `Navigator.pushNamed(context, eventsRoute)`.
- O botão Adicionar novo abre o formulário vazio | usa `Navigator.pushNamed(context, createEventRoute)`.
- A edição abre o formulário já com um evento escolhido | usa `Navigator.of(context).push(MaterialPageRoute(...))`.
- O logout limpa todo o histórico autenticado | usa `Navigator.pushNamedAndRemoveUntil(context, loginRoute, (route) => false)`.

### Trecho direto do código

```dart
const String loginRoute = '/login';
const String homeRoute = '/home';
const String eventsRoute = '/events';
const String createEventRoute = '/create-event';

routes: {
  loginRoute: (context) => const LoginPage(),
  homeRoute: (context) => const WelcomeScreen(),
  eventsRoute: (context) => const EventListScreen(),
  createEventRoute: (context) => const CadastrarEventoScreen(),
},
```

---

## 21. Logout

### O que mostrar

Clicar no ícone de logout no topo da tela inicial.

### Fala sugerida

"Para sair da conta, eu clico no ícone de logout. O app apaga os dados locais que identificavam o usuário logado. Tecnicamente, isso é feito por `SessionService.clearSession()`, que remove `usuario_id` e `usuario_email` do armazenamento local."

"Depois disso, ele volta para a tela de login limpando o histórico de telas autenticadas. Tecnicamente, essa navegação usa `pushNamedAndRemoveUntil`. Então, depois de sair, o usuário não consegue apertar voltar e acessar a home antiga."

"Na próxima vez que o app abrir, a tela de partida vai consultar a sessão novamente. Tecnicamente, essa tela é `AppStartScreen`. Como os dados locais foram apagados, ela vai mandar o usuário para o login."

### O que acontece no fundo

- O botão de sair chama uma função de logout | `_logout()` chama `SessionService.clearSession()`.
- Os dados locais da sessão são apagados | `SharedPreferences` remove `usuario_id` e `usuario_email`.
- O app volta para o login limpando as telas anteriores | a navegação limpa a pilha e abre `loginRoute`.
- O usuário não consegue voltar para a área logada pelo botão voltar | as telas autenticadas saem do histórico.

---

## 22. Tratamento de erro em eventos

### O que mostrar

Se acontecer erro real de API, usar como exemplo. Se não acontecer, apenas explicar rapidamente.

### Fala sugerida

"Nas operações de evento, o app também trata falhas. Se a sessão não existir, uma camada de serviço mostra que o usuário precisa fazer login novamente. Tecnicamente, isso vem do `EventService`. Se a API retornar erro HTTP ou JSON inválido, uma função central transforma isso em uma exceção controlada. Tecnicamente, essa função é `decodeApiResponse`."

"Com isso, a tela não quebra de forma inesperada. Ela mostra mensagem de erro, botão para tentar de novo quando faz sentido, ou uma mensagem rápida quando a falha acontece em uma ação pontual como salvar, editar ou excluir. Tecnicamente, essa mensagem rápida é um `SnackBar`."

### O que acontece no fundo

- Antes de mexer em eventos, o app confere se existe usuário logado | `EventService._requireSession()` impede operações sem sessão.
- A resposta do servidor é conferida antes de ser usada | `decodeApiResponse()` valida corpo JSON e status HTTP.
- O app verifica se a própria API marcou a operação como sucesso | `ApiService` confere se `status` veio como `sucesso`.
- Falhas viram erros controlados pelo app | erros são convertidos em `ApiException`.
- As telas mostram mensagens compreensíveis ao usuário | capturam `ApiException` e exibem feedback amigável.

---

## 23. Como os dados da API viram cards na tela

### O que mostrar

Apontar para um card e explicar os dados exibidos.

### Fala sugerida

"Cada card que aparece aqui começou como um item JSON vindo da API. Uma classe de API recebe esse JSON e transforma os dados em um objeto do Dart. Tecnicamente, o `ApiService` chama `Evento.fromJson()`."

"Esse objeto valida campos obrigatórios. Ele aceita algumas variações de nome para o id, como `evento_id`, `id_evento` ou `id`, mas exige que título, descrição e data venham preenchidos."

"Depois disso, a tela não precisa saber como era o JSON original. Ela trabalha com propriedades claras do evento, como id, disciplina, descrição e data de entrega. Tecnicamente, essas propriedades são `event.id`, `event.nomeDisciplina`, `event.descricaoAtividade` e `event.dataEntrega`. Isso deixa o código da interface mais limpo e mais seguro."

### O que acontece no fundo

- O servidor devolve uma lista com os eventos | a API retorna uma lista em `eventos`.
- Uma classe de API percorre cada item recebido | `ApiService` percorre essa lista.
- Cada item é preparado para leitura pelo Dart | vira `Map<String, dynamic>`.
- O app valida e organiza os campos do evento | `Evento.fromJson()` valida e converte os dados.
- A tela recebe uma lista de objetos prontos para uso | recebe `List<Evento>`.
- O card só precisa exibir dados já tratados | `EventCard` recebe os dados prontos para exibição.

---

## 24. Responsividade e visual

### O que mostrar

Se estiver no web, redimensionar a janela ou comentar sobre celular e desktop.

### Fala sugerida

"O mesmo app pode rodar em celular, web e desktop. Por isso, o layout não usa sempre uma largura fixa. O SafeRoute tem uma camada de layout e constantes visuais para manter tudo padronizado. Tecnicamente, isso fica em `AppLayout` e `AppStyles`."

"Na prática, isso controla espaçamento, largura máxima de formulários, largura de listas, quantidade de colunas dos cards e comportamento dos botões. Em tela estreita, os botões ficam empilhados. Em tela mais larga, eles ficam lado a lado."

"O tema também é centralizado em uma classe própria, usando Material Design 3. Tecnicamente, essa classe é `AppTheme`. Isso faz com que campos, botões, cards, snackbars e cores sigam o mesmo padrão em todo o aplicativo."

### O que acontece no fundo

- Uma camada de layout controla margens, largura e rolagem | `AppLayout` aplica padding, largura máxima e scroll.
- Os espaçamentos e tamanhos ficam padronizados | `AppStyles` centraliza medidas recorrentes.
- A tela consegue reagir ao espaço disponível | `LayoutBuilder` adapta widgets à largura.
- O visual do app fica consistente em todas as telas | `AppTheme` padroniza Material 3, tema claro, escuro e cores dinâmicas.

---

## 25. Fechamento da demonstração

### O que mostrar

Voltar para a home ou deixar a lista aberta com os eventos atualizados.

### Fala sugerida

"Então, resumindo a demonstração: o SafeRoute não é só uma tela estática. Ele tem autenticação, sessão local, navegação organizada, listagem de eventos, cadastro, edição, exclusão, atualização automática ao voltar de telas, validação de formulário, tratamento de erro e layout responsivo."

"Quando eu faço login, o app chama a API e salva a sessão local. Quando eu entro na home, ele busca três eventos de destaque. Quando eu vou para Ver tudo, ele busca a lista completa. Quando eu cadastro, edito ou excluo, ele envia os dados certos para a API e atualiza a interface. E quando eu saio, ele limpa a sessão e remove o acesso às telas autenticadas."

"A arquitetura separa bem as responsabilidades: as telas cuidam da interface e do estado visual, os serviços cuidam das regras de comunicação e sessão, os models representam os dados, e a camada core concentra tema, layout, configuração e formatação. Essa separação facilita manutenção, testes e evolução futura do projeto."

---

## Versão curta para falar se o tempo estiver apertado

"O SafeRoute abre verificando se existe sessão salva localmente. Se não houver sessão, ele mostra o login. No login, os campos são validados antes da chamada à API. Com credenciais válidas, uma classe de autenticação envia os dados para o endpoint de login | `AuthService` envia `POST /auth`, transforma a resposta em `AuthResponse` e salva `usuario_id` e e-mail em `SharedPreferences`."

"Depois disso, a home carrega três eventos em destaque. Uma camada de serviço busca o usuário da sessão e uma classe de API chama a listagem com limite de três itens | `EventService.listEventos(limit: 3)` -> `ApiService` chama `/listar_eventos` com `usuario_id` e `limit=3`. A resposta vira uma lista de eventos, e os cards aparecem na tela com data formatada em português."

"Em Ver tudo, o app navega para a lista completa e busca todos os eventos do usuário, sem limite. Para cadastrar, ele abre o formulário vazio, valida título, descrição e data, converte a data para o formato da API e envia o novo evento | `yyyy-MM-dd` e `POST /salvar_evento`. Para editar, abre o mesmo formulário preenchido com o evento escolhido e envia a atualização | `POST /editar_evento`. Para excluir, mostra uma confirmação e depois envia o pedido de remoção | `POST /excluir_evento`."

"Quando uma tela de cadastro ou edição fecha, a tela anterior percebe o retorno e recarrega os dados | `RouteAware`. Assim, as mudanças aparecem sem reiniciar o app. No logout, o app limpa a sessão local e remove o histórico de telas autenticadas, voltando para o login."

---

## Ordem recomendada para apresentar ao vivo

1. Abrir o app sem sessão e mostrar login.
2. Explicar validação dos campos.
3. Fazer login com sucesso.
4. Mostrar a home carregando três eventos.
5. Explicar `listEventos(limit: 3)`.
6. Clicar em Ver tudo.
7. Explicar listagem completa sem limite.
8. Voltar para a home.
9. Clicar em Adicionar novo.
10. Preencher título, descrição e data.
11. Salvar novo evento.
12. Mostrar que a tela anterior atualiza.
13. Editar um evento existente.
14. Alterar dados e atualizar.
15. Excluir um evento com confirmação.
16. Mostrar feedback de sucesso.
17. Fazer logout.
18. Explicar que a sessão foi apagada e a pilha autenticada foi removida.

---

## Cola simples + técnica dos principais pontos

- Ao abrir, o app decide se mostra login ou home | `AppStartScreen` -> `SessionService.hasSession()`.
- Ao entrar, o app guarda os dados mínimos do usuário | `SessionService.saveUserSession()`.
- Ao sair, o app apaga a sessão local | `SessionService.clearSession()`.
- No login, uma classe envia e-mail e senha para o endpoint de autenticação | `AuthService.signIn()` -> `AuthService.login()` -> `POST /auth`.
- Na home, o app busca só três eventos para destaque | `WelcomeScreen._loadHighlights()` -> `EventService.listEventos(limit: 3)`.
- Na lista completa, o app busca todos os eventos do usuário | `EventListScreen._loadEvents()` -> `EventService.listEventos()`.
- Para criar evento, o formulário envia os novos dados para a API | `CadastrarEventoScreen._saveEvent()` -> `EventService.salvarEvento()` -> `POST /salvar_evento`.
- Para editar evento, o formulário envia o id do evento e os dados atualizados | `CadastrarEventoScreen._saveEvent()` -> `EventService.editarEvento()` -> `POST /editar_evento`.
- Para excluir evento, a tela confirma e envia o pedido de remoção | `_deleteEvent()` -> `EventService.excluirEvento()` -> `POST /excluir_evento`.
- Antes de apagar, o app mostra uma confirmação | `showDeleteEventDialog()`.
- Ao voltar de cadastro ou edição, a tela anterior atualiza os dados | `RouteAware.didPopNext()`.
- Para montar a URL final da API, o app junta base, caminho e parâmetros | `buildApiUri()`.
- Para validar respostas, o app confere JSON e erro HTTP | `decodeApiResponse()`.
- Para usar dados da API na tela, o JSON vira objeto de evento | `Evento.fromJson()`.
- Para mostrar datas ao usuário, o app usa formato brasileiro | `BrDateFormatter.formatShort()`.