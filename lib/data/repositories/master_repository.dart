import 'package:agros/core/services/api_service.dart';

class MasterRepository {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getKomoditas() async => _getList('/master/komoditas');
  Future<List<dynamic>> getVarietas() async => _getList('/master/varietas');
  Future<List<dynamic>> getKelompokTani() async => _getList('/kelompok-tani');

  Future<List<dynamic>> _getList(String endpoint) async {
    try {
      final response = await _api.get(endpoint);
      if (response is Map && response.containsKey('data')) {
        return response['data'] ?? [];
      } else if (response is List) {
        return response;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}