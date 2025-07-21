import 'package:flutter/material.dart';
import 'package:smartify/pages/professions/professionCard.dart';
import 'package:smartify/pages/professions/profDetPage.dart';

class ProfessionGrid extends StatelessWidget {
  final List<Map<String, dynamic>> professions = [
    {
      "name": "Детский хирург",
      "description": "Детский хирург проводит сложные операции...",
      "ege_subjects": ["Русский язык", "Математика (базовый)", "Химия", "Биология"],
      "mbti_types": "INFJ, ISFJ",
      "interests": ["Помогать людям", "Делать эксперименты"],
      "values": ["Помощь другим", "Стабильность"],
      "role": "Исполнителем",
      "place": "В лаборатории",
      "style": "По чёткому алгоритму",
      "education_level": "Высшее",
      "salary_range": "100,000–300,000 руб./мес",
      "growth_prospects": "Высокие"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профессии')),
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1,
        padding: const EdgeInsets.all(8),
        children: professions.map((profession) {
          return ProfessionCard(
            title: profession['name'],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfessionDetailPage(profession: profession),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
