import 'package:agros/core/services/api_service.dart';

class PanenRepository {
  final ApiService _api = ApiService();

  Future<bool> createPanen(Map<String, dynamic> data) async {
    try {
      await _api.post('/panen', data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getPanenList() async {
    try {
      final response = await _api.get('/panen');
      return (response is Map && response.containsKey('data')) ? response['data'] : [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> updatePanen(String id, Map<String, dynamic> data) async {
    try {
      await _api.patch('/panen/$id', data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyPanen(String id) async {
    try {
      await _api.post('/panen/$id/verify', {});
      return true;
    } catch (e) {
      return false;
    }
  }
}