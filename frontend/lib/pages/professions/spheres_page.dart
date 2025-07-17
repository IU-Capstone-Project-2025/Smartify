import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'subspheres_page.dart';
import 'package:smartify/pages/tests/prof_test_page.dart';

class SpheresPage extends StatefulWidget {
  const SpheresPage({super.key});

  @override
  State<SpheresPage> createState() => _SpheresPageState();
}

class _SpheresPageState extends State<SpheresPage> {
  Map<String, List<String>> sphereMap = {}; // sphere → list of subspheres

  @override
  void initState() {
    super.initState();
    loadSphereData();
  }

  Future<void> loadSphereData() async {
    final String jsonStr =
        await rootBundle.loadString('assets/spheres_stats.json');
    final List<dynamic> data = json.decode(jsonStr)['spheres'];

    final map = <String, List<String>>{};
    for (var item in data) {
      final sphere = item['sphere'];
      final subsphere = item['subsphere'];
      map.putIfAbsent(sphere, () => []);
      if (!map[sphere]!.contains(subsphere)) {
        map[sphere]!.add(subsphere);
      }
    }

    setState(() {
      sphereMap = map;
    });
  }

  @override
  Widget build(BuildContext context) {
    const highlightColor = Color(0xFF54D0C0);
    final spheres = sphereMap.keys.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Сферы"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Кнопка анкетирования
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          // Список сфер
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: spheres.length,
              itemBuilder: (context, index) {
                final sphere = spheres[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      title: Text(
                        sphere,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SubspheresPage(
                              sphere: sphere,
                              subspheres: sphereMap[sphere]!,
                            ),
                          ),
                        );
                      },
                    ),
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
