import 'package:smartify/pages/api_server/api_server.dart';

class ProfessionPrediction {
  final String name;
  final double score;
  final List<String> positives;
  final List<String> negatives;
  final String description;

  ProfessionPrediction({
    required this.name,
    required this.score,
    required this.positives,
    required this.negatives,
    required this.description,
  });

  factory ProfessionPrediction.fromJson(Map<String, dynamic> json) {
    return ProfessionPrediction(
      name: json['name'],
      score: (json['score'] as num).toDouble(),
      positives: List<String>.from(json['positives'] ?? []),
      negatives: List<String>.from(json['negatives'] ?? []),
      description: json['description'] ?? '',
    );
  }
}