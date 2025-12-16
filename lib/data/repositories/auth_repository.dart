import 'package:shared_preferences/shared_preferences.dart';
import 'package:agros/core/services/api_service.dart';

class AuthRepository {
  final ApiService _api = ApiService();

  Future<bool> checkUserExists(String phoneNumber) async {
    try {
      final response = await _api.post('/check-phone', {
        'phone_number': phoneNumber,
      });

      if (response != null && response['exists'] != null) {
        return response['exists'] as bool;
      }
      return false;
    } catch (e) {
      print("Check Phone Error: $e");
      return false;
    }
  }

  Future<bool> login(String phoneNumber) async {
    try {
      final response = await _api.post('/login', {
        'phone_number': phoneNumber, 
      });

      if (response != null && response['token'] != null) {
        final String token = response['token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        
        if (response['data'] != null) {
           await prefs.setString('user_name', response['data']['name'] ?? 'Petani');
        }

        return true;
      }
      
      return false;

    } catch (e) {
      print("Login Error: $e");
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