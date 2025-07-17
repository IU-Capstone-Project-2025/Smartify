import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:smartify/pages/tracker/tracker_classes.dart';
import 'package:flutter/cupertino.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();
  late Future<void> _localeFuture;
  late final List<DateTime> _dateRange;
  
  // Set of dates with at least one incomplete task deadline
  Set<DateTime> get _datesWithDeadlines {
    final Set<DateTime> result = {};
    for (final subject in SubjectsManager().subjects) {
      for (final task in subject.tasks) {
        if (task.deadline != null && !(task.isCompleted ?? false)) {
          // Only date part
          final d = DateTime(task.deadline!.year, task.deadline!.month, task.deadline!.day);
          result.add(d);
        }
      }
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _localeFuture = initializeDateFormatting('ru');
    DateTime today = DateTime.now();
    DateTime oneMonthAhead = DateTime(today.year, today.month + 1, today.day);
    int days = oneMonthAhead.difference(today).inDays + 1;
    _dateRange = List.generate(
      days,
      (index) => today.add(Duration(days: index)),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<_TaskWithSubject> _tasksForSelectedDate() {
    final List<_TaskWithSubject> result = [];
    for (final subject in SubjectsManager().subjects) {
      for (final task in subject.tasks) {
        if (task.deadline != null && isSameDay(task.deadline!, _selectedDate)) {
          result.add(_TaskWithSubject(task: task, subject: subject));
        }
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _localeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final tasks = _tasksForSelectedDate();
        return Scaffold(
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
                      const Text('Календарь', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        color: const Color(0xFF26977F),
                        minSize: 28,
                        borderRadius: BorderRadius.circular(8),
                        child: const Text('+ Добавить', style: TextStyle(fontSize: 15, color: Colors.white)),
                        onPressed: () => _showAddTaskDialog(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('d', 'ru').format(_selectedDate),
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                      bool isSelected = isSameDay(date, _selectedDate);
                      // Only date part for comparison
                      final onlyDate = DateTime(date.year, date.month, date.day);
                      bool hasDeadline = _datesWithDeadlines.contains(onlyDate);
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
                            boxShadow: hasDeadline
                                ? [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.7),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
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
                  child: tasks.isEmpty
                      ? const Center(child: Text('Нет заданий на выбранную дату'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index].task;
                            final subject = tasks[index].subject;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: GestureDetector(
                                onTap: () => _showEditTaskDialog(task, subject),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        task.duration,
                                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: subject.color.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  subject.title,
                                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                                ),
                                                const Icon(Icons.more_vert, size: 18),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              task.title,
                                              style: const TextStyle(color: Colors.black54),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Checkbox(
                                                  value: task.isCompleted,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      task.isCompleted = val ?? false;
                                                      SubjectsManager().saveAll();
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  task.isCompleted ? "Выполнено" : "Не выполнено",
                                                  style: TextStyle(
                                                    color: task.isCompleted ? Colors.green : Colors.redAccent,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    String? selectedSubjectTitle = SubjectsManager().subjects.isNotEmpty ? SubjectsManager().subjects[0].title : null;
    String taskTitle = '';
    TimeOfDay selectedTime = const TimeOfDay(hour: 12, minute: 0);
    bool showError = false;
    showCupertinoDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return CupertinoAlertDialog(
              title: const Text('Новое задание'),
              content: Column(
                children: [
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final result = await showCupertinoModalPopup<String>(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoActionSheet(
                            title: const Text('Выберите предмет'),
                            actions: SubjectsManager().subjects.map((s) => CupertinoActionSheetAction(
                              onPressed: () {
                                Navigator.of(context).pop(s.title);
                              },
                              child: Text(s.title),
                            )).toList(),
                            cancelButton: CupertinoActionSheetAction(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Отмена'),
                            ),
                          );
                        },
                      );
                      if (result != null) {
                        setStateDialog(() {
                          selectedSubjectTitle = result;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedSubjectTitle ?? 'Выберите предмет', style: const TextStyle(color: Colors.black)),
                          const Icon(CupertinoIcons.chevron_down, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    placeholder: 'Название задания',
                    onChanged: (val) {
                      taskTitle = val;
                      if (showError && val.trim().isNotEmpty) {
                        setStateDialog(() {
                          showError = false;
                        });
                      }
                    },
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    style: const TextStyle(color: Colors.black),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    placeholderStyle: TextStyle(
                      color: showError ? Colors.red : Colors.grey,
                      fontSize: showError ? 18 : 14,
                      fontWeight: showError ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: true,
                      initialDateTime: DateTime(0, 0, 0, selectedTime.hour, selectedTime.minute),
                      onDateTimeChanged: (dt) {
                        setStateDialog(() {
                          selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Отмена'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                CupertinoDialogAction(
                  child: const Text('Сохранить'),
                  onPressed: () {
                    if (selectedSubjectTitle != null && taskTitle.trim().isNotEmpty) {
                      final subject = SubjectsManager().subjects.firstWhere((s) => s.title == selectedSubjectTitle);
                      final onlyDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
                      subject.addTasks([
                        Task(
                          title: taskTitle,
                          duration: selectedTime.format(context),
                          isCompleted: false,
                          deadline: onlyDate,
                        )
                      ]);
                      SubjectsManager().saveAll();
                      setState(() {});
                      Navigator.of(ctx).pop();
                    } else if (taskTitle.trim().isEmpty) {
                      setStateDialog(() {
                        showError = true;
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditTaskDialog(Task task, Subject subject) {
    String taskTitle = task.title;
    DateTime selectedDateTime = task.deadline ?? _selectedDate;
    showCupertinoDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return CupertinoAlertDialog(
              title: const Text('Редактировать задание'),
              content: Column(
                children: [
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    placeholder: 'Название задания',
                    controller: TextEditingController(text: taskTitle),
                    onChanged: (val) => taskTitle = val,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    style: const TextStyle(color: Colors.black),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: true,
                      initialDateTime: DateTime(0, 0, 0, selectedDateTime.hour, selectedDateTime.minute),
                      onDateTimeChanged: (dt) {
                        setStateDialog(() {
                          selectedDateTime = dt;
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Удалить'),
                  isDestructiveAction: true,
                  onPressed: () {
                    subject.tasks.remove(task);
                    SubjectsManager().saveAll();
                    setState(() {});
                    Navigator.of(ctx).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: const Text('Сохранить'),
                  onPressed: () {
                    task.title = taskTitle;
                    task.deadline = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
                    task.duration = DateFormat('HH:mm').format(selectedDateTime);
                    SubjectsManager().saveAll();
                    setState(() {});
                    Navigator.of(ctx).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: const Text('Отмена'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _TaskWithSubject {
  final Task task;
  final Subject subject;
  _TaskWithSubject({required this.task, required this.subject});
}