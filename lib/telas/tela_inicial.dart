import 'package:flutter/material.dart';

import '../core/app_styles.dart';
import '../main.dart';
import '../models/evento.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _apiService = ApiService();
  late Future<List<Evento>> _highlightsFuture;

  @override
  void initState() {
    super.initState();
    _highlightsFuture = _loadHighlights();
  }

  Future<List<Evento>> _loadHighlights() async {
    final usuarioId = await SessionService.getUserId();
    if (usuarioId == null) {
      throw ApiException('Sessão não encontrada. Faça login novamente.');
    }

    return _apiService.listarEventos(usuarioId: usuarioId, limit: 3);
  }

  Future<void> _logout() async {
    await SessionService.clearSession();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, loginRoute, (route) => false);
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
                  'Bem-vindo',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: AppStyles.headerSize,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                AppStyles.gap8,
                Text(
                  'Visualize seus destaques abaixo',
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
                      return const Text('Nenhum compromisso próximo encontrado.');
                    }

                    // Lista visual dos cards de destaque.
                    return Column(
                      children: [
                        for (final event in events)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildHighlightCard(
                              date: 'Até ${_formatDate(event.dataEntrega)}',
                              title: event.nomeDisciplina,
                              description: event.descricaoAtividade,
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
                    if (!mounted) return;
                    setState(() {
                      _highlightsFuture = _loadHighlights();
                    });
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
    required String date,
    required String title,
    required String description,
  }) {
    // Card padrão para representar um compromisso em destaque.
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