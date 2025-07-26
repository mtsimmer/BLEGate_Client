import '../utils/constants.dart';

/// A log entry for the BLE interaction log
class LogEntry {
  final DateTime timestamp;
  final String message;
  final LogEntryType type;

  const LogEntry({
    required this.timestamp,
    required this.message,
    required this.type,
  });

  /// Create an info log entry
  factory LogEntry.info(String message) {
    return LogEntry(
      timestamp: DateTime.now(),
      message: message,
      type: LogEntryType.info,
    );
  }

  /// Create a success log entry
  factory LogEntry.success(String message) {
    return LogEntry(
      timestamp: DateTime.now(),
      message: message,
      type: LogEntryType.success,
    );
  }

  /// Create a warning log entry
  factory LogEntry.warning(String message) {
    return LogEntry(
      timestamp: DateTime.now(),
      message: message,
      type: LogEntryType.warning,
    );
  }

  /// Create an error log entry
  factory LogEntry.error(String message) {
    return LogEntry(
      timestamp: DateTime.now(),
      message: message,
      type: LogEntryType.error,
    );
  }

  /// Get formatted timestamp string
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}:'
           '${timestamp.second.toString().padLeft(2, '0')}';
  }

  /// Get display message with timestamp
  String get displayMessage {
    return '[$formattedTime] $message';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogEntry &&
          runtimeType == other.runtimeType &&
          timestamp == other.timestamp &&
          message == other.message &&
          type == other.type;

  @override
  int get hashCode => timestamp.hashCode ^ message.hashCode ^ type.hashCode;

  @override
  String toString() {
    return 'LogEntry{timestamp: $timestamp, message: $message, type: $type}';
  }
}