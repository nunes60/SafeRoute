import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color greenPrimary = Color(0xFF386A3F);
    const Color cardBackground = Color(0xFFEDF2EC);
    const Color textDark = Colors.black87;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: greenPrimary),
          onPressed: () {
  
          },
        ),
      ),
                color: accentColor.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BEM-VINDO',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: greenPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Visualize seus destaques abaixo',
              style: TextStyle(
                fontSize: 16,
                color: textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            
        
            _buildHighlightCard(
              date: 'Até 25/05/2026',
              title: 'Programação Mobile',
              description: 'Desenvolvimento de 4 telas usando Flutter e estruturação da 1ª tela em código.',
              cardColor: cardBackground,
              accentColor: greenPrimary,
            ),
            const SizedBox(height: 16),
            _buildHighlightCard(
              date: 'Até 29/05/2026',
              title: 'Laboratório de Inovação IV',
              description: 'Criar o slide para usar no Innova Day, contendo todas as informações essenciais para a equipe.',
              cardColor: cardBackground,
              accentColor: greenPrimary,
            ),
            const SizedBox(height: 16),
            _buildHighlightCard(
              date: 'Até 30/05/2026',
              title: 'Governança de TI',
              description: 'Responder o questionário completo no Moodle, para não correr riscos.',
              cardColor: cardBackground,
              accentColor: greenPrimary,
            ),
            
            const SizedBox(height: 32),
            
            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/events');
                    },
                    icon: const Icon(Icons.list, size: 18, color: Colors.white),
                    label: const Text(
                      'VER TUDO',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/create-event');
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 18, color: Colors.white),
                    label: const Text(
                      'ADICIONAR NOVO',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightCard({
    required String date,
    required String title,
    required String description,
    required Color cardColor,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                color: accentColor.withOpacity(0.5),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              date,
                              style: TextStyle(
                                fontSize: 13,
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Align(
                        alignment: Alignment.topRight,
                        child: Icon(
                          Icons.play_arrow,
                          color: accentColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}