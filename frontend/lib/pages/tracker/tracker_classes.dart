import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Task {
  String title;
  String duration;
  DateTime? deadline;
  bool isCompleted;

  Task({
    required this.title,
    required this.duration,
    required this.deadline,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'duration': duration,
      'deadline': deadline?.toIso8601String(),
      'isCompleted': isCompleted
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    DateTime? dt;
    if (json['deadline'] != null && json['deadline'] is DateTime?) {
      dt = json['deadline'];
    }
    else if (json['deadline'] != null) {
      dt = DateTime.parse(json['deadline']);
    }
    return Task(
      title: json['title'], 
      duration: json['duration'], 
      deadline: dt,
      isCompleted: json['isCompleted'] ?? false
    );
  }
}

class TaskCalendar {
  String title;
  String duration;
  Color color;
  String subjectTitle;
  bool isCompleted;


  TaskCalendar({
    required this.title,
    required this.duration,
    required this.color,
    required this.isCompleted,
    required this.subjectTitle
  });

  factory TaskCalendar.fromJson(Map<String, dynamic> jsonData) {
    return TaskCalendar(
      title: jsonData['title'], 
      duration: jsonData['duration'], 
      color: jsonData['color'], 
      isCompleted: jsonData['completed'], 
      subjectTitle: jsonData['subject']
    );
  }
}

class Subject {
  List<Task> tasks;
  String title;
  IconData icon;
  Color color;

  Subject({
    required this.title,
    this.icon = Icons.book, 
    this.color = const Color.fromARGB(255, 0, 150, 136),
    this.tasks = const []
  });

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> tasksJson = [];
    for (var task in tasks) {
      tasksJson.add(task.toJson());
    }
    return {
      'title': title,
      'icon': icon.codePoint,
      'color': color.value,
      'tasks': tasksJson
    };
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    List<Task> loadTasks = [];
    List<dynamic>? jsonTasks = json['tasks'];
    if (jsonTasks != null) {
      for (var taskJson in json['tasks']) {
        loadTasks.add(Task.fromJson(taskJson));
      }
    }
    return Subject(
      title: json['title'] as String,
      icon: IconData(json['icon']),
      color: Color(json['color']),
      tasks: loadTasks
    );
  }

  void addTasks(List<Task> newTasks) {
    tasks.addAll(newTasks);
  }
  void removeTasks(int index) {
    if (index < 0 || index >= tasks.length) {
      return;
    }
    tasks.removeAt(index);
  }
}

class SubjectsManager {
  List<Subject> subjects;
  SubjectsManager() : subjects = [];

  Future<void> saveAll() async {
    final sharedPref = await SharedPreferences.getInstance();

    List<String> subjectsJson = [];
    for (var sub in subjects) {
      subjectsJson.add(jsonEncode(sub.toJson()));
    }

    await sharedPref.setString("subjects", jsonEncode({
      "data": subjectsJson
    }));
    // потом можно будет добавить проверку на то, что записались данные или нет
    // и в зависимости от этого отображать раззные данные
  }

  Future<void> loadAll() async {
    final sharedPref = await SharedPreferences.getInstance();
    
    String? data = sharedPref.getString("subjects");
    if (data == null) {
      return;
    }

    final decoded = jsonDecode(data);
    final List<dynamic> subjectsJson = decoded['data'];

    subjects.clear();

    for (var sub in subjectsJson) {
      final Map<String, dynamic> subJson = jsonDecode(sub);
      subjects.add(Subject.fromJson(subJson));
    }
  }

  void addSubject(Subject subject) {
    subjects.add(subject);
  }
  void removeSubject(int index) {
    if (index < 0 || index >= subjects.length) {
      return;
    }
    subjects.removeAt(index);
  }
}