import 'package:flutter/material.dart';

class TeacherOfferPage extends StatefulWidget {
  final Map<String, dynamic> teacher;
  const TeacherOfferPage({Key? key, required this.teacher}) : super(key: key);

  @override
  State<TeacherOfferPage> createState() => _TeacherOfferPageState();
}

class _TeacherOfferPageState extends State<TeacherOfferPage> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _formatController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final FocusNode _subjectFocus = FocusNode();
  final FocusNode _goalFocus = FocusNode();
  final FocusNode _timeFocus = FocusNode();
  final FocusNode _formatFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();

  @override
  void dispose() {
    _subjectController.dispose();
    _goalController.dispose();
    _timeController.dispose();
    _formatController.dispose();
    _descriptionController.dispose();
    _subjectFocus.dispose();
    _goalFocus.dispose();
    _timeFocus.dispose();
    _formatFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Заявка на репетитора',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Опишите свои цели и найдите идеального преподавателя',
              style: TextStyle(color: Colors.black54, fontSize: 14),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),
            _OfferTile(
              title: 'Предмет',
              controller: _subjectController,
              focusNode: _subjectFocus,
              hint: 'Введите предмет',
            ),
            const SizedBox(height: 10),
            _OfferTile(
              title: 'Цель',
              controller: _goalController,
              focusNode: _goalFocus,
              hint: 'Опишите вашу цель',
            ),
            const SizedBox(height: 10),
            _OfferTile(
              title: 'Доступное время',
              controller: _timeController,
              focusNode: _timeFocus,
              hint: 'Когда вам удобно заниматься?',
            ),
            const SizedBox(height: 10),
            _OfferTile(
              title: 'Формат',
              controller: _formatController,
              focusNode: _formatFocus,
              hint: 'Онлайн, офлайн или оба варианта',
            ),
            const SizedBox(height: 10),
            _OfferTile(
              title: 'Описание',
              controller: _descriptionController,
              focusNode: _descriptionFocus,
              hint: 'Расскажите о себе или пожеланиях',
              maxLines: 2,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B6C5A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  // TODO: обработка отправки заявки
                },
                child: const Text('Отправить заявку', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

class _OfferTile extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final int maxLines;
  const _OfferTile({
    required this.title,
    required this.controller,
    required this.focusNode,
    required this.hint,
    this.maxLines = 1,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFB6CFC8),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 2),
          TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
} 