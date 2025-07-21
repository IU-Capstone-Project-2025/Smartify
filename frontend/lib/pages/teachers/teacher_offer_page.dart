import 'package:flutter/material.dart';
import 'package:smartify/l10n/app_localizations.dart';
import 'teacher_offer_sent_page.dart';
import 'package:smartify/l10n/app_localizations.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.teacherOfferTitle,
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.teacherOfferSubtitle,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),
            _OfferTile(
              title: AppLocalizations.of(context)!.subject,
              controller: _subjectController,
              focusNode: _subjectFocus,
              hint: AppLocalizations.of(context)!.enterSubject,
            ),
            const SizedBox(height: 10),
            _OfferTile(
              title: AppLocalizations.of(context)!.goal,
              controller: _goalController,
              focusNode: _goalFocus,
              hint: AppLocalizations.of(context)!.enterGoal,
            ),
            const SizedBox(height: 10),
            _OfferTile(
              title: AppLocalizations.of(context)!.availableTime,
              controller: _timeController,
              focusNode: _timeFocus,
              hint: AppLocalizations.of(context)!.enterAvailableTime,
            ),
            const SizedBox(height: 10),
            _OfferTile(
              title: AppLocalizations.of(context)!.format,
              controller: _formatController,
              focusNode: _formatFocus,
              hint: AppLocalizations.of(context)!.enterFormat,
            ),
            const SizedBox(height: 10),
            _OfferTile(
              title: AppLocalizations.of(context)!.description,
              controller: _descriptionController,
              focusNode: _descriptionFocus,
              hint: AppLocalizations.of(context)!.enterDescription,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TeacherOfferSentPage(),
                    ),
                  );
                },
                child: Text(AppLocalizations.of(context)!.sendOffer, style: const TextStyle(fontSize: 16)),
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