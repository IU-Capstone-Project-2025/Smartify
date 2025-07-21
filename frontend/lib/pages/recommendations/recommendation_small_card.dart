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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ВЕРХНЯЯ ЧАСТЬ
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Название профессии
                Text(
                  recommendation.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  softWrap: true,
                ),

                /// Сфера (subsphere)
                const SizedBox(height: 2),
                Text(
                  recommendation.subsphere,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                /// Короткое описание
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

            /// НИЖНЯЯ ЧАСТЬ
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Процент совпадения
                Text(
                  "${recommendation.score.round()}%",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),

                /// Кнопка перехода к деталям
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
