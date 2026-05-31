import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_styles.dart';
import '../core/br_date_formatter.dart';
import '../main.dart';
import '../models/evento.dart';
import '../services/api_exception.dart';
import '../services/event_service.dart';
import '../services/session_service.dart';
import 'tela_cadastrar_evento.dart';
import '../widgets/event_card.dart';

/// Mostra os destaques iniciais e atalhos principais do usuário.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  /// Cria o estado responsável por carregar e atualizar os destaques.
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

/// Controla o carregamento, atualização e ações dos eventos destacados.
class _WelcomeScreenState extends State<WelcomeScreen> with RouteAware {
  final _eventService = EventService();
  final Set<int> _busyEventIds = <int>{};
  PageRoute<dynamic>? _route;
  late Future<List<Evento>> _highlightsFuture;

  @override
  /// Inicia o carregamento dos eventos em destaque ao abrir a tela.
  void initState() {
    super.initState();
    _highlightsFuture = _loadHighlights();
  }

  @override
  /// Registra a tela no observador de rotas para reagir ao retorno.
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute && route != _route) {
      if (_route != null) {
        appRouteObserver.unsubscribe(this);
      }
      appRouteObserver.subscribe(this, route);
      _route = route;
    }
  }

  @override
  /// Atualiza os destaques quando o usuário volta para esta tela.
  void didPopNext() {
    _refreshHighlights();
  }

  @override
  /// Remove a assinatura do observador ao descartar a tela.
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  /// Busca os próximos eventos usados no bloco de destaques.
  Future<List<Evento>> _loadHighlights() async {
    return _eventService.listEventos(limit: 3);
  }

  /// Recarrega o Future dos destaques para refletir mudanças recentes.
  void _refreshHighlights() {
    if (!mounted) return;
    setState(() {
      _highlightsFuture = _loadHighlights();
    });
  }

  /// Abre o formulário de edição para o evento selecionado.
  Future<void> _editEvent(Evento event) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CadastrarEventoScreen(evento: event),
      ),
    );
  }

  /// Confirma e executa a exclusão de um evento destacado.
  Future<void> _deleteEvent(Evento event) async {
    final shouldDelete = await showDeleteEventDialog(
      context: context,
      eventTitle: event.nomeDisciplina,
    );

    if (!shouldDelete || !mounted) return;

    setState(() {
      _busyEventIds.add(event.id);
    });

    try {
      await _eventService.excluirEvento(eventoId: event.id);

      if (!mounted) return;
      setState(() {
        _busyEventIds.remove(event.id);
        _highlightsFuture = _loadHighlights();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento excluído com sucesso.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busyEventIds.remove(event.id);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busyEventIds.remove(event.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir o evento.')),
      );
    }
  }

  /// Limpa a sessão local e redireciona o usuário para o login.
  Future<void> _logout() async {
    await SessionService.clearSession();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, loginRoute, (route) => false);
  }

  /// Renderiza os cards dos eventos em uma ou duas colunas.
  Widget _buildEventHighlights(List<Evento> events) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = AppLayout.eventColumnsForWidth(constraints.maxWidth);

        if (columns == 1) {
          return Column(
            children: [
              for (final event in events)
                Padding(
                  padding: AppStyles.bottomPadding16,
                  child: EventCard(
                    date:
                        'Até ${BrDateFormatter.formatShort(event.dataEntrega)}',
                    title: event.nomeDisciplina,
                    description: event.descricaoAtividade,
                    isBusy: _busyEventIds.contains(event.id),
                    onTap: _busyEventIds.contains(event.id)
                        ? null
                        : () => _editEvent(event),
                    onSelectedAction: (action) {
                      switch (action) {
                        case EventCardAction.edit:
                          _editEvent(event);
                        case EventCardAction.delete:
                          _deleteEvent(event);
                      }
                    },
                  ),
                ),
            ],
          );
        }

        final itemWidth =
            (constraints.maxWidth - AppStyles.itemSpacing) / columns;

        return Wrap(
          spacing: AppStyles.itemSpacing,
          runSpacing: AppStyles.itemSpacing,
          children: [
            for (final event in events)
              SizedBox(
                width: itemWidth,
                child: EventCard(
                  date: 'Até ${BrDateFormatter.formatShort(event.dataEntrega)}',
                  title: event.nomeDisciplina,
                  description: event.descricaoAtividade,
                  isBusy: _busyEventIds.contains(event.id),
                  onTap: _busyEventIds.contains(event.id)
                      ? null
                      : () => _editEvent(event),
                  onSelectedAction: (action) {
                    switch (action) {
                      case EventCardAction.edit:
                        _editEvent(event);
                      case EventCardAction.delete:
                        _deleteEvent(event);
                    }
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  /// Exibe os atalhos para lista completa e novo cadastro.
  Widget _buildActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns =
            constraints.maxWidth >= AppStyles.actionWrapBreakpoint;
        final buttonWidth = useTwoColumns
            ? (constraints.maxWidth - AppStyles.actionSpacing) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: AppStyles.actionSpacing,
          runSpacing: AppStyles.actionSpacing,
          children: [
            SizedBox(
              width: buttonWidth,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, eventsRoute);
                },
                icon: const Icon(Icons.list),
                label: const Text('Ver tudo'),
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: FilledButton.icon(
                onPressed: () async {
                  await Navigator.pushNamed(context, createEventRoute);
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Adicionar novo'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  /// Monta a tela inicial com destaques, ações e logout.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Início'),
        actions: [
          IconButton(
            onPressed: _logout,
            tooltip: 'Encerrar sessão',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: AppLayout(
          width: AppLayoutWidth.content,
          scrollable: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Boas-vindas',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              AppStyles.gap8,
              Text(
                'Confira seus destaques abaixo',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              AppStyles.gap24,
              FutureBuilder<List<Evento>>(
                future: _highlightsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Não foi possível carregar os destaques.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        AppStyles.gap8,
                        OutlinedButton(
                          onPressed: _refreshHighlights,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    );
                  }

                  final events = snapshot.data ?? const [];
                  if (events.isEmpty) {
                    return const Text('Nenhum compromisso próximo encontrado.');
                  }

                  return _buildEventHighlights(events);
                },
              ),
              AppStyles.gap32,
              _buildActionButtons(),
              AppStyles.gap24,
            ],
          ),
        ),
      ),
    );
  }
}
