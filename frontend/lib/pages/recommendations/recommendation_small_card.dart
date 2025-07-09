import 'package:flutter/material.dart';
import 'package:smartify/pages/recommendations/recommendation.dart';
import 'package:smartify/pages/recommendations/recommendation_detail_screen.dart';

class RecommendationSmallCard extends StatelessWidget {
  final Recommendation recommendation;

  const RecommendationSmallCard({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 128, 128, 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // распределение по всей высоте
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхняя текстовая часть
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  softWrap: true,
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                  softWrap: true,
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Нижняя часть
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${recommendation.score.round()}%",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.play_circle_rounded,
                    size: 41,
                    color: Color.fromRGBO(102, 178, 178, 1),
                  ),
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
      ),
    );
  }
}
