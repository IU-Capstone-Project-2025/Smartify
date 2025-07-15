import 'package:flutter/material.dart';
import 'package:smartify/pages/tracker/main_tracker_page.dart';
import 'package:smartify/pages/universities/main_university_page.dart';
import 'package:smartify/pages/account/account_page.dart';
import 'package:smartify/pages/professions/professions_page.dart';
import 'package:smartify/pages/teachers/teachers_list_page.dart';

void main() {
  runApp(const SmartifyApp());
}

class SmartifyApp extends StatelessWidget {
  const SmartifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  automaticallyImplyLeading: false, // We'll manually control it
  title: Stack(
    alignment: Alignment.center,
    children: [
      Center(
        child: Image.asset(
          'logo.png',
          height: 50,
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () {
                showGeneralDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: 'Settings',
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (_, __, ___) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 360,
                          height: MediaQuery.of(context).size.height,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: const SettingsSheet(),
                        ),
                      ),
                    );
                  },
                  transitionBuilder: (context, animation, _, child) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(-1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                );
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/user_avatar.jpg'),
              ),
            ),
          ),
          const SizedBox(width: 50), // Spacer for symmetry (optional)
        ],
      ),
    ],
  ),
),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Добро пожаловать!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Выберите тему',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _TopicCard(
                              title: 'Университеты',
                              subtitle: 'Более ста разных университетов',
                              assetImage: 'university.png',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const UniversityPage(),
                                  ),
                                );
                              },
                              isDarkButton: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TopicCard(
                              title: 'Подготовка\nк ЕГЭ',
                              subtitle: 'Отслеживайте\nсвой прогресс',
                              assetImage: 'career.png',
                              onPressed: () {
                                  Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ProgressPage(),
                                  ),
                                );
                              },
                              isDarkButton: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _WideButton(
                        title: 'Карьерные Предложения',
                        subtitle: 'Огромная база карьер',
                        onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ProfessionsPage(),
                                  ),
                                );
                              },
                      ),
                      const SizedBox(height: 12),
                      _WideButton(
                        title: 'Репетиторы',
                        subtitle: 'Более ста репетиторов',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TeachersListPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String assetImage;
  final VoidCallback onPressed;
  final bool isDarkButton;

  const _TopicCard({
    required this.title,
    required this.subtitle,
    required this.assetImage,
    required this.onPressed,
    this.isDarkButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: const Color(0xFF54D0C0),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Image.asset(
              assetImage,
              width: 100,
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDarkButton ? const Color(0xFF0E736B) : Colors.white,
                foregroundColor:
                    isDarkButton ? Colors.white : const Color(0xFF1C7D75),
                minimumSize: const Size(80, 36),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: onPressed,
              child: const Text('Перейти'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WideButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  const _WideButton({
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E736B),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_filled_rounded,
                color: Colors.white, size: 30),
            onPressed: onPressed,
          )
        ],
      ),
    );
  }
}
