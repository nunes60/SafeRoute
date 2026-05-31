import 'package:flutter/material.dart';

import '../core/app_styles.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class CadastrarEventoScreen extends StatefulWidget {
  const CadastrarEventoScreen({super.key});

  @override
  State<CadastrarEventoScreen> createState() => _CadastrarEventoScreenState();
}

class _CadastrarEventoScreenState extends State<CadastrarEventoScreen> {
  final TextEditingController _disciplinaController = TextEditingController();
  final TextEditingController _atividadeController = TextEditingController();
  final _apiService = ApiService();

  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  String _formatDateBr(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
    });
  }

  @override
  void dispose() {
    _disciplinaController.dispose();
    _atividadeController.dispose();
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

      await _apiService.salvarEvento(
        usuarioId: usuarioId,
        nomeDisciplina: nomeDisciplina,
        descricaoAtividade: descricaoAtividade,
        dataEntrega: _toApiDate(_selectedDate),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento cadastrado com sucesso.')),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
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
        // Barra superior com título da tela de cadastro.
        title: const Text(
          'Cadastrar evento',
        ),
      ),
      body: SingleChildScrollView(
        padding: AppStyles.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo para informar a disciplina.
            _buildInputField(
              label: 'Nome da Disciplina',
              hint: 'Digite a disciplina aqui',
              controller: _disciplinaController,
            ),
            AppStyles.gap20,

            // Campo para informar a descrição da atividade.
            _buildInputField(
              label: 'Descrição da Atividade',
              hint: 'Digite uma rápida descrição da atividade',
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
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                hintText: 'Selecione a data',
                suffixIcon: const Icon(Icons.calendar_today),
                border: const OutlineInputBorder(),
                filled: true,
                labelText: _formatDateBr(_selectedDate),
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
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveEvent,
                    child: const Text('Salvar'),
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
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        AppStyles.gap8,
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: GestureDetector(
              onTap: () => controller.clear(),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.clear),
              ),
            ),
            border: const OutlineInputBorder(),
            filled: true,
          ),
        ),
      ],
    );
  }
}