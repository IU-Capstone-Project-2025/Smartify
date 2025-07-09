import 'package:flutter/material.dart';
import 'package:smartify/pages/welcome/welcome_page.dart';
import 'package:smartify/pages/api_server/api_token.dart';
import 'package:smartify/pages/api_server/api_save_data.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.95,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
              tileColor: const Color(0xFFF5F5F5),
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
            _buildTile(Icons.language, 'Язык'),
            _buildTile(Icons.help_outline, 'Помощь'),
            _buildTile(Icons.privacy_tip_outlined, 'Политика конфиденциальности'),
            _buildDarkModeTile(),
            const Spacer(),
            ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: const Color(0xFFF5F5F5),
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Выйти', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Подтвердите выход'),
                    content: const Text('Вы уверены, что хотите выйти?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Отмена'),
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
                        child: const Text('Выйти'),
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
        tileColor: const Color(0xFFF5F5F5),
        leading: Icon(icon, color: Colors.black),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }

  Widget _buildDarkModeTile() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: const Color(0xFFF5F5F5),
        leading: const Icon(Icons.nightlight_round_outlined, color: Colors.black),
        title: const Text('Темная тема'),
        trailing: Switch(
          value: false,
          onChanged: (value) {
            // Add your theme toggle logic here
          },
        ),
        onTap: () {},
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
