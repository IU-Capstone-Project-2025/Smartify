import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smartify/pages/api_server/api_server.dart';

class AuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static final String _accessTokenKey = 'access_token';
  static final String _refreshTokenKey = 'refresh_token';

  // Сохранить токены
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // Получить access-токен
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // Получить refresh-токен
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Удалить токены если пользователь выходит из аккаунта
  static Future<void> deleteTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
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
    final status = await isAuthenticatedServer();
    if (status == -1) {
      final token = await getAccessToken();
      return token != null && token.isNotEmpty;
    }
    return status == 200;
  }

  static Future<int> isAuthenticatedServer() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();

    if (accessToken == null || refreshToken == null || accessToken.isEmpty || refreshToken.isEmpty) {
      return 401;
    }

    final error = await ApiService.CheckTokens(accessToken, refreshToken);

    if (error != null && error == "Access Token is old") {
      final stts = await AuthService.refreshAccessToken();
      if (stts != null) {
        return 200;
      }
      return 401;
    }

    if (error != null) {
      return -1;
    }

    return 200;
  }
}
