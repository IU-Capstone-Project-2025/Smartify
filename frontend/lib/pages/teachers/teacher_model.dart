/*class Teacher {
  final String name;
  final String subject;
  final String level;
  final String price;
  final String email;
  final String phone;
  final String city;
  final double rating;
  final String avatarUrl;

  Teacher({
    required this.name,
    required this.subject,
    required this.level,
    required this.price,
    required this.email,
    required this.phone,
    required this.city,
    required this.rating,
    required this.avatarUrl,
  });
}*/

class Teacher {
  final String name;
  final String subject;
  final String level;
  final String price;
  final String city;
  final double rating;
  final String avatarUrl;
  final String link;
  final DateTime timestamp;

  Teacher({
    required this.name,
    required this.subject,
    required this.level,
    required this.price,
    required this.city,
    required this.rating,
    required this.avatarUrl,
    required this.link,
    required this.timestamp,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      name: json['name'] ?? '',
      subject: json['subject'] ?? '',
      level: json['level'] ?? '',
      price: json['price'] ?? '',
      city: json['city'] ?? '',
      rating: json['rating'] ?? '',
      avatarUrl: json['avatarurl'] ?? '',
      link: json['link'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}