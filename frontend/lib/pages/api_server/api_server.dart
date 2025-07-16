import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:smartify/pages/api_server/api_token.dart';
import 'package:http/http.dart' as http;
import 'package:smartify/pages/api_server/api_save_data.dart';
import 'package:smartify/pages/api_server/api_save_prof.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartify/pages/tracker/tracker_classes.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:22025/api';
  //static const String _baseUrl = 'http://213.226.112.206:22025/api';

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
  static Future<List<ProfessionPrediction>> AddQuestionnaire(Map<String, dynamic> questionnaire) async {
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
        final List<dynamic> data = json.decode(response.body);
        final predictions = data
          .map((item) => ProfessionPrediction.fromJson(item))
          .toList();
        return predictions;
      } else if (response.statusCode == 401) {
        print("Access token is invalid or expired. Trying to refresh...");

        bool refreshSuccess = await AuthService.refreshTokens();
        if (!refreshSuccess) {
          print("Не удалось обновить токены");
          return [];
        }
        return await AddQuestionnaire(questionnaire);
      } else {
        print("Ошибка при отправке анкеты: ${response.statusCode}");
        print("Ответ сервера: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return [];
    }
  }
    static Future<bool> SaveTrackers(SubjectsManager subjectsManager, [int tries = 0]) async {
    try {
      final token = await AuthService.getAccessToken();
      final trackers = subjectsManager.getJSON();
      final timeNow_ = DateTime.now().toIso8601String().split('.')[0] + 'Z';
      final response = await http.post(
        Uri.parse('$_baseUrl/savetrackers'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': token,
          'trackers': trackers,
          'timestamp': timeNow_
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Success: [CODE: ${data["code"]}], [STATUS: ${data["status"]}]");
        return true;
      } else {
        final data = jsonDecode(response.body);
        print("Error: [CODE: ${data["code"]}], [ERROR: ${data["error"]}]");
        if (data["code"] == 401) {
          if (tries < 3) {
            print("Refresh access token");
            await AuthService.refreshAccessToken();
            return await SaveTrackers(subjectsManager, tries + 1);
          }
        }
        return false;
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return false;
    }
  }

  static Future<List<String>?> GetTrackers(SubjectsManager subjectsManager, [int tries = 0]) async {
    try {
      final token = await AuthService.getAccessToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/gettrackers'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': token,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Success!");
        return (data['trackers'] as List<dynamic>).map((item) => item as String).toList();
      } else {
        final data = jsonDecode(response.body);
        print("Error: [CODE: ${data["code"]}], [ERROR: ${data["error"]}]");
        if (data["code"] == 401) {
          print("Refresh access token");
          if (tries < 3) {
            await AuthService.refreshAccessToken();
            return await GetTrackers(subjectsManager, tries + 1);
          }
        }
        return null;
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return null;
    }
  }

  static Future<String?> CheckTokens(String accessToken, String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/checktokens'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'refresh_token': refreshToken,
          'access_token': accessToken
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Success: [CODE: ${data["code"]}], [STATUS: ${data["status"]}]");
        return null;
      } else {
        final data = jsonDecode(response.body);
        return data['error'];
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return "Other Error";
    }
  }
}

class UniversitiesMeneger {
  static const fileName = 'universities.json';
  
  static Future<void> GetUniversititesJSON() async {
    try {
      final token = await AuthService.getAccessToken();

      final response = await http.get(
        Uri.parse('${ApiService._baseUrl}/update_university_json'),
        headers: {
          'Content-Type': 'application/json',
          'Access_token': token ?? '',
        }
      );
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
      } else {
        print("Ошибка при отправке анкеты: ${response.statusCode}");
        print("Ответ сервера: ${response.body}");
        return;
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return;
    }
  }
  static Future<List<dynamic>> loadSavedJson() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      String jsonString = await file.readAsString();
      return jsonDecode(jsonString);
    } catch (e) {
      print("Блин, не работает походу");
      return await loadInitialJson();
    }
  }
  static Future<List<dynamic>> loadInitialJson() async {
    String jsonString = await rootBundle.loadString('assets/$fileName');
    return jsonDecode(jsonString);
  }
}