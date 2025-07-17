import 'package:flutter/material.dart';
import 'package:smartify/pages/api_server/api_server.dart';
import 'package:smartify/pages/menu/menu_page.dart';
import 'package:smartify/pages/reset/reset_password_page.dart';
import 'package:smartify/pages/nav/nav_page.dart';
import 'package:smartify/l10n/app_localizations.dart';
import 'package:smartify/pages/sign/sign_up_page.dart'; // Исправленный импорт

class AuthorizationPage extends StatefulWidget {
  const AuthorizationPage({super.key});

  @override
  State<AuthorizationPage> createState() => _AuthorizationPageState();
}

class _AuthorizationPageState extends State<AuthorizationPage> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();     // To retrieve the entered email
  final _passwordController = TextEditingController();  // To retrieve the entered password

  Future<void> _login() async {
    final response = await ApiService.login(
      _emailController.text, 
      _passwordController.text
    );

    if (response) {
      // Successful entry
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()), 
      );
    } else {
      // Failed to log in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка входа')),
      );
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white, // убрано для поддержки темы
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0,
        // backgroundColor: Colors.white, // убрано для поддержки темы
        foregroundColor: Colors.black,
        title: const Text(
          'Вход в аккаунт',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Почта',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 6),
            TextField(
              controller:  _emailController,
              decoration: InputDecoration(
                hintText: 'Почта',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            const Text(
              'Пароль',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 6),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Введите пароль',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _login, // TODO: логика входа
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF54D0C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Войти', // Жёстко прописываем текст
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpPage(),
                    ),
                  );
                },
                child: const Text(
                  'Создать аккаунт',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResetPasswordPage(),
                        ),
                  );
                },
                child: const Text(
                  'Забыли пароль?',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text.rich(
                  TextSpan(
                    text: 'Пользуясь Smartify, вы соглашаетесь с условиями использования и политикой конфиденциальности.',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
