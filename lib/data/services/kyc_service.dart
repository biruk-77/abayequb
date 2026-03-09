// lib/data/services/kyc_service.dart
import 'package:dio/dio.dart';
import '../../core/utils/logger.dart';

class KYCService {
  final Dio _dio;

  KYCService(this._dio);

  Future<Map<String, dynamic>> submitKYC({
    required String documentType,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'documentType': documentType,
        'document': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split(RegExp(r'[/\\]')).last,
        ),
      });

      final response = await _dio.post('/kyc', data: formData);
      return response.data;
    } catch (e) {
      AppLogger.error('KYC Submission Error', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateKYC({
    required String kycId,
    required String documentType,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'documentType': documentType,
        'document': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split(RegExp(r'[/\\]')).last,
        ),
      });

      final response = await _dio.put('/kyc', data: formData);
      return response.data;
    } catch (e) {
      AppLogger.error('KYC Update Error', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMyKYC() async {
    try {
      final response = await _dio.get('/kyc/me');
      return response.data;
    } catch (e) {
      AppLogger.error('Fetch My KYC Error', e);
      rethrow;
    }
  }
}
