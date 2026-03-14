// lib/data/repositories/legal_repository.dart
import '../services/legal_service.dart';
import '../../core/utils/logger.dart';

class LegalRepository {
  final LegalService _service;

  LegalRepository(this._service);

  Future<List<dynamic>> getTerms() async {
    try {
      AppLogger.info('fetching all legal terms...');
      return await _service.getTerms();
    } catch (e) {
      AppLogger.error('failed to get terms', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTermById(String id) async {
    try {
      AppLogger.info('fetching term detail for: $id');
      return await _service.getTermById(id);
    } catch (e) {
      AppLogger.error('failed to get term by id: $id', e);
      rethrow;
    }
  }
}
