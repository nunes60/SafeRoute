import 'package:flutter/material.dart';

import '../core/app_styles.dart';

/// Lista as ações disponíveis no menu contextual de um evento.
enum EventCardAction { edit, delete }

/// Exibe um resumo visual de um evento com ações rápidas.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.date,
    required this.title,
    required this.description,
    this.isBusy = false,
    this.onTap,
    this.onSelectedAction,
  });

  final String date;
  final String title;
  final String description;
  final bool isBusy;
  final VoidCallback? onTap;
  final ValueChanged<EventCardAction>? onSelectedAction;

  @override
  /// Monta o card com conteúdo, estado de carregamento e menu de ações.
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        enabled: !isBusy,
        onTap: onTap,
        title: Text(title),
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
            : PopupMenuButton<EventCardAction>(
                tooltip: 'Ações do evento',
                onSelected: onSelectedAction,
                itemBuilder: (context) => const [
                  PopupMenuItem<EventCardAction>(
                    value: EventCardAction.edit,
                    child: Text('Editar'),
                  ),
                  PopupMenuItem<EventCardAction>(
                    value: EventCardAction.delete,
                    child: Text('Excluir'),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Exibe a confirmação antes de excluir um evento da lista.
Future<bool> showDeleteEventDialog({
  required BuildContext context,
  required String eventTitle,
}) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Excluir evento'),
        content: Text('Deseja excluir "$eventTitle" da sua lista?'),
        buttonPadding: const EdgeInsets.symmetric(
          horizontal: AppStyles.actionSpacing / 2,
        ),
        actionsOverflowButtonSpacing: AppStyles.actionSpacing,
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Excluir'),
          ),
        ],
      );
    },
  );

  return shouldDelete ?? false;
}
