// lib/data/repositories/ideas_repository.dart
import '../services/ideas_service.dart';
import '../../core/utils/logger.dart';

class IdeasRepository {
  final IdeasService _service;

  IdeasRepository(this._service);

  Future<List<dynamic>> getIdeas() async {
    try {
      AppLogger.info('fetching community ideas...');
      return await _service.getIdeas();
    } catch (e) {
      AppLogger.error('failed to get ideas', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getIdeaById(String id) async {
    try {
      AppLogger.info('fetching idea detail for: $id');
      return await _service.getIdeaById(id);
    } catch (e) {
      AppLogger.error('failed to get idea by id: $id', e);
      rethrow;
    }
  }

  Future<void> createIdea({
    required String title,
    required String description,
    required String category,
    String? filePath,
  }) async {
    try {
      AppLogger.info('submitting new idea: $title');
      await _service.createIdea(
        title: title,
        description: description,
        category: category,
        filePath: filePath,
      );
      AppLogger.success('idea submitted successfully');
    } catch (e) {
      AppLogger.error('failed to submit idea', e);
      rethrow;
    }
  }

  Future<void> deleteIdea(String id) async {
    try {
      AppLogger.info('deleting idea: $id');
      await _service.deleteIdea(id);
      AppLogger.success('idea deleted successfully');
    } catch (e) {
      AppLogger.error('failed to delete idea', e);
      rethrow;
    }
  }
}
