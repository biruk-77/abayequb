// lib/presentation/providers/ideas_provider.dart
import 'package:flutter/foundation.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/ideas_repository.dart';

class IdeasProvider extends ChangeNotifier {
  final IdeasRepository _repository;
  List<dynamic> _ideas = [];
  bool _isLoading = false;

  IdeasProvider(this._repository);

  List<dynamic> get ideas => _ideas;
  bool get isLoading => _isLoading;

  Future<void> fetchIdeas() async {
    _isLoading = true;
    notifyListeners();

    try {
      _ideas = await _repository.getIdeas();
      AppLogger.success('IdeasProvider: Fetched ${_ideas.length} ideas');
    } catch (e) {
      AppLogger.error('IdeasProvider: Error fetching ideas', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createIdea({
    required String title,
    required String description,
    required String category,
    String? filePath,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.createIdea(
        title: title,
        description: description,
        category: category,
        filePath: filePath,
      );
      AppLogger.success('IdeasProvider: Idea created successfully');
      await fetchIdeas(); // Refresh the list
    } catch (e) {
      AppLogger.error('IdeasProvider: Error creating idea', e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteIdea(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.deleteIdea(id);
      AppLogger.success('IdeasProvider: Idea deleted successfully');
      await fetchIdeas();
    } catch (e) {
      AppLogger.error('IdeasProvider: Error deleting idea', e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
