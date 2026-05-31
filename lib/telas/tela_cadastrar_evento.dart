import 'package:flutter/material.dart';

import '../core/app_styles.dart';
import '../core/br_date_formatter.dart';
import '../models/evento.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class CadastrarEventoScreen extends StatefulWidget {
  const CadastrarEventoScreen({super.key, this.evento});

  final Evento? evento;

  @override
  State<CadastrarEventoScreen> createState() => _CadastrarEventoScreenState();
}

class _CadastrarEventoScreenState extends State<CadastrarEventoScreen> {
  final TextEditingController _disciplinaController = TextEditingController();
  final TextEditingController _atividadeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final _apiService = ApiService();

  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  bool get _isEditing => widget.evento != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _disciplinaController.text = widget.evento!.nomeDisciplina;
      _atividadeController.text = widget.evento!.descricaoAtividade;
      _selectedDate = widget.evento!.dataEntrega;
    }
    _syncSelectedDate();
  }

  void _syncSelectedDate() {
    _dateController.text = BrDateFormatter.formatShort(_selectedDate);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _syncSelectedDate();
    });
  }

  @override
  void dispose() {
    _disciplinaController.dispose();
    _atividadeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String _toApiDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _saveEvent() async {
    final nomeDisciplina = _disciplinaController.text.trim();
    final descricaoAtividade = _atividadeController.text.trim();

    if (nomeDisciplina.isEmpty || descricaoAtividade.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos do evento.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final usuarioId = await SessionService.getUserId();
      if (usuarioId == null) {
        throw ApiException('Sessão não encontrada. Faça login novamente.');
      }

      if (_isEditing) {
        await _apiService.editarEvento(
          eventoId: widget.evento!.id,
          usuarioId: usuarioId,
          nomeDisciplina: nomeDisciplina,
          descricaoAtividade: descricaoAtividade,
          dataEntrega: _toApiDate(_selectedDate),
        );
      } else {
        await _apiService.salvarEvento(
          usuarioId: usuarioId,
          nomeDisciplina: nomeDisciplina,
          descricaoAtividade: descricaoAtividade,
          dataEntrega: _toApiDate(_selectedDate),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Evento atualizado com sucesso.'
                : 'Evento cadastrado com sucesso.',
          ),
        ),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro inesperado ao salvar o evento.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Barra superior com título do fluxo atual.
        title: Text(_isEditing ? 'Editar evento' : 'Cadastrar evento'),
      ),
      body: SingleChildScrollView(
        padding: AppStyles.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo para informar o título do evento.
            _buildInputField(
              label: 'Título',
              hint: 'Digite o título do evento',
              controller: _disciplinaController,
            ),
            AppStyles.gap20,

            // Campo para informar a descrição da atividade.
            _buildInputField(
              label: 'Descrição da atividade',
              hint: 'Digite uma breve descrição da atividade',
              controller: _atividadeController,
            ),
            AppStyles.gap20,

            // Rótulo da seção de seleção de data.
            Text(
              'Data de entrega',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            AppStyles.gap8,
            // Campo somente leitura que abre o seletor de data.
            TextFormField(
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                hintText: 'Selecione uma data',
                suffixIcon: const Icon(Icons.calendar_today),
              ),
            ),
            AppStyles.gap24,
            // Ações de cancelar ou salvar o evento informado.
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    child: const Text('Cancelar'),
                  ),
                ),
                AppStyles.gapWidth12,
                Expanded(
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveEvent,
                    child: Text(_isEditing ? 'Atualizar' : 'Salvar'),
                  ),
                ),
              ],
            ),
            if (_isSaving) ...[
              AppStyles.gap16,
              // Indicador exibido durante o envio do evento para a API.
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    // Componente reutilizável para campos de texto do formulário.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        AppStyles.gap8,
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: GestureDetector(
              onTap: () => controller.clear(),
              child: const Padding(
                padding: AppStyles.compactPadding,
                child: Icon(Icons.clear),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
