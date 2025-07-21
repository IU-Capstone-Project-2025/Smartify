import 'package:flutter/material.dart';
import 'package:smartify/l10n/app_localizations.dart';

class TeacherSubjectFilterPage extends StatelessWidget {
  const TeacherSubjectFilterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.subject),
      ),
      body: Center(
        child: Text(AppLocalizations.of(context)!.subjectFilterHere),
      ),
    );
  }
} 