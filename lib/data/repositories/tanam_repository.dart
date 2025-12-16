import 'package:agros/core/services/api_service.dart';

class TanamRepository {
  final ApiService _api = ApiService();

  Future<bool> createTanam(Map<String, dynamic> data) async {
    try {
      await _api.post('/tanam', data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getTanamList() async {
    try {
      final response = await _api.get('/tanam');
      return (response is Map && response.containsKey('data')) ? response['data'] : [];
    } catch (e) {
      return [];
    }
  }
  
  Future<List<dynamic>> getTanamOngoing() async {
    try {
      final response = await _api.get('/tanam/ongoing');
      return (response is Map && response.containsKey('data')) ? response['data'] : [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateTanam(String id, Map<String, dynamic> data) async {
    try {
      await _api.patch('/tanam/$id', data);
      return true;
    } catch (e) {
      return false;
    }
  }
}