import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_styles.dart';
import '../core/br_date_formatter.dart';
import '../models/evento.dart';
import '../services/api_exception.dart';
import '../services/event_service.dart';

/// Exibe o formulário para criar ou editar um evento.
class CadastrarEventoScreen extends StatefulWidget {
  const CadastrarEventoScreen({super.key, this.evento});

  final Evento? evento;

  @override
  /// Cria o estado que controla os campos e o salvamento do formulário.
  State<CadastrarEventoScreen> createState() => _CadastrarEventoScreenState();
}

/// Gerencia os campos, a data escolhida e o envio do formulário.
class _CadastrarEventoScreenState extends State<CadastrarEventoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _disciplinaController = TextEditingController();
  final TextEditingController _atividadeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final _eventService = EventService();

  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  bool get _isEditing => widget.evento != null;

  @override
  /// Preenche os campos quando a tela é aberta em modo de edição.
  void initState() {
    super.initState();
    if (_isEditing) {
      _disciplinaController.text = widget.evento!.nomeDisciplina;
      _atividadeController.text = widget.evento!.descricaoAtividade;
      _selectedDate = widget.evento!.dataEntrega;
    }
    _syncSelectedDate();
  }

  /// Atualiza o texto exibido no campo de data selecionada.
  void _syncSelectedDate() {
    _dateController.text = BrDateFormatter.formatShort(_selectedDate);
  }

  /// Abre o seletor de data e sincroniza o valor escolhido no formulário.
  Future<void> _pickDate() async {
    if (_isSaving) {
      return;
    }

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
  /// Libera os controllers usados pelos campos do formulário.
  void dispose() {
    _disciplinaController.dispose();
    _atividadeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  /// Converte a data selecionada para o formato esperado pela API.
  String _toApiDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Valida se um campo obrigatório recebeu algum valor.
  String? _validateRequired(String? value, String message) {
    if ((value ?? '').trim().isEmpty) {
      return message;
    }

    return null;
  }

  /// Monta os botões de cancelar e salvar de forma responsiva.
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
              child: OutlinedButton(
                onPressed: _isSaving
                    ? null
                    : () {
                        Navigator.pop(context);
                      },
                child: const Text('Cancelar'),
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: FilledButton(
                onPressed: _isSaving ? null : _saveEvent,
                child: _isSaving
                    ? const SizedBox(
                        width: AppStyles.busyIndicatorSize,
                        height: AppStyles.busyIndicatorSize,
                        child: CircularProgressIndicator(
                          strokeWidth: AppStyles.busyIndicatorStrokeWidth,
                        ),
                      )
                    : Text(_isEditing ? 'Atualizar' : 'Salvar'),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Valida o formulário e envia os dados para criação ou edição.
  Future<void> _saveEvent() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nomeDisciplina = _disciplinaController.text.trim();
    final descricaoAtividade = _atividadeController.text.trim();

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isEditing) {
        await _eventService.editarEvento(
          eventoId: widget.evento!.id,
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
  /// Monta a tela do formulário de evento com seus campos principais.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar evento' : 'Cadastrar evento'),
      ),
      body: SafeArea(
        child: AppLayout(
          width: AppLayoutWidth.content,
          scrollable: true,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(
                  label: 'Título',
                  hint: 'Digite o título do evento',
                  controller: _disciplinaController,
                  validator: (value) =>
                      _validateRequired(value, 'Informe o título do evento.'),
                ),
                AppStyles.gap20,
                _buildInputField(
                  label: 'Descrição da atividade',
                  hint: 'Digite uma breve descrição da atividade',
                  controller: _atividadeController,
                  validator: (value) => _validateRequired(
                    value,
                    'Informe a descrição da atividade.',
                  ),
                ),
                AppStyles.gap20,
                Text(
                  'Data de entrega',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                AppStyles.gap8,
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickDate,
                  validator: (value) =>
                      _validateRequired(value, 'Informe a data de entrega.'),
                  decoration: InputDecoration(
                    hintText: 'Selecione uma data',
                    suffixIcon: IconButton(
                      onPressed: _pickDate,
                      tooltip: 'Selecionar data',
                      icon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
                AppStyles.gap24,
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Cria um campo com rótulo, validação e ação rápida de limpeza.
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        AppStyles.gap8,
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: IconButton(
              onPressed: () {
                controller.clear();
              },
              tooltip: 'Limpar campo',
              icon: const Icon(Icons.clear),
            ),
          ),
        ),
      ],
    );
  }
}
