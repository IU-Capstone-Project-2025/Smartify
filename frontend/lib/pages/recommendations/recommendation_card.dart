import 'package:flutter/material.dart';
import 'package:smartify/pages/recommendations/recommendation.dart';
import 'package:smartify/pages/recommendations/recommendation_detail_screen.dart';

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;

  const RecommendationCard({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final shortPositive = recommendation.positives.isNotEmpty
        ? recommendation.positives.first
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(178, 216, 216, 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Иконку убрали, просто отступ слева
          const SizedBox(width: 4),

          // Текстовая часть
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,),
                ),
                const SizedBox(height: 6),
                Text(
                  '- $shortPositive',
                  style: const TextStyle(fontSize: 10, color: Color.fromRGBO(0, 76, 76, 1), fontWeight: FontWeight.w400,),
                ),
              ],
            ),
          ),

          // % и Play
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${recommendation.score.round()}%",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              IconButton(
                icon: Icon(Icons.play_circle_rounded, size: 41, color: Color.fromRGBO(102, 178, 178, 1),),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecommendationDetailScreen(
                        recommendation: recommendation,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}