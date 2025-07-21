import 'package:flutter/material.dart';

class ProfessionDetailPage extends StatelessWidget {
  final Map<String, dynamic> profession;

  const ProfessionDetailPage({super.key, required this.profession});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white, // светло-серый фон
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          profession['name'] ?? 'Без названия',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF1C1C1E),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCardSection(
            title: "Описание",
            content: profession['description'] ?? 'Описание отсутствует',
          ),
          _buildCardSection(
            title: "Предметы ЕГЭ",
            list: profession['ege_subjects'],
          ),
          _buildCardSection(
            title: "Типы MBTI",
            content: profession['mbti_types'] ?? '—',
          ),
          _buildCardSection(
            title: "Интересы",
            list: profession['interests'],
          ),
          _buildCardSection(
            title: "Ценности",
            list: profession['values'],
          ),
          _buildCardSection(
            title: "Роль в команде",
            content: profession['role'] ?? '—',
          ),
          _buildCardSection(
            title: "Рабочая среда",
            content: profession['place'] ?? '—',
          ),
          _buildCardSection(
            title: "Стиль работы",
            content: profession['style'] ?? '—',
          ),
          _buildCardSection(
            title: "Уровень образования",
            content: profession['education_level'] ?? '—',
          ),
          _buildCardSection(
            title: "Диапазон зарплаты",
            content: profession['salary_range'] ?? '—',
          ),
          _buildCardSection(
            title: "Перспективы роста",
            content: profession['growth_prospects'] ?? '—',
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection({required String title, String? content, List<dynamic>? list}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 8),
          if (list != null)
            ...list.map((item) => Text(
                  '• $item',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF444444)),
                ))
          else
            Text(
              content ?? '—',
              style: const TextStyle(fontSize: 14, color: Color(0xFF444444)),
            ),
        ],
      ),
    );
  }
}
