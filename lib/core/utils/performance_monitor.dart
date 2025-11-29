import 'package:flutter/foundation.dart';

/// Performance monitoring utility
/// 
/// Tracks and logs performance metrics for debugging and optimization.
class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, List<Duration>> _durations = {};

  /// Start timing an operation
  static void startTiming(String operationId) {
    _startTimes[operationId] = DateTime.now();
  }

  /// End timing an operation and log the duration
  static Duration endTiming(String operationId, {bool log = true}) {
    final startTime = _startTimes.remove(operationId);
    if (startTime == null) {
      debugPrint('WARNING: No start time found for operation: $operationId');
      return Duration.zero;
    }

    final duration = DateTime.now().difference(startTime);
    
    // Store duration for analytics
    _durations.putIfAbsent(operationId, () => []).add(duration);
    
    if (log) {
      debugPrint('PERFORMANCE: $operationId took ${duration.inMilliseconds}ms');
    }
    
    return duration;
  }

  /// Get average duration for an operation
  static Duration? getAverageDuration(String operationId) {
    final durations = _durations[operationId];
    if (durations == null || durations.isEmpty) return null;
    
    final totalMs = durations.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );
    
    return Duration(milliseconds: totalMs ~/ durations.length);
  }

  /// Get all performance metrics
  static Map<String, Duration> getAllAverages() {
    final averages = <String, Duration>{};
    
    _durations.forEach((operationId, durations) {
      final avg = getAverageDuration(operationId);
      if (avg != null) {
        averages[operationId] = avg;
      }
    });
    
    return averages;
  }

  /// Clear all performance data
  static void clear() {
    _startTimes.clear();
    _durations.clear();
  }
}

