// lib/data/services/legal_service.dart
import 'package:dio/dio.dart';
import '../../core/utils/logger.dart';

class LegalService {
  final Dio _dio;

  LegalService(this._dio);

  Future<List<dynamic>> getTerms() async {
    try {
      final response = await _dio.get('/equb/terms');
      final data = response.data['data'];
      if (data is List) return data;
      return [];
    } catch (e) {
      AppLogger.error('API Error in getTerms', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTermById(String id) async {
    try {
      final response = await _dio.get('/equb/terms/$id');
      return response.data['data'] ?? response.data;
    } catch (e) {
      AppLogger.error('API Error in getTermById', e);
      rethrow;
    }
  }
}
