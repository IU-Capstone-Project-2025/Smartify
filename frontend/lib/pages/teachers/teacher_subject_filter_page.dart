import 'package:flutter/material.dart';

class TeacherSubjectFilterPage extends StatelessWidget {
  const TeacherSubjectFilterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Предмет'),
      ),
      body: const Center(
        child: Text('Фильтр по предмету будет здесь'),
      ),
    );
  }
} 