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
  DateTime _selectedDate = DateTime.now(); // Set to current date
  late Future<void> _localeFuture;

  late final List<DateTime> _dateRange;

  @override
  void initState() {
    super.initState();
    _localeFuture = initializeDateFormatting('ru');
    // Generate dates from today to one month ahead
    DateTime today = DateTime.now();
    DateTime oneMonthAhead = DateTime(today.year, today.month + 1, today.day);
    int days = oneMonthAhead.difference(today).inDays + 1;
    _dateRange = List.generate(
      days,
      (index) => today.add(Duration(days: index)),
    );
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
            backgroundColor: const Color(0xFFFCFCFC),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Календарь',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('d', 'ru').format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${DateFormat('EEEE', 'ru').format(_selectedDate)}, ${DateFormat('LLLL y', 'ru').format(_selectedDate)}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 70,
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
                            width: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF26977F) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('E', 'ru').format(date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.white : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Text("Время", style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(width: 32),
                        Text("Предмет", style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 60,
                                child: Text(
                                  task["duration"],
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: (task["color"] as Color).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            task["subject"],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const Icon(Icons.more_vert, size: 18),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        task["title"],
                                        style: const TextStyle(color: Colors.black54),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        task["completed"] ? "Решено верно" : "В процессе",
                                        style: TextStyle(
                                          color: task["completed"] ? Colors.green : Colors.redAccent,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
