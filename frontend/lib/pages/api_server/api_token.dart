import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartify/pages/api_server/api_server.dart';

class AuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static late final SharedPreferences _prefs;
  static final String _accessTokenKey = 'access_token';
  static final String _refreshTokenKey = 'refresh_token';

  static Future<void> init() async {
    if (kIsWeb) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  // Сохранить токены
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (kIsWeb) {
      await _prefs.setString(_accessTokenKey, accessToken);
      await _prefs.setString(_refreshTokenKey, refreshToken);
    } else {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  // Получить access-токен
  static Future<String?> getAccessToken() async {
    if (kIsWeb) {
      return _prefs.getString(_accessTokenKey);
    }
    return await _storage.read(key: _accessTokenKey);
  }

  // Получить refresh-токен
  static Future<String?> getRefreshToken() async {
    if (kIsWeb) {
      return _prefs.getString(_refreshTokenKey);
    }
    return await _storage.read(key: _refreshTokenKey);
  }

  // Удалить токены если пользователь выходит из аккаунта
  static Future<void> deleteTokens() async {
    if (kIsWeb) {
      await _prefs.remove(_accessTokenKey);
      await _prefs.remove(_refreshTokenKey);
    } 
    else {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
    }
  }

  // Обновить access-токен с помощью refresh-токена
  static Future<String?> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final newTokens = await ApiService.fetchNewAccessToken(refreshToken);
      if ( !newTokens.containsKey('access_token') || !newTokens.containsKey('refresh_token') ) {
        print('Invalid tokens received');
        return null;
      }

      String access_token = newTokens['access_token'] as String;
      String refresh_token = newTokens['refresh_token'] as String;
      await saveTokens(accessToken: access_token, refreshToken: refresh_token);
      return access_token;
    } catch (e) {
      print('Ошибка обновления токена: $e');
      return null;
    }
  }

  static Future<bool> refreshTokens() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final newTokens = await ApiService.fetchNewAccessToken(refreshToken);
      if ( !newTokens.containsKey('access_token') || !newTokens.containsKey('refresh_token') ) {
        print('Invalid tokens received');
        return false;
      }

      String access_token = newTokens['access_token'] as String;
      String refresh_token = newTokens['refresh_token'] as String;
      await saveTokens(accessToken: access_token, refreshToken: refresh_token);
      return true;
    } catch (e) {
      print('Ошибка обновления токена: $e');
      return false;
    }
  }

  static Future<bool> isAuthenticated() async {
    // 1. Проверка наличия токенов в хранилище
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    
    if (accessToken == null || refreshToken == null) {
      print('Tokens not found in storage');
      return false;
    }

    // 2. Проверка формата токенов (опционально)
    if (accessToken.isEmpty || refreshToken.isEmpty) {
      print('Empty tokens found');
      await deleteTokens();
      return false;
    }

    try {
      // 3. Проверка токенов на сервере
      final error = await ApiService.CheckTokens(accessToken, refreshToken);
      
      if (error == null) {
        return true; // Оба токена валидны
      }

      // 4. Обработка случая, когда access token устарел
      if (error == "Access Token is old") {
        final refreshSuccess = await refreshTokens();
        if (refreshSuccess) {
          return true; // Токены успешно обновлены
        }
        print('Failed to refresh tokens');
        return false;
      }

      // 5. Другие ошибки (например, неверный refresh token)
      print('Token validation error: $error');
      await deleteTokens(); // Очищаем невалидные токены
      return false;

    } catch (e) {
      print('Authentication check failed: $e');
      return false;
    }
  }
}
