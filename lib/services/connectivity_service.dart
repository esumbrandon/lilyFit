import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

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

  Future<void> initialize() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isOnline = _hasConnection(result);

      debugPrint(
        'ConnectivityService initialized: ${_isOnline ? "online" : "offline"}',
      );

      _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
        List<ConnectivityResult> result,
      ) {
        final wasOnline = _isOnline;
        _isOnline = _hasConnection(result);

        if (wasOnline != _isOnline) {
          _connectivityController.add(_isOnline);
          debugPrint(
            'Connectivity changed: ${wasOnline ? "online" : "offline"} -> ${_isOnline ? "online" : "offline"}',
          );
        }
      });
    } catch (e) {
      debugPrint('ConnectivityService initialization error: $e');
      _isOnline = true;
    }
  }

  bool _hasConnection(List<ConnectivityResult> result) {
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}
