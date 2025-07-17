import 'package:flutter/material.dart';
import 'package:smartify/l10n/app_localizations.dart';
import 'package:smartify/pages/welcome/welcome_page.dart';
import 'package:smartify/pages/api_server/api_token.dart';
import 'package:smartify/pages/api_server/api_save_data.dart';
import '../../main.dart'; // путь до main.dart

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.95,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                Image.asset(
                  'logo.png',
                  height: 50,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              leading: const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('assets/user_avatar.jpg'),
              ),
              title:
              FutureBuilder(
                future: ManageData.getDataAsync('email'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  return Text(snapshot.data ?? "example@example.com");
                },
              ),
              trailing: const Icon(Icons.edit, color: Color(0xFF54D0C0)),
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildLanguageTile(context),
            _buildTile(Icons.help_outline, AppLocalizations.of(context)!.help),
            _buildTile(Icons.privacy_tip_outlined, AppLocalizations.of(context)!.privacyPolicy),
            _buildDarkModeTile(context),
            const Spacer(),
            ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(AppLocalizations.of(context)!.logout, style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(AppLocalizations.of(context)!.confirmLogout),
                    content: Text(AppLocalizations.of(context)!.areYouSureLogout),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          _logOutFromAccount();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const WelcomePage(),
                            ),
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.logout),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            const Text('Version 1.1.1', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(icon, color: Colors.black),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: const Icon(Icons.language, color: Colors.black),
        title: Text(AppLocalizations.of(context)!.language),
        trailing: DropdownButton<Locale>(
          value: localeNotifier.value ?? Localizations.localeOf(context),
          items: const [
            DropdownMenuItem(
              value: Locale('ru'),
              child: Text('Русский'),
            ),
            DropdownMenuItem(
              value: Locale('en'),
              child: Text('English'),
            ),
          ],
          onChanged: (locale) {
            localeNotifier.value = locale;
          },
        ),
      ),
    );
  }

  Widget _buildDarkModeTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeModeNotifier,
        builder: (context, mode, _) {
          return ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: const Icon(Icons.nightlight_round_outlined, color: Colors.black),
            title: Text(AppLocalizations.of(context)!.darkTheme),
            trailing: Switch(
              value: mode == ThemeMode.dark,
              onChanged: (value) {
                themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
              },
            ),
            onTap: () {},
          );
        },
      ),
    );
  }

  Future<bool> _logOutFromAccount() async {
    try {
      await AuthService.deleteTokens();
      await ManageData.removeAllData();
      return true;
    } catch (e) {
      return false;
    }
  }
}
