import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:smartify/pages/tracker/tracker_classes.dart';  

class CalendarPage extends StatefulWidget {
  final List<Subject> subjects;

  const CalendarPage({super.key, required this.subjects});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();
  late Future<void> _localeFuture;

  final List<DateTime> _dateRange = List.generate(
    30,
    (index) => DateTime.now().add(Duration(days: index)),
  );

  @override
  void initState() {
    super.initState();
    // Инициализация локали
    _localeFuture = initializeDateFormatting('ru');
  }

  List<TaskCalendar> _tasksForSelectedDate() {
    List<TaskCalendar> tasks = [];
    for (var subject in widget.subjects) {
      for (var task in subject.tasks) {
        DateTime? deadline = task.deadline;
        if (deadline != null &&
            deadline.year == _selectedDate.year &&
            deadline.month == _selectedDate.month &&
            deadline.day == _selectedDate.day) {
          tasks.add(TaskCalendar.fromJson({
            "subject": subject.title,
            "color": subject.color,
            "title": task.title,
            "duration": task.duration,
            "completed": task.isCompleted,
          }));
        }
      }
    }
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _localeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          List<TaskCalendar> tasks = _tasksForSelectedDate();

          return Scaffold(
            appBar: AppBar(
              title: const Text("Календарь дедлайнов"),
            ),
            body: Column(
              children: [
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _dateRange.length,
                    itemBuilder: (context, index) {
                      DateTime date = _dateRange[index];
                      bool isSelected = date.year == _selectedDate.year &&
                          date.month == _selectedDate.month &&
                          date.day == _selectedDate.day;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey.shade400,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('E', 'ru').format(date),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected ? Colors.white : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                date.day.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Выбрана дата: ${DateFormat('dd.MM.yyyy').format(_selectedDate)}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Expanded(
                  child: tasks.isEmpty
                      ? const Center(child: Text("Заданий на эту дату нет"))
                      : ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            TaskCalendar task = tasks[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: task.color,
                                child: Text(task.subjectTitle[0]),
                              ),
                              title: Text(task.title),
                              subtitle: Text("Длительность: ${task.duration}"),
                              trailing: Icon(
                                task.isCompleted ? Icons.check_circle : Icons.pending,
                                color: task.isCompleted ? Colors.green : Colors.orange,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}