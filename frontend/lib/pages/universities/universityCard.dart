import 'package:flutter/material.dart';

class UniversityCard extends StatelessWidget {
  final String image;
  final String title;
  final double rating;
  final VoidCallback onTap;

  const UniversityCard({
    Key? key,
    required this.image,
    required this.title,
    required this.rating,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Image.network(
                image,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Ошибка загрузки изображения: $error');
                  return Container(
                    color: Colors.grey,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.white),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color.fromARGB(255, 59, 174, 128).withOpacity(0.5),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
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
