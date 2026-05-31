import 'package:flutter/material.dart';

import '../core/app_styles.dart';
import '../core/br_date_formatter.dart';
import '../main.dart';
import '../models/evento.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import 'tela_cadastrar_evento.dart';

enum _EventAction { editar, excluir }

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> with RouteAware {
  final _apiService = ApiService();
  final Set<int> _busyEventIds = <int>{};
  PageRoute<dynamic>? _route;
  bool _isLoading = true;
  String? _error;
  List<Evento> _events = const [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
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
  void didPopNext() {
    _loadEvents();
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final usuarioId = await SessionService.getUserId();
      if (usuarioId == null) {
        throw ApiException('Sessão não encontrada. Faça login novamente.');
      }

      final events = await _apiService.listarEventos(usuarioId: usuarioId);
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

  Future<void> _editEvent(Evento event) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CadastrarEventoScreen(evento: event),
      ),
    );
  }

  Future<void> _deleteEvent(Evento event) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir evento'),
          content: Text(
            'Deseja excluir "${event.nomeDisciplina}" da sua lista?',
          ),
          actionsOverflowButtonSpacing: 12,
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: AppStyles.dialogActionMinimumSize,
                padding: AppStyles.buttonPadding,
              ),
              child: const Text('Cancelar'),
            ),
            AppStyles.gapWidth12,
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                minimumSize: AppStyles.dialogActionMinimumSize,
                padding: AppStyles.buttonPadding,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    setState(() {
      _busyEventIds.add(event.id);
    });

    try {
      final usuarioId = await SessionService.getUserId();
      if (usuarioId == null) {
        throw ApiException('Sessão não encontrada. Faça login novamente.');
      }

      final deletedEventId = await _apiService.excluirEvento(
        eventoId: event.id,
        usuarioId: usuarioId,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Barra superior da tela com o título da listagem.
        title: const Text('Lista de eventos'),
      ),
      // Corpo principal com estados de carregamento, erro, vazio e lista.
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      // Exibido enquanto os eventos estão sendo buscados na API.
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      // Exibido quando ocorre falha na leitura de eventos.
      return Center(
        child: Padding(
          padding: AppStyles.pagePadding,
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
        ),
      );
    }

    if (_events.isEmpty) {
      // Exibido quando o usuário ainda não possui eventos cadastrados.
      return const Center(child: Text('Nenhum evento cadastrado.'));
    }

    // Lista completa de eventos em ordem retornada pela API.
    return ListView.builder(
      padding: AppStyles.listPadding,
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        final isBusy = _busyEventIds.contains(event.id);
        return Padding(
          padding: AppStyles.bottomPadding16,
          child: _EventCard(
            date: 'Até ${BrDateFormatter.formatShort(event.dataEntrega)}',
            title: event.nomeDisciplina,
            description: event.descricaoAtividade,
            isBusy: isBusy,
            onTap: isBusy ? null : () => _editEvent(event),
            onSelectedAction: (action) {
              switch (action) {
                case _EventAction.editar:
                  _editEvent(event);
                case _EventAction.excluir:
                  _deleteEvent(event);
              }
            },
          ),
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final String date;
  final String title;
  final String description;
  final bool isBusy;
  final VoidCallback? onTap;
  final ValueChanged<_EventAction>? onSelectedAction;

  const _EventCard({
    required this.date,
    required this.title,
    required this.description,
    this.isBusy = false,
    this.onTap,
    this.onSelectedAction,
  });

  @override
  Widget build(BuildContext context) {
    // Card padrão usado para apresentar cada evento da lista.
    return Card(
      child: ListTile(
        enabled: !isBusy,
        onTap: onTap,
        contentPadding: AppStyles.cardPadding,
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: AppStyles.titleSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: AppStyles.topPadding8,
          child: Text('$date\n$description'),
        ),
        isThreeLine: true,
        trailing: isBusy
            ? const SizedBox(
                height: AppStyles.busyIndicatorSize,
                width: AppStyles.busyIndicatorSize,
                child: CircularProgressIndicator(
                  strokeWidth: AppStyles.busyIndicatorStrokeWidth,
                ),
              )
            : PopupMenuButton<_EventAction>(
                tooltip: 'Ações do evento',
                onSelected: onSelectedAction,
                itemBuilder: (context) => const [
                  PopupMenuItem<_EventAction>(
                    value: _EventAction.editar,
                    child: Text('Editar'),
                  ),
                  PopupMenuItem<_EventAction>(
                    value: _EventAction.excluir,
                    child: Text('Excluir'),
                  ),
                ],
              ),
      ),
    );
  }
}
