import 'package:flutter/material.dart';

class CadastrarEventoScreen extends StatefulWidget {
  const CadastrarEventoScreen({super.key});

  @override
  State<CadastrarEventoScreen> createState() => _CadastrarEventoScreenState();
}

class _CadastrarEventoScreenState extends State<CadastrarEventoScreen> {
  final TextEditingController _disciplinaController = TextEditingController();
  final TextEditingController _atividadeController = TextEditingController();
  DateTime _selectedDate = DateTime(2025, 8, 17);

  @override
  Widget build(BuildContext context) {
    const Color greenPrimary = Color(0xFF386A3F);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: greenPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'CADASTRAR EVENTO',
          style: TextStyle(
            color: greenPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField(
              label: 'Nome da Disciplina',
              hint: 'Digite a disciplina aqui',
              controller: _disciplinaController,
            ),
            const SizedBox(height: 20),

            _buildInputField(
              label: 'Descrição da Atividade',
              hint: 'Digite uma rápida descrição da atividade',
              controller: _atividadeController,
            ),
            const SizedBox(height: 20),

            const Text(
              'Date',
              style: TextStyle(
                color: greenPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.calendar_month, color: greenPrimary),
                ],
              ),
            ),
            const Text(
              'MM/DD/YYYY',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4EE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: greenPrimary, 
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: CalendarDatePicker(
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      onDateChanged: (date) {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16, bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text('Cancel',
                              style: TextStyle(color: greenPrimary, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {},
                          child: const Text('OK',
                              style: TextStyle(color: greenPrimary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
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
    const Color greenPrimary = Color(0xFF386A3F);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: greenPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFE2E8E0),
            suffixIcon: IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.grey),
              onPressed: () => controller.clear(),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}