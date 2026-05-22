import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service to handle connectivity detection and offline/online state
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  final _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _isOnline = _hasConnection(result);

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      final wasOnline = _isOnline;
      _isOnline = _hasConnection(result);

      // Notify listeners of connectivity change
      _connectivityController.add(_isOnline);

      debugPrint(
        'Connectivity changed: ${wasOnline ? "online" : "offline"} -> ${_isOnline ? "online" : "offline"}',
      );
    });
  }

  /// Check if device has network connection
  bool _hasConnection(List<ConnectivityResult> result) {
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}
