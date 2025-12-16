import 'package:shared_preferences/shared_preferences.dart';
import 'package:agros/core/services/api_service.dart';
import 'package:logging/logging.dart';

class AuthRepository {
  static final Logger _logger = Logger('AuthRepository');
  final ApiService _api = ApiService();

  Future<bool> checkUserExists(String phoneNumber) async {
    try {
      _logger.info('Checking if phone exists: $phoneNumber');
      final response = await _api.post('/check-phone', {
        'phone_number': phoneNumber,
      });

      _logger.fine('Check phone response: $response');

      if (response != null && response['exists'] != null) {
        bool exists = response['exists'] as bool;
        _logger.info('User exists: $exists');
        return exists;
      }

      _logger.warning('Response format unexpected, returning false');
      return false;
    } catch (e) {
      _logger.severe('Check Phone Error: $e');
      // Jika endpoint tidak tersedia, return true untuk langsung coba login
      _logger.info('Endpoint might not exist, will attempt login directly');
      return true;
    }
  }

  Future<bool> login(String phoneNumber) async {
    try {
      _logger.info('Attempting login for: $phoneNumber');
      final response = await _api.post('/login', {'phone_number': phoneNumber});

      _logger.fine('Login response: $response');

      if (response != null && response['token'] != null) {
        final String token = response['token'];
        _logger.info('Token received, saving to storage');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        if (response['data'] != null) {
          await prefs.setString(
            'user_name',
            response['data']['name'] ?? 'Petani',
          );
          _logger.fine("User name saved: ${response['data']['name']}");
        }

        _logger.info('Login successful');
        return true;
      }

      _logger.warning('Login failed: No token in response');
      return false;
    } catch (e) {
      _logger.severe('Login Error: $e');
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      await _api.post('/logout', {});

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }
}
