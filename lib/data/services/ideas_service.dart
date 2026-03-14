// lib/data/services/ideas_service.dart
import 'package:dio/dio.dart';
import '../../core/utils/logger.dart';

class IdeasService {
  final Dio _dio;

  IdeasService(this._dio);

  Future<List<dynamic>> getIdeas() async {
    try {
      final response = await _dio.get('/equb/ideas');
      final data = response.data['data'];
      if (data is List) return data;
      return [];
    } catch (e) {
      AppLogger.error('API Error in getIdeas', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getIdeaById(String id) async {
    try {
      final response = await _dio.get('/equb/ideas/$id');
      return response.data['data'] ?? response.data;
    } catch (e) {
      AppLogger.error('API Error in getIdeaById', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createIdea({
    required String title,
    required String description,
    required String category,
    String? filePath,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'title': title,
        'description': description,
        'category': category,
      };

      if (filePath != null) {
        data['file'] = await MultipartFile.fromFile(
          filePath,
          filename: filePath.split(RegExp(r'[/\\]')).last,
        );
      }

      final formData = FormData.fromMap(data);
      final response = await _dio.post('/equb/ideas', data: formData);
      return response.data;
    } catch (e) {
      AppLogger.error('API Error in createIdea', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateIdea(
    String id, {
    String? title,
    String? description,
    String? category,
    String? filePath,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (category != null) data['category'] = category;
      
      if (filePath != null) {
        data['file'] = await MultipartFile.fromFile(
          filePath,
          filename: filePath.split(RegExp(r'[/\\]')).last,
        );
      }

      final formData = FormData.fromMap(data);
      final response = await _dio.put('/equb/ideas/$id', data: formData);
      return response.data;
    } catch (e) {
      AppLogger.error('API Error in updateIdea', e);
      rethrow;
    }
  }

  Future<void> deleteIdea(String id) async {
    try {
      await _dio.delete('/equb/ideas/$id');
    } catch (e) {
      AppLogger.error('API Error in deleteIdea', e);
      rethrow;
    }
  }
}
