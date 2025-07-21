import 'package:flutter/material.dart';
import 'teacher_offer_page.dart';
import 'package:smartify/l10n/app_localizations.dart';

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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          name,
          style: theme.textTheme.titleLarge,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Color(0xFF54D0C0) : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
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
                child: (teacher['avatarurl']?.toString() ?? '').startsWith('http') || (teacher['avatarurl']?.toString() ?? '').startsWith('https')
                    ? Image.network(
                        teacher['avatarurl']?.toString() ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, color: Colors.grey, size: 50),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/user_avatar.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : Image.asset(
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
                color: theme.cardColor,
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
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  if (email.isNotEmpty)
                    Text('${AppLocalizations.of(context)!.email}: $email', style: theme.textTheme.bodyMedium),
                  if (phone.isNotEmpty)
                    Text('${AppLocalizations.of(context)!.phone}: $phone', style: theme.textTheme.bodyMedium),
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
                              style: theme.textTheme.bodyMedium,
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
                            Text(rating, style: theme.textTheme.bodyMedium),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _InfoBlock(title: AppLocalizations.of(context)!.subjects, value: subjects),
                  const SizedBox(height: 10),
                  _InfoBlock(title: AppLocalizations.of(context)!.experience, value: experience),
                  const SizedBox(height: 10),
                  _InfoBlock(title: AppLocalizations.of(context)!.about, value: about),
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
                      child: Text(AppLocalizations.of(context)!.leaveRequest, style: const TextStyle(fontSize: 16)),
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