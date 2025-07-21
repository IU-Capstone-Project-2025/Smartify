import 'package:flutter/material.dart';
import 'package:smartify/pages/universities/universityCard.dart';

class UniversityGrid extends StatelessWidget {
  final List<Map<String, dynamic>> universities = [
    
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = kToolbarHeight; // 56
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // Высота, доступная под GridView
    final availableHeight = screenHeight - appBarHeight - statusBarHeight;

    return Scaffold(
      appBar: AppBar(title: const Text('Universities')),
      body: Center(
        child: SizedBox(
          height: availableHeight,
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1, // квадрат
            physics: const NeverScrollableScrollPhysics(), // запрет прокрутки
            children: universities.map((university) {
              return UniversityCard(
                image: university['image'],
                title: university['title'],
                rating: university['rating'], onTap: () {  },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
