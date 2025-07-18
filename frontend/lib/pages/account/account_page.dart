import 'package:flutter/material.dart';
import 'package:smartify/l10n/app_localizations.dart';
import 'package:smartify/pages/welcome/welcome_page.dart';
import 'package:smartify/pages/api_server/api_token.dart';
import 'package:smartify/pages/api_server/api_save_data.dart';
import 'package:smartify/pages/account/support.dart';
import 'package:smartify/pages/account/terms.dart';
import '../../main.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Image.asset(
                'logo.png',
                height: 50,
                color: isDarkMode ? Colors.white : null,
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.notifications_none, color: theme.iconTheme.color),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: theme.cardColor,
            leading: const CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage('assets/user_avatar.jpg'),
            ),
            title: FutureBuilder(
              future: ManageData.getDataAsync('email'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return Text(
                  snapshot.data ?? "example@example.com",
                  style: theme.textTheme.bodyLarge,
                );
              },
            ),
            trailing: const Icon(Icons.edit, color: Color(0xFF54D0C0)),
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _buildLanguageTile(context),
          _buildTile(
            context,
            icon: Icons.help_outline,
            label: AppLocalizations.of(context)!.help,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SupportPage()),
              );
            },
          ),
          _buildTile(
            context,
            icon: Icons.privacy_tip_outlined,
            label: AppLocalizations.of(context)!.privacyPolicy,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsPage()),
              );
            },
          ),
          _buildDarkModeTile(context),
          const Spacer(),
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: theme.cardColor,
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              AppLocalizations.of(context)!.logout,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    AppLocalizations.of(context)!.confirmLogout,
                    style: theme.textTheme.titleLarge,
                  ),
                  content: Text(
                    AppLocalizations.of(context)!.areYouSureLogout,
                    style: theme.textTheme.bodyMedium,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        _logOutFromAccount();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WelcomePage(),
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
          Text(
            'Version 1.1.1',
            style: TextStyle(color: theme.textTheme.bodySmall?.color),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: theme.cardColor,
        leading: Icon(icon, color: theme.iconTheme.color),
        title: Text(label, style: theme.textTheme.bodyMedium),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.iconTheme.color),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: theme.cardColor,
        leading: Icon(Icons.language, color: theme.iconTheme.color),
        title: Text(
          AppLocalizations.of(context)!.language,
          style: theme.textTheme.bodyMedium,
        ),
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeModeNotifier,
        builder: (context, mode, _) {
          return ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: theme.cardColor,
            leading: Icon(Icons.nightlight_round_outlined, color: theme.iconTheme.color),
            title: Text(
              AppLocalizations.of(context)!.darkTheme,
              style: theme.textTheme.bodyMedium,
            ),
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
