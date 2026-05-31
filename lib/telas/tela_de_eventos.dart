import 'package:flutter/material.dart';

import '../core/app_styles.dart';
import '../models/evento.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<Evento> _events = const [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
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
      return const Center(
        child: Text('Nenhum evento cadastrado.'),
      );
    }

    // Lista completa de eventos em ordem retornada pela API.
    return ListView.builder(
      padding: AppStyles.listPadding,
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          // Permite gesto de swipe para remover o item da visualização.
          child: Dismissible(
            key: ValueKey<int>(event.id),
            direction: DismissDirection.startToEnd,
            background: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(AppStyles.cardRadius),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            onDismissed: (_) {
              setState(() {
                _events = List<Evento>.from(_events)..removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Evento removido da lista.')),
              );
            },
            child: EventCard(
              date: 'Até ${_formatDate(event.dataEntrega)}',
              title: event.nomeDisciplina,
              description: event.descricaoAtividade,
            ),
          ),
        );
      },
    );
  }
}

class EventCard extends StatelessWidget {
  final String date;
  final String title;
  final String description;

  const EventCard({
    super.key,
    required this.date,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    // Card padrão usado para apresentar cada evento da lista.
    return Card(
      child: ListTile(
        contentPadding: AppStyles.cardPadding,
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: AppStyles.titleSize,
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('$date\n$description'),
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}