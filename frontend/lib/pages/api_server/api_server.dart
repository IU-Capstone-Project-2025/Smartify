import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:smartify/pages/api_server/api_token.dart';
import 'package:http/http.dart' as http;
import 'package:smartify/pages/api_server/api_save_data.dart';
import 'package:smartify/pages/api_server/api_save_prof.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartify/pages/tracker/tracker_classes.dart';
import 'package:smartify/pages/teachers/teacher_model.dart';

// Main API service class for handling all network requests
class ApiService {
  // Production server URL
  static const String _baseUrl = 'http://213.226.112.206:22025/api';

  /// Authenticates user with email and password
  /// @param email User's email address
  /// @param password User's password
  /// @return Future<bool> indicating login success
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
      print("Connection error: $e");
      return false;
    }
  }

  /// Validates email during registration process
  /// @param email Email to validate
  /// @return Future<bool> indicating validation success
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
      print("Connection error: $e");
      return false;
    }
  }

  /// Validates registration verification code
  /// @param email User's email
  /// @param code Verification code to check
  /// @return Future<bool> indicating code validity
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
      print("Connection error: $e");
      return false;
    }
  }

  /// Sets password during registration process
  /// @param email User's email
  /// @param password Password to set
  /// @return Future<bool> indicating success
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
      print("Connection error: $e");
      return false;
    }
  }

  /// Initiates password recovery process
  /// @param email Email for password recovery
  /// @return Future<bool> indicating request success
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
      print("Connection error: $e");
      return false;
    }
  }

  /// Validates password reset code
  /// @param email User's email
  /// @param code Reset code to validate
  /// @return Future<bool> indicating code validity
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
      print("Connection error: $e");
      return false;
    }
  }

  /// Completes password reset process
  /// @param email User's email
  /// @param password New password to set
  /// @return Future<bool> indicating reset success
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
      print("Connection error: $e");
      return false;
    }
  }

  /// Refreshes access token using refresh token
  /// @param refreshToken Refresh token string
  /// @return Future<Map> containing new tokens or empty map on failure
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
      print("Connection error: $e");
      return {};
    }
  }

  /// Submits questionnaire and receives profession predictions
  /// @param questionnaire Map of questionnaire data
  /// @return Future<List<ProfessionPrediction>> list of predictions
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
        print("Questionnaire submitted successfully");
        final List<dynamic> data = json.decode(response.body);
        final predictions = data
          .map((item) => ProfessionPrediction.fromJson(item))
          .toList();
        return predictions;
      } else if (response.statusCode == 401) {
        print("Access token is invalid or expired. Trying to refresh...");

        bool refreshSuccess = await AuthService.refreshTokens();
        if (!refreshSuccess) {
          print("Failed to refresh tokens");
          return [];
        }
        return await AddQuestionnaire(questionnaire);
      } else {
        print("Questionnaire submission error: ${response.statusCode}");
        print("Server response:${response.body}");
        return [];
      }
    } catch (e) {
      print("Connection error: $e");
      return [];
    }
  }

  /// Saves tracker/subject data to server
  /// @param subjectsManager Contains tracker data to save
  /// @param tries Current retry attempt count (default 0)
  /// @return Future<bool> indicating save success
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
      print("Connection error: $e");
      return false;
    }
  }


  /// Retrieves saved tracker data from server
  /// @param subjectsManager Manager to potentially update
  /// @param tries Current retry attempt count (default 0)
  /// @return Future<List<String>?> list of trackers or null on failure
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
      print("Connection error: $e");
      return null;
    }
  }

  /// Validates token pair (access + refresh)
  /// @param accessToken Current access token
  /// @param refreshToken Current refresh token
  /// @return Future<String?> error message or null if valid
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

/// Manages teacher-related operations including:
/// - Fetching teacher data from server
/// - Caching teacher data locally
/// - Loading teacher data from cache or assets
class TeacherMeneger {
  // Local filename for teachers data
  static const fileName = 'teachers.json';


  /// Fetches latest teachers data from server and caches locally
  /// @return Future<void>
  static Future<void> UpdateTeachers() async {
    try {
      final token = await AuthService.getAccessToken();

      final response = await http.post(
        Uri.parse('${ApiService._baseUrl}/get_teachers'),
        headers: {
          'Content-Type': 'application/json',
          'Access_token': token ?? '',
        },
      );

      if (response.statusCode == 200) {
        print("Response received");
        final List<dynamic> data = json.decode(response.body);
        // Save to local cache
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
      } else if (response.statusCode == 401) {
        print("Access token is invalid or expired. Trying to refresh...");

        bool refreshSuccess = await AuthService.refreshTokens();
        if (!refreshSuccess) {
          print("Failed to refresh tokens");
          return ;
        }
        return await UpdateTeachers();
      } else {
        print("Request error: ${response.statusCode}");
        print("Server response: ${response.body}");
        return ;
      }
    } catch (e) {
      print("Connection error: $e");
      return ;
    }
  }

  /// Loads teachers data from local cache
  /// @return Future<String> JSON string of teachers data  
  static Future<String> loadSavedJsonTeachers() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      String jsonString = await file.readAsString();
      return jsonString;
    } catch (e) {
      print("load failed: $e");
      return await loadInitialJsonTeachers();
    }
  }

  /// Loads initial teachers data from app assets
  /// @return Future<String> JSON string of default teachers data
  static Future<String> loadInitialJsonTeachers() async {
    String jsonString = await rootBundle.loadString('assets/$fileName');
    return jsonString;
  }

  static Future<String> UpdateTeachersAndReturn() async {
    try {
      final token = await AuthService.getAccessToken();

      final response = await http.post(
        Uri.parse('${ApiService._baseUrl}/get_teachers'),
        headers: {
          'Content-Type': 'application/json',
          'Access_token': token ?? '',
        },
      );

      if (response.statusCode == 200) {
        print("Ответ получен");
        final List<dynamic> data = json.decode(response.body);
        return response.body;
      } else if (response.statusCode == 401) {
        print("Access token is invalid or expired. Trying to refresh...");

        bool refreshSuccess = await AuthService.refreshTokens();
        if (!refreshSuccess) {
          print("Не удалось обновить токены");
          return "";
        }
        return await UpdateTeachersAndReturn();
      } else {
        print("Ошибка при отправке запроса: ${response.statusCode}");
        print("Ответ сервера: ${response.body}");
        return "";
      }
    } catch (e) {
      print("Ошибка соединенея: $e");
      return "";
    }
  }
  static Future<String> loadTeachers() async {
    try {
      final String s = await UpdateTeachersAndReturn();
      if (s.isNotEmpty) {
        print("Successful direct return of teachers");
        return s;
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      String jsonString = await file.readAsString();
      return jsonString;
    } catch (e) {
      print("Блин, не работает походу $e");
      return await loadInitialJsonTeachers();
    }
  }
}


 /// Manages universities data including:
 /// - Fetching latest data from server
 /// - Caching data locally
 /// - Loading from cache or assets

class UniversitiesMeneger {
  // Local filename for universities data
  static const fileName = 'universities.json';
  
  /// Fetches latest universities data from server and caches locally
  /// @return Future<void>

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
        print("Request error:  ${response.statusCode}");
        print("Server response: ${response.body}");
        return;
      }
    } catch (e) {
      print("Connection error: $e");
      return;
    }
  }

  /// Loads universities data from local cache
  /// @return Future<List<dynamic>> parsed JSON data
  static Future<List<dynamic>> loadSavedJson() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      String jsonString = await file.readAsString();
      return jsonDecode(jsonString);
    } catch (e) {
      print("load failed");
      return await loadInitialJson();
    }
  }
  /// Loads initial universities data from app assets
  /// @return Future<List<dynamic>> parsed JSON data
  static Future<List<dynamic>> loadInitialJson() async {
    String jsonString = await rootBundle.loadString('assets/$fileName');
    return jsonDecode(jsonString);
  }
}