import 'package:flutter/material.dart';
import 'package:smartify/pages/tests/prof_test_page.dart';
import 'package:smartify/pages/professions/sphere_professions_page.dart';

class SubspheresPage extends StatelessWidget {
  final String sphere;
  final List<String> subspheres;

  const SubspheresPage({
    super.key,
    required this.sphere,
    required this.subspheres,
  });

  @override
  Widget build(BuildContext context) {
    const highlightColor = Color(0xFF54D0C0);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          sphere,
          style: theme.textTheme.titleLarge,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? highlightColor : Colors.black,
          ),
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
          // Список карточек подсфер
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subspheres.length,
              itemBuilder: (context, index) {
                final sub = subspheres[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    color: theme.cardColor,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      title: Text(
                        sub,
                        style: theme.textTheme.bodyLarge,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: theme.iconTheme.color,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SphereProfessionsPage(
                              sphere: sphere,
                              subsphere: sub,
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
