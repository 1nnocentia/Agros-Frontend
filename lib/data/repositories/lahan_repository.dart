import 'package:agros/core/services/api_service.dart';

class LahanRepository {
  final ApiService _api = ApiService();

  Future<bool> createLahan(Map<String, dynamic> data) async {
    try {
      await _api.post('/lahan', data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getLahanList() async {
    try {
      final response = await _api.get('/lahan');
      return (response is Map && response.containsKey('data')) ? response['data'] : [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getLahanDetail(String id) async {
    try {
      return await _api.get('/lahan/$id');
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateLahan(String id, Map<String, dynamic> data) async {
    try {
      await _api.patch('/lahan/$id', data);
      return true;
    } catch (e) {
      return false;
    }
  }
}