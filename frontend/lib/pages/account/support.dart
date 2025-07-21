import 'package:flutter/material.dart';
import 'package:smartify/l10n/app_localizations.dart';
import 'package:smartify/pages/account/faq.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true, // Центрируем заголовок
        title: Text(
          AppLocalizations.of(context)!.help,
          style: theme.textTheme.titleLarge,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSupportTile(
              context,
              icon: Icons.mail_outline,
              title: AppLocalizations.of(context)!.contactUs,
              subtitle: 'projectsmartifyapp@gmail.com',
              onTap: () {},
              showArrow: false, // Убираем стрелку
            ),
            _buildSupportTile(
              context,
              icon: Icons.info_outline,
              title: AppLocalizations.of(context)!.faq,
              subtitle: AppLocalizations.of(context)!.commonQuestions,
                onTap: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FAQPage()),
                );
              },
              showArrow: true,
            ),
            const Spacer(),
            Center(
              child: Text(
                'Smartify © 2025',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool showArrow,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: theme.cardColor,
        leading: Icon(icon, color: theme.iconTheme.color),
        title: Text(title, style: theme.textTheme.bodyMedium),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        trailing: showArrow
            ? Icon(Icons.arrow_forward_ios, size: 16, color: theme.iconTheme.color)
            : null,
        onTap: onTap,
      ),
    );
  }
}
