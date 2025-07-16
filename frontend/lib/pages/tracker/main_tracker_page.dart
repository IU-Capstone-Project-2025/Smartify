import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:smartify/pages/tracker/calendar_page.dart';
import 'package:smartify/pages/tracker/tracker_classes.dart';
import 'package:smartify/l10n/app_localizations.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final SubjectsManager taskManager = SubjectsManager();

  @override
  void initState() {
    super.initState();
    loadSavedSubjects();
  }

  Future<void> loadSavedSubjects() async {
    await taskManager.loadAll();
    setState(() {});
  }

  void _addSubject() {
    showDialog(
      context: context,
      builder: (context) {
        String newTitle = "";
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.newSubject),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: AppLocalizations.of(context)!.subjectTitle),
            onChanged: (val) => newTitle = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (newTitle.trim().isNotEmpty) {
                  setState(() {
                    taskManager.addSubject(Subject(
                      title: newTitle,
                      icon: Icons.book,
                      color: const Color.fromARGB(255, 0, 150, 136),
                      tasks: []
                    ));
                  });
                  taskManager.saveAll();
                }
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.add),
            )
          ],
        );
      },
    );
  }

  void _deleteSubject(int index) {
    setState(() {
      taskManager.removeSubject(index);
    });
    taskManager.saveAll();
  }

  void _openCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int total = 0;
    int done = 0;
    for (var subject in taskManager.subjects) {
      total += subject.tasks.length;
      done += subject.tasks.where((t) => t.isCompleted == true).length;
    }
    double percent = total > 0 ? done / total : 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(AppLocalizations.of(context)!.progress, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.black),
            onPressed: _openCalendar,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Общая диаграмма прогресса
            Text(AppLocalizations.of(context)!.progress, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(AppLocalizations.of(context)!.forAllTime),
            const SizedBox(height: 12),
            Center(
              child: CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 15.0,
                percent: percent,
                center: Text("${(percent * 100).toInt()}%\n${AppLocalizations.of(context)!.completed}", textAlign: TextAlign.center),
                progressColor: Colors.teal,
                backgroundColor: Colors.teal.shade100,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
            const SizedBox(height: 32),
            // Список предметов
            Text(AppLocalizations.of(context)!.subjects, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: taskManager.subjects.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: subjectCard(taskManager.subjects[index], index),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget subjectCard(Subject subject, int subjectIndex) {
    int total = subject.tasks.length;
    int done = subject.tasks.where((t) => t.isCompleted == true).length;
    double percent = total > 0 ? done / total : 0;
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: subject.color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Декоративные круги (имитация фона как на картинке)
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Контент карточки
          Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      subject.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: CircularPercentIndicator(
                    radius: 38.0,
                    lineWidth: 8.0,
                    percent: percent,
                    center: Text("${(percent * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    progressColor: Colors.white,
                    backgroundColor: Colors.white24,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.topRight,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteSubject(subjectIndex);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(value: 'delete', child: Text(AppLocalizations.of(context)!.deleteSubject)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }
}