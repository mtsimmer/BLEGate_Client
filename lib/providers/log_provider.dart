import 'package:flutter/foundation.dart';
import '../models/log_entry.dart';
import '../utils/constants.dart';

/// Provider for managing the BLE interaction log
class LogProvider with ChangeNotifier {
  final List<LogEntry> _logEntries = [];
  final int _maxLogEntries = 100; // Limit log size to prevent memory issues
  
  // Getters
  List<LogEntry> get logEntries => List.unmodifiable(_logEntries);
  bool get hasEntries => _logEntries.isNotEmpty;
  int get entryCount => _logEntries.length;

  /// Add an info log entry
  void addInfo(String message) {
    _addEntry(LogEntry.info(message));
  }

  /// Add a success log entry
  void addSuccess(String message) {
    _addEntry(LogEntry.success(message));
  }

  /// Add a warning log entry
  void addWarning(String message) {
    _addEntry(LogEntry.warning(message));
  }

  /// Add an error log entry
  void addError(String message) {
    _addEntry(LogEntry.error(message));
  }

  /// Add a custom log entry
  void addEntry(LogEntry entry) {
    _addEntry(entry);
  }

  /// Clear all log entries
  void clearLog() {
    _logEntries.clear();
    notifyListeners();
  }

  /// Get log entries of a specific type
  List<LogEntry> getEntriesByType(LogEntryType type) {
    return _logEntries.where((entry) => entry.type == type).toList();
  }

  /// Get recent log entries (last n entries)
  List<LogEntry> getRecentEntries(int count) {
    if (_logEntries.length <= count) {
      return List.from(_logEntries);
    }
    return _logEntries.sublist(_logEntries.length - count);
  }

  /// Get log entries from a specific time range
  List<LogEntry> getEntriesInTimeRange(DateTime start, DateTime end) {
    return _logEntries.where((entry) {
      return entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end);
    }).toList();
  }

  /// Get formatted log text for export/sharing
  String getFormattedLogText() {
    if (_logEntries.isEmpty) {
      return 'No log entries';
    }

    final buffer = StringBuffer();
    buffer.writeln('BLE Gate Controller Log');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('Total entries: ${_logEntries.length}');
    buffer.writeln('${'=' * 40}');
    
    for (final entry in _logEntries) {
      buffer.writeln('${entry.displayMessage} [${entry.type.name.toUpperCase()}]');
    }
    
    return buffer.toString();
  }

  /// Add entry with automatic cleanup
  void _addEntry(LogEntry entry) {
    _logEntries.add(entry);
    
    // Remove old entries if we exceed the maximum
    if (_logEntries.length > _maxLogEntries) {
      _logEntries.removeAt(0);
    }
    
    notifyListeners();
  }

  /// Initialize with app startup log
  void initializeWithStartupLog() {
    addInfo('App started');
    addInfo('BLE Gate Controller initialized');
  }

  /// Log BLE connection events
  void logConnectionEvent(String event) {
    addInfo('Connection: $event');
  }

  /// Log BLE scanning events
  void logScanEvent(String event) {
    addInfo('Scan: $event');
  }

  /// Log authentication events
  void logAuthEvent(String event) {
    addInfo('Auth: $event');
  }

  /// Log notification received
  void logNotification(String notification) {
    addSuccess('Received: $notification');
  }

  /// Log error with context
  void logErrorWithContext(String error, String context) {
    addError('$context: $error');
  }

  /// Log permission events
  void logPermissionEvent(String event) {
    addWarning('Permission: $event');
  }

  /// Log settings changes
  void logSettingsChange(String change) {
    addInfo('Settings: $change');
  }
}