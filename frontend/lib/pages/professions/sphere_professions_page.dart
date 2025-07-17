import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:smartify/pages/tests/prof_test_page.dart';
import 'package:smartify/pages/professions/professionCard.dart';
import 'package:smartify/pages/professions/profDetPage.dart';

class SphereProfessionsPage extends StatefulWidget {
  final String sphere;
  final String subsphere;

  const SphereProfessionsPage({
    super.key,
    required this.sphere,
    required this.subsphere,
  });

  @override
  State<SphereProfessionsPage> createState() => _SphereProfessionsPageState();
}

class _SphereProfessionsPageState extends State<SphereProfessionsPage> {
  List<dynamic> professions = [];

  @override
  void initState() {
    super.initState();
    loadProfessionData();
  }

  Future<void> loadProfessionData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/professions.json');
      final List<dynamic> data = json.decode(jsonString);

      final filtered = data.where((item) =>
          item['sphere'] == widget.sphere &&
          item['subsphere'] == widget.subsphere).toList();

      setState(() {
        professions = filtered;
      });
    } catch (e) {
      debugPrint('Ошибка при загрузке данных: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const highlightColor = Color(0xFF54D0C0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.subsphere),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: professions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Кнопка анкеты
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: highlightColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QuestionnairePage(),
                        ),
                      );
                    },
                    child: const Center(
                      child: Text(
                        'Пройти анкетирование',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                // Список профессий
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: professions.length,
                    itemBuilder: (context, index) {
                      final prof = professions[index];
                      final title = prof['name'] ?? 'Без названия';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ProfessionCard(
                          title: title,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfessionDetailPage(
                                  profession: prof,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
