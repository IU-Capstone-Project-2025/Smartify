import 'dart:convert';
import 'package:smartify/pages/api_server/api_token.dart';
import 'package:http/http.dart' as http;
import 'package:smartify/pages/api_server/api_save_data.dart';

class ApiService {
  //static const String _baseUrl = 'http://localhost:22025/api';
  static const String _baseUrl = 'http://213.226.112.206:22025/api';

  // Метод для входа
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AuthService.saveTokens(accessToken: data["access_token"], refreshToken: data["refresh_token"]);
        await ManageData.saveDataAsync('email', email);
        return true;
      } else {
        final data = jsonDecode(response.body);
        return false;
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return false;
    }
  }

  // Валидация email при регистрации
  static Future<bool> registration_emailValidation(String email)async {
    try {
      final response = await http.post(
      Uri.parse('$_baseUrl/registration_emailvalidation'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return true;
      } else {
        final data = jsonDecode(response.body);
        return false;
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return false;
    }
  }

  // Валидация кода подтверждения
  static Future<bool> registration_codeValidation(String email, String code)async {
    try {
      final response = await http.post(
      Uri.parse('$_baseUrl/registration_codevalidation'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'code': code
      }));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return true;
      } else {
        final data = jsonDecode(response.body);
        return false;
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return false;
    }
  }

  // Установка пароля
  static Future<bool> registration_password(String email, String password)async {
    try {
      final response = await http.post(
      Uri.parse('$_baseUrl/registration_password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password
      }));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AuthService.saveTokens(accessToken: data["access_token"], refreshToken: data["refresh_token"]);
        await ManageData.saveDataAsync('email', email);
        return true;
      } else {
        final data = jsonDecode(response.body);
        return false;
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return false;
    }
  }

  // Запрос на восстановление пароля
  static Future<bool> forgot_password(String email) async {
    try {
      final response = await http.post(
      Uri.parse('$_baseUrl/forgot_password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return true;
      } else {
        final data = jsonDecode(response.body);
        return false;
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return false;
    }
  }
  static Future<bool> resetPassword_codeValidation(String email, String code)async {
    try {
      final response = await http.post(
      Uri.parse('$_baseUrl/commit_code_reset_password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'code': code
      }));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return true;
      } else {
        final data = jsonDecode(response.body);
        return false;
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return false;
    }
  }
  static Future<bool> resetPassword_resetPassword(String email, String password)async {
    try {
      final response = await http.post(
      Uri.parse('$_baseUrl/reset_password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'newPassword': password
      }));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return true;
      } else {
        final data = jsonDecode(response.body);
        return false;
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return false;
    }
  }
  static Future<Map<String, String>> fetchNewAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
      Uri.parse('$_baseUrl/refresh_token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'refresh_token': refreshToken
      }));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'access_token': data["access_token"],
          'refresh_token': data["refresh_token"],
        };
      } else {
        return {};
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return {};
    }
  }
  // Метод для входа
  static Future<bool> AddQuestionnaire(Map<String, dynamic> questionnaire) async {
    try {
      final token = await AuthService.getAccessToken();

      final response = await http.post(
        Uri.parse('$_baseUrl/questionnaire'),
        headers: {
          'Content-Type': 'application/json',
          'Access_token': token ?? '',
        },
        body: json.encode(questionnaire),
      );

      if (response.statusCode == 200) {
        print("Анкета успешно отправлена");
        return true;
      } else if (response.statusCode == 401) {
        print("Access token is invalid or expired. Trying to refresh...");

        bool refreshSuccess = await AuthService.refreshTokens();
        if (!refreshSuccess) {
          print("Не удалось обновить токены");
          return false;
        }
        return await AddQuestionnaire(questionnaire);
      } else {
        print("Ошибка при отправке анкеты: ${response.statusCode}");
        print("Ответ сервера: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return false;
    }
  }
}

