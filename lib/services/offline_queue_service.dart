import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Types of operations that can be queued
enum OfflineOperationType {
  addMeal,
  removeMeal,
  addWater,
  addWeight,
  updateProfile,
}

/// Represents a pending operation to sync when back online
class PendingOperation {
  final String id;
  final OfflineOperationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  PendingOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
  };

  factory PendingOperation.fromJson(Map<String, dynamic> json) {
    return PendingOperation(
      id: json['id'],
      type: OfflineOperationType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// Service to manage offline operations queue
class OfflineQueueService {
  static final OfflineQueueService _instance = OfflineQueueService._internal();
  factory OfflineQueueService() => _instance;
  OfflineQueueService._internal();

  static const String _queueKey = 'offline_operations_queue';
  List<PendingOperation> _queue = [];
  bool _isSyncing = false;

  /// Load queue from storage
  Future<void> loadQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);
      if (queueJson != null) {
        final List<dynamic> list = jsonDecode(queueJson);
        _queue = list.map((e) => PendingOperation.fromJson(e)).toList();
        debugPrint('Loaded ${_queue.length} pending operations from queue');
      }
    } catch (e) {
      debugPrint('Error loading offline queue: $e');
      _queue = [];
    }
  }

  /// Save queue to storage
  Future<void> _saveQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(_queue.map((op) => op.toJson()).toList());
      await prefs.setString(_queueKey, json);
    } catch (e) {
      debugPrint('Error saving offline queue: $e');
    }
  }

  /// Add operation to queue
  Future<void> addOperation(
    OfflineOperationType type,
    Map<String, dynamic> data,
  ) async {
    final operation = PendingOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      data: data,
      timestamp: DateTime.now(),
    );
    _queue.add(operation);
    await _saveQueue();
    debugPrint('Added operation to queue: ${type.name}');
  }

  /// Get number of pending operations
  int get pendingCount => _queue.length;

  /// Check if there are pending operations
  bool get hasPendingOperations => _queue.isNotEmpty;

  /// Remove operation from queue
  Future<void> _removeOperation(String id) async {
    _queue.removeWhere((op) => op.id == id);
    await _saveQueue();
  }

  /// Clear all operations
  Future<void> clearQueue() async {
    _queue.clear();
    await _saveQueue();
  }

  /// Get all pending operations
  List<PendingOperation> get pendingOperations => List.unmodifiable(_queue);

  /// Sync pending operations
  /// Returns true if all operations synced successfully
  Future<bool> syncPendingOperations(
    Future<void> Function(PendingOperation) syncFunction,
  ) async {
    if (_isSyncing || _queue.isEmpty) {
      return true;
    }

    _isSyncing = true;
    debugPrint('Syncing ${_queue.length} pending operations...');

    try {
      final operationsToSync = List<PendingOperation>.from(_queue);

      for (var operation in operationsToSync) {
        try {
          // Add timeout to prevent operations from hanging indefinitely
          await syncFunction(operation).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Operation timed out after 30 seconds');
            },
          );
          await _removeOperation(operation.id);
          debugPrint('Successfully synced operation: ${operation.type.name}');
        } catch (e) {
          debugPrint('Failed to sync operation ${operation.type.name}: $e');
          // Keep operation in queue for retry
          return false;
        }
      }

      debugPrint('All pending operations synced successfully');
      return true;
    } finally {
      _isSyncing = false;
    }
  }
}
