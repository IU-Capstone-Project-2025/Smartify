class Recommendation {
  final String name;
  final double score;
  final String description;
  final List<String> positives;
  final List<String> negatives;

  Recommendation({
    required this.name,
    required this.score,
    required this.description,
    required this.positives,
    required this.negatives,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      name: json['name'],
      score: json['score'].toDouble(),
      description: json['description'],
      positives: List<String>.from(json['positives'] ?? []),
      negatives: List<String>.from(json['negatives'] ?? []),
    );
  }
}
