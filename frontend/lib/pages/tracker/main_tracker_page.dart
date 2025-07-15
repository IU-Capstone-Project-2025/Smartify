import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:smartify/pages/tracker/calendar_page.dart'; 
import 'package:smartify/pages/tracker/tracker_classes.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {

  final SubjectsManager taskManager = SubjectsManager();
  @override
  void initState() {
    loadSavedSubjects();
    super.initState();
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
          title: const Text("Новый предмет"),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: "Название предмета"),
            onChanged: (val) => newTitle = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Отмена"),
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
              child: const Text("Добавить"),
            )
          ],
        );
      },
    );
  }

  Future<DateTime?> _pickDate(DateTime? initialDate) async {
    DateTime now = DateTime.now();
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
  }

  void _addTask(int subjectIndex) {
    String title = "";
    String duration = "";
    DateTime? deadline;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Новое задание"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(labelText: "Название"),
                    onChanged: (val) => title = val,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: "Длительность"),
                    onChanged: (val) => duration = val,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text("Дедлайн: "),
                      Expanded(
                        child: Text(
                          deadline != null
                              ? DateFormat('dd.MM.yyyy').format(deadline!)
                              : '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          DateTime? picked = await _pickDate(deadline);
                          if (picked != null) {
                            setStateDialog(() {
                              deadline = picked;
                            });
                          }
                        },
                        child: const Text("Выбрать"),
                      )
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Отмена"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (title.trim().isNotEmpty) {
                      setState(() {
                        taskManager.subjects[subjectIndex].addTasks([Task.fromJson({
                          "title": title,
                          "duration": duration,
                          "completed": false,
                          "deadline": deadline,
                        })]);
                      });
                      taskManager.saveAll();
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Добавить"),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _editTask(int subjectIndex, int taskIndex) {
    String title = taskManager.subjects[subjectIndex].tasks[taskIndex].title;
    String duration = taskManager.subjects[subjectIndex].tasks[taskIndex].duration;
    DateTime? deadline = taskManager.subjects[subjectIndex].tasks[taskIndex].deadline;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Редактировать задание"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: TextEditingController(text: title),
                    decoration: const InputDecoration(labelText: "Название"),
                    onChanged: (val) => title = val,
                  ),
                  TextField(
                    controller: TextEditingController(text: duration),
                    decoration: const InputDecoration(labelText: "Длительность"),
                    onChanged: (val) => duration = val,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text("Дедлайн: "),
                      Expanded(
                        child: Text(
                          deadline != null
                              ? DateFormat('dd.MM.yyyy').format(deadline!):'',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          DateTime? picked = await _pickDate(deadline);
                          if (picked != null) {
                            setStateDialog(() {
                              deadline = picked;
                            });
                          }
                        },
                        child: const Text("Выбрать"),
                      )
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Отмена"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      taskManager.subjects[subjectIndex].tasks[taskIndex].title = title;
                      taskManager.subjects[subjectIndex].tasks[taskIndex].duration = duration;
                      taskManager.subjects[subjectIndex].tasks[taskIndex].deadline = deadline;
                    });
                    taskManager.saveAll();
                    Navigator.pop(context);
                  },
                  child: const Text("Сохранить"),
                )
              ],
            );
          },
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
        builder: (context) => CalendarPage(subjects: taskManager.subjects),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Прогресс', style: TextStyle(color: Colors.black)),
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
            const Text('Предметы', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...taskManager.subjects.asMap().entries.map((entry) {
                    int index = entry.key;
                    var subject = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: subjectCard(taskManager.subjects[index], index),
                    );
                  }),
                  GestureDetector(
                    onTap: _addSubject,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.add, size: 40, color: Colors.grey),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text("Прогресс", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("За всё время"),
            const SizedBox(height: 12),
            Center(
              child: CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 15.0,
                percent: percent,
                center: Text("${(percent * 100).toInt()}%\nВыполнено", textAlign: TextAlign.center),
                progressColor: Colors.teal,
                backgroundColor: Colors.teal.shade100,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget subjectCard(Subject subject, int subjectIndex) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: subject.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(subject.icon, color: Colors.white, size: 28),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteSubject(subjectIndex);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(value: 'delete', child: Text('Удалить предмет')),
                ],
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(subject.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...subject.tasks.asMap().entries.map((entry) {
                  int taskIndex = entry.key;
                  var task = entry.value;
                  DateTime? deadline = task.deadline;
                  return GestureDetector(
                    onTap: () => _editTask(subjectIndex, taskIndex),
                    child: Container(
                      width: 130,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: task.isCompleted,
                            onChanged: (val) {
                              setState(() {
                                task.isCompleted = val ?? false;
                              });
                              taskManager.saveAll();
                            },
                            activeColor: Colors.white,
                            checkColor: subject.color,
                          ),
                          Text(
                            task.title,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            task.duration,
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                          if (deadline != null)
                            Text(
                              "Дедлайн: ${DateFormat('dd.MM.yyyy').format(deadline)}",
                              style: const TextStyle(color: Colors.white70, fontSize: 10, fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                GestureDetector(
                  onTap: () => _addTask(subjectIndex),
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Icon(Icons.add, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
