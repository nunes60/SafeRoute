import 'package:flutter/material.dart';

import '../core/app_styles.dart';
import '../core/br_date_formatter.dart';
import '../main.dart';
import '../models/evento.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import 'tela_cadastrar_evento.dart';

enum _HighlightAction { editar, excluir }

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with RouteAware {
  final _apiService = ApiService();
  final Set<int> _busyEventIds = <int>{};
  PageRoute<dynamic>? _route;
  late Future<List<Evento>> _highlightsFuture;

  @override
  void initState() {
    super.initState();
    _highlightsFuture = _loadHighlights();
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
    _refreshHighlights();
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  Future<List<Evento>> _loadHighlights() async {
    final usuarioId = await SessionService.getUserId();
    if (usuarioId == null) {
      throw ApiException('Sessão não encontrada. Faça login novamente.');
    }

    return _apiService.listarEventos(usuarioId: usuarioId, limit: 3);
  }

  void _refreshHighlights() {
    if (!mounted) return;
    setState(() {
      _highlightsFuture = _loadHighlights();
    });
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
          actions: [
            Padding(
              padding: AppStyles.dialogActionEndPadding,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: AppStyles.buttonMinimumSize,
                  padding: AppStyles.buttonPadding,
                ),
                child: const Text('Cancelar'),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                minimumSize: AppStyles.buttonMinimumSize,
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

      await _apiService.excluirEvento(eventoId: event.id, usuarioId: usuarioId);

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

  Future<void> _logout() async {
    await SessionService.clearSession();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, loginRoute, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Barra superior com título e ação de logout.
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
        child: Padding(
          padding: AppStyles.pagePadding,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho principal da tela inicial.
                Text(
                  'Boas-vindas',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: AppStyles.headerSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppStyles.gap8,
                Text(
                  'Confira seus destaques abaixo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: AppStyles.subtitleSize,
                  ),
                ),
                AppStyles.gap24,
                // Bloco que carrega os 3 próximos eventos via API.
                FutureBuilder<List<Evento>>(
                  future: _highlightsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      // Estado de carregamento dos destaques.
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      // Estado de erro com opção de nova tentativa.
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Não foi possível carregar os destaques.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          AppStyles.gap8,
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _highlightsFuture = _loadHighlights();
                              });
                            },
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      );
                    }

                    final events = snapshot.data ?? const [];
                    if (events.isEmpty) {
                      // Estado vazio quando não há eventos próximos.
                      return const Text(
                        'Nenhum compromisso próximo encontrado.',
                      );
                    }

                    // Lista visual dos cards de destaque.
                    return Column(
                      children: [
                        for (final event in events)
                          Padding(
                            padding: AppStyles.bottomPadding16,
                            child: _buildHighlightCard(
                              event: event,
                              date:
                                  'Até ${BrDateFormatter.formatShort(event.dataEntrega)}',
                              title: event.nomeDisciplina,
                              description: event.descricaoAtividade,
                              isBusy: _busyEventIds.contains(event.id),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                AppStyles.gap32,
                // Navega para a listagem completa de eventos.
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, eventsRoute);
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('Ver tudo'),
                ),
                AppStyles.gap12,
                // Navega para o formulário de cadastro de evento.
                FilledButton.icon(
                  onPressed: () async {
                    await Navigator.pushNamed(context, createEventRoute);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Adicionar novo'),
                ),
                AppStyles.gap24,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightCard({
    required Evento event,
    required String date,
    required String title,
    required String description,
    required bool isBusy,
  }) {
    // Card padrão para representar um compromisso em destaque.
    return Card(
      child: ListTile(
        enabled: !isBusy,
        onTap: isBusy ? null : () => _editEvent(event),
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
            : PopupMenuButton<_HighlightAction>(
                tooltip: 'Ações do evento',
                onSelected: (action) {
                  switch (action) {
                    case _HighlightAction.editar:
                      _editEvent(event);
                    case _HighlightAction.excluir:
                      _deleteEvent(event);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<_HighlightAction>(
                    value: _HighlightAction.editar,
                    child: Text('Editar'),
                  ),
                  PopupMenuItem<_HighlightAction>(
                    value: _HighlightAction.excluir,
                    child: Text('Excluir'),
                  ),
                ],
              ),
      ),
    );
  }
}
