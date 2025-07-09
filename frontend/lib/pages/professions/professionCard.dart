import 'package:flutter/material.dart';

class ProfessionCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const ProfessionCard({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF0E736B),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
