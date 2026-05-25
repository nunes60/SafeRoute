import 'package:flutter/material.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color greenPrimary = Color(0xFF386A3F);

    final List<Map<String, String>> events = [
      {
        'date': 'Até 25/05/2026',
        'title': 'Programação Mobile',
        'desc': 'Desenvolvimento de 4 telas usando Flutter e estruturação da 1ª tela em código.'
      },
      {
        'date': 'Até 29/05/2026',
        'title': 'Laboratório de Inovação IV',
        'desc': 'Criar o slide para usar no Innova Day, contendo todas as informações essenciais para a equipe.'
      },
      {
        'date': 'Até 30/05/2026',
        'title': 'Governança de TI',
        'desc': 'Criar o slide para usar no Innova Day, o Moodle, para não correr riscos.'
      },
      {
        'date': 'Até 30/05/2026',
        'title': 'Governança de TI',
        'desc': 'Responder o questionário completo no Moodle, para não correr riscos.'
      },
      {
        'date': 'Até 30/05/2026',
        'title': 'Governança de TI',
        'desc': 'Responder o questionário completo no Moodle, para não correr riscos.'
      },
      {
        'date': 'Até 30/05/2026',
        'title': 'Governança de TI',
        'desc': 'Responder o questionário completo no Moodle, para não correr riscos.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: greenPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'LISTA DE EVENTOS',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Em visão cronológica',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: EventCard(
              date: event['date']!,
              title: event['title']!,
              description: event['desc']!,
              accentColor: greenPrimary,
            ),
          );
        },
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String date;
  final String title;
  final String description;
  final Color accentColor;

  const EventCard({
    super.key,
    required this.date,
    required this.title,
    required this.description,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEDF2EC), 
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
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Icon(
                          Icons.play_arrow,
                          color: accentColor,
                          size: 18,
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