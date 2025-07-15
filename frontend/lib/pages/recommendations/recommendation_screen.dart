import 'package:flutter/material.dart';
import 'package:smartify/pages/recommendations/recommendation.dart';
import 'package:smartify/pages/recommendations/recommendation_card.dart';
import 'package:smartify/pages/recommendations/recommendation_small_card.dart';
import 'package:smartify/pages/api_server/api_save_prof.dart'; // тут лежит ProfessionPrediction

class RecommendationScreen extends StatefulWidget {
  final List<ProfessionPrediction> predictions;

  const RecommendationScreen({super.key, required this.predictions});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  List<Recommendation> recommendations = [];

  @override
  void initState() {
    super.initState();
    processPredictions();
  }

  void processPredictions() {
    setState(() {
      recommendations = widget.predictions.map((p) {
        return Recommendation(
          name: p.name,
          score: p.score,
          description: p.description,
          positives: p.positives,
          negatives: p.negatives,
        );
      }).toList();

      recommendations.sort((a, b) => b.score.compareTo(a.score));
    });
  }

  @override
  Widget build(BuildContext context) {
    final topRecommendations = recommendations.take(3).toList();
    final smallRecommendations = recommendations.skip(3).take(2).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Рекомендуемые\nпрофессии',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: recommendations.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    for (final rec in topRecommendations)
                      RecommendationCard(recommendation: rec),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: smallRecommendations.map(
                        (rec) => ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth:
                                (MediaQuery.of(context).size.width - 40) / 2,
                          ),
                          child: IntrinsicHeight(
                            child: RecommendationSmallCard(
                              recommendation: rec,
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
