// lib/presentation/providers/legal_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/legal_repository.dart';

class LegalProvider extends ChangeNotifier {
  final LegalRepository _repository;
  List<dynamic> _terms = [];
  bool _isLoading = false;
  bool _hasAcceptedGlobalTerms = false;

  LegalProvider(this._repository) {
    _loadAcceptanceStatus();
  }

  List<dynamic> get terms => _terms;
  bool get isLoading => _isLoading;
  bool get hasAcceptedGlobalTerms => _hasAcceptedGlobalTerms;

  Future<void> _loadAcceptanceStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _hasAcceptedGlobalTerms = prefs.getBool('accepted_global_terms') ?? false;
    notifyListeners();
  }

  Future<void> acceptGlobalTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('accepted_global_terms', true);
    _hasAcceptedGlobalTerms = true;
    notifyListeners();
  }

  Future<void> fetchTerms() async {
    _isLoading = true;
    notifyListeners();

    try {
      _terms = await _repository.getTerms();
      AppLogger.success('LegalProvider: Fetched ${_terms.length} terms');
    } catch (e) {
      AppLogger.error('LegalProvider: Error fetching terms', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic>? get activeTerms {
    try {
      return _terms.firstWhere((t) => t['isActive'] == true);
    } catch (_) {
      return _terms.isNotEmpty ? _terms.first : null;
    }
  }
}
