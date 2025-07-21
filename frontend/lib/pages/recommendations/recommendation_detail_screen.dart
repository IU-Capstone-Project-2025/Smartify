import 'package:flutter/material.dart';
import 'package:smartify/pages/recommendations/recommendation.dart';

class RecommendationDetailScreen extends StatelessWidget {
  final Recommendation recommendation;

  const RecommendationDetailScreen({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(), // стандартная стрелка назад
        title: Text(
          recommendation.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black, // иконка и текст чёрные
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Соответствие: ${recommendation.score.round()}%',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                // Плюсы
                if (recommendation.positives.isNotEmpty) ...[
                  const Text('Плюсы',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(221, 240, 230, 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: recommendation.positives
                          .map((p) =>
                              Text('- $p', style: const TextStyle(fontSize: 14)))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Минусы
                if (recommendation.negatives.isNotEmpty) ...[
                  const Text('Минусы',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(253, 228, 228, 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: recommendation.negatives
                          .map((n) =>
                              Text('- $n', style: const TextStyle(fontSize: 14)))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Описание
                const Text('Описание',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(235, 234, 236, 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recommendation.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}