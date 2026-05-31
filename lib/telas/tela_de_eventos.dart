import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_styles.dart';
import '../core/br_date_formatter.dart';
import '../main.dart';
import '../models/evento.dart';
import '../services/api_exception.dart';
import '../services/event_service.dart';
import 'tela_cadastrar_evento.dart';
import '../widgets/event_card.dart';

/// Exibe todos os eventos cadastrados pelo usuário.
class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  /// Cria o estado que gerencia a listagem e as ações sobre eventos.
  State<EventListScreen> createState() => _EventListScreenState();
}

/// Controla carregamento, atualização e exclusão na lista de eventos.
class _EventListScreenState extends State<EventListScreen> with RouteAware {
  final _eventService = EventService();
  final Set<int> _busyEventIds = <int>{};
  PageRoute<dynamic>? _route;
  bool _isLoading = true;
  String? _error;
  List<Evento> _events = const [];

  @override
  /// Inicia a busca dos eventos assim que a tela é criada.
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  /// Observa a rota atual para recarregar a lista ao retornar à tela.
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
  /// Rebusca os eventos quando o usuário volta da edição ou cadastro.
  void didPopNext() {
    _loadEvents();
  }

  @override
  /// Remove a assinatura do observador antes de destruir o estado.
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  /// Busca todos os eventos e atualiza os estados de carregamento e erro.
  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final events = await _eventService.listEventos();
      if (!mounted) return;
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro ao carregar eventos.';
        _isLoading = false;
      });
    }
  }

  /// Abre o formulário de edição para o evento informado.
  Future<void> _editEvent(Evento event) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CadastrarEventoScreen(evento: event),
      ),
    );
  }

  /// Confirma a exclusão e remove o evento da lista local.
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
      final deletedEventId = await _eventService.excluirEvento(
        eventoId: event.id,
      );

      if (!mounted) return;

      final removedEventId = deletedEventId == 0 ? event.id : deletedEventId;
      setState(() {
        _busyEventIds.remove(event.id);
        _events = _events
            .where((item) => item.id != removedEventId)
            .toList(growable: false);
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

  /// Monta um card com as ações disponíveis para um evento.
  Widget _buildEventCard(Evento event) {
    final isBusy = _busyEventIds.contains(event.id);

    return EventCard(
      date: 'Até ${BrDateFormatter.formatShort(event.dataEntrega)}',
      title: event.nomeDisciplina,
      description: event.descricaoAtividade,
      isBusy: isBusy,
      onTap: isBusy ? null : () => _editEvent(event),
      onSelectedAction: (action) {
        switch (action) {
          case EventCardAction.edit:
            _editEvent(event);
          case EventCardAction.delete:
            _deleteEvent(event);
        }
      },
    );
  }

  /// Decide entre lista simples ou grade de cards conforme a largura.
  Widget _buildEventsContent() {
    return AppLayout(
      width: AppLayoutWidth.list,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = AppLayout.eventColumnsForWidth(constraints.maxWidth);

          if (columns == 1) {
            return ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _events.length,
              separatorBuilder: (context, index) => AppStyles.gap16,
              itemBuilder: (context, index) {
                final event = _events[index];
                return _buildEventCard(event);
              },
            );
          }

          final itemWidth =
              (constraints.maxWidth - AppStyles.itemSpacing) / columns;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Wrap(
                spacing: AppStyles.itemSpacing,
                runSpacing: AppStyles.itemSpacing,
                children: [
                  for (final event in _events)
                    SizedBox(width: itemWidth, child: _buildEventCard(event)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  /// Monta a estrutura principal da tela de listagem.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de eventos')),
      body: _buildBody(),
    );
  }

  /// Exibe carregamento, erro, lista vazia ou o conteúdo principal.
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
}
