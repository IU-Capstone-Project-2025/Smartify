import 'package:flutter/material.dart';
import 'teacher_offer_page.dart';

class TeacherDetailPage extends StatelessWidget {
  final Map<String, dynamic> teacher;
  const TeacherDetailPage({Key? key, required this.teacher}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String name = teacher['name'] ?? '';
    final String email = teacher['email'] ?? '';
    final String phone = teacher['phone'] ?? '';
    final String city = teacher['city'] ?? '';
    final String country = teacher['country'] ?? '';
    final String rating = teacher['rating']?.toString() ?? '';
    final String subjects = teacher['subject'] is List
        ? (teacher['subject'] as List).join(', ')
        : (teacher['subject'] ?? '');
    final String experience = teacher['level'] ?? '';
    final String about = teacher['about'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black38),
            onPressed: () {},
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Иллюстрация/аватар сверху
            Container(
              height: 180,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFB6E3DF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                child: Image.asset(
                  'assets/user_avatar.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            // Карточка с данными
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              transform: Matrix4.translationValues(0, -32, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  if (email.isNotEmpty)
                    Text(email, style: const TextStyle(color: Colors.black54, fontSize: 15)),
                  if (phone.isNotEmpty)
                    Text(phone, style: const TextStyle(color: Colors.black54, fontSize: 15)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (city.isNotEmpty || country.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.black45),
                            Text(
                              [city, country].where((e) => e.isNotEmpty).join(', '),
                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      if (rating.isNotEmpty)
                        Row(
                          children: [
                            ...List.generate(5, (i) => Icon(
                                  Icons.star,
                                  color: i < double.tryParse(rating)!.round()
                                      ? Colors.amber
                                      : Colors.grey[300],
                                  size: 18,
                                )),
                            const SizedBox(width: 4),
                            Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _InfoBlock(title: 'Предметы', value: subjects),
                  const SizedBox(height: 10),
                  _InfoBlock(title: 'Стаж', value: experience),
                  const SizedBox(height: 10),
                  _InfoBlock(title: 'О себе', value: about),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE3F1ED),
                        foregroundColor: const Color(0xFF3B6C5A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeacherOfferPage(teacher: teacher),
                          ),
                        );
                      },
                      child: const Text('Оставить заявку', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String title;
  final String value;
  const _InfoBlock({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
} 