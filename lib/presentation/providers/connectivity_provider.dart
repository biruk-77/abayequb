import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../../core/utils/logger.dart';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  bool _isOnline = true;
  bool _hasBeenOffline = false;

  bool get isOnline => _isOnline;
  bool get hasBeenOffline => _hasBeenOffline;

  ConnectivityProvider() {
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      AppLogger.error('Failed to check connectivity', e);
      _isOnline = false;
      notifyListeners();
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    
    // Consider connected if any connection type is available (except none)
    _isOnline = results.any((result) => result != ConnectivityResult.none);
    
    if (wasOnline != _isOnline) {
      if (_isOnline) {
        AppLogger.success('🌐 Connection restored');
        if (_hasBeenOffline) {
          // Connection restored after being offline
          _hasBeenOffline = false;
        }
      } else {
        AppLogger.warning('📵 No internet connection');
        _hasBeenOffline = true;
      }
      notifyListeners();
    }
  }

  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    return _isOnline;
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
