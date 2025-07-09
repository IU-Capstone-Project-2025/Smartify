import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:smartify/pages/tests/prof_test_page.dart';
import 'package:smartify/pages/professions/professionCard.dart';
import 'package:smartify/pages/professions/profDetPage.dart';

class ProfessionsPage extends StatefulWidget {
  const ProfessionsPage({super.key});

  @override
  State<ProfessionsPage> createState() => _ProfessionsPageState();
}

class _ProfessionsPageState extends State<ProfessionsPage> {
  List<dynamic> professions = [];
  List<dynamic> filteredProfessions = [];

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
      setState(() {
        professions = data;
        filteredProfessions = data;
      });
    } catch (e) {
      debugPrint('Ошибка при загрузке данных: $e');
    }
  }

  void filterSearch(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredProfessions = professions.where((profession) {
        final name = (profession['name'] ?? '').toString().toLowerCase();
        return name.contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    const highlightColor = Color(0xFF54D0C0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Image.asset('logo.png', height: 50),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: professions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Поиск
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    onChanged: filterSearch,
                    decoration: InputDecoration(
                      hintText: 'Поиск профессии...',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: const BorderSide(color: Colors.teal),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: const BorderSide(color: Colors.teal),
                      ),
                    ),
                  ),
                ),
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
                // Список ProfessionCard
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProfessions.length,
                    itemBuilder: (context, index) {
                      final prof = filteredProfessions[index];
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
