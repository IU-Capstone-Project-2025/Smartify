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
        automaticallyImplyLeading: false,
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
                const SizedBox(width: 50),
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
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const UniversityPage(),
                                  ),
                                );
                              },
                              child: const _TopicCard(
                                title: 'Университеты',
                                subtitle: 'Более ста разных университетов',
                                assetImage: 'university.png',
                                isDarkButton: false,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProgressPage(),
                                  ),
                                );
                              },
                              child: const _TopicCard(
                                title: 'Подготовка\nк ЕГЭ',
                                subtitle: 'Отслеживайте\nсвой прогресс',
                                assetImage: 'career.png',
                                isDarkButton: true,
                              ),
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
                              builder: (context) => const ProfessionsPage(),
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

class _TopicCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String assetImage;
  final bool isDarkButton;

  const _TopicCard({
    required this.title,
    required this.subtitle,
    required this.assetImage,
    this.isDarkButton = false,
  });

  @override
  State<_TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<_TopicCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Stack(
        children: [
          Container(
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
                    widget.assetImage,
                    width: 100,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _hovering ? 0.1 : 0.0,
            child: Container(
              height: 230,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WideButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  const _WideButton({
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  State<_WideButton> createState() => _WideButtonState();
}

class _WideButtonState extends State<_WideButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Stack(
        children: [
          GestureDetector(
            onTap: widget.onPressed,
            child: Container(
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
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.play_circle_filled_rounded,
                    color: Colors.white,
                    size: 30,
                  )
                ],
              ),
            ),
          ),
          IgnorePointer(
            ignoring: true,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _hovering ? 0.1 : 0.0,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
