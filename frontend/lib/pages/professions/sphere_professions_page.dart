import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:smartify/pages/tests/prof_test_page.dart';
import 'package:smartify/pages/professions/professionCard.dart';
import 'package:smartify/pages/professions/profDetPage.dart';
import 'package:flutter/foundation.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadProfessionData();
  }

  Future<void> loadProfessionData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/professions.json');
      final List<dynamic> data = json.decode(jsonString);
      String sphere = widget.sphere;
      String subsphere = widget.subsphere;
      final locale = Localizations.localeOf(context).languageCode;
      if (locale == 'en') {
        final String spheresRuStr = await rootBundle.loadString('assets/spheres_stats.json');
        final String spheresEnStr = await rootBundle.loadString('assets/spheres_stats_en.json');
        final List spheresRu = json.decode(spheresRuStr)['spheres'];
        final List spheresEn = json.decode(spheresEnStr)['spheres'];
        final match = spheresEn.indexWhere((el) => el['sphere'] == widget.sphere && el['subsphere'] == widget.subsphere);
        if (match != -1) {
          sphere = spheresRu[match]['sphere'];
          subsphere = spheresRu[match]['subsphere'];
        }
      }
      final filtered = data.where((item) =>
          item['sphere'] == sphere &&
          item['subsphere'] == subsphere).toList();
      if (mounted) {
        setState(() {
          professions = filtered;
        });
      }
    } catch (e) {
      debugPrint('Ошибка при загрузке данных: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const highlightColor = Color(0xFF54D0C0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.subsphere,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).brightness == Brightness.dark
                ? Color(0xFF54D0C0)
                : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Кнопка анкеты (всегда видна)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          // Список профессий или индикатор загрузки
          Expanded(
            child: professions.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
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
