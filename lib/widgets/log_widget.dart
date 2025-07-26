import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/log_provider.dart';
import '../models/log_entry.dart';
import '../utils/constants.dart';

/// Widget that displays the scrollable BLE interaction log
class LogWidget extends StatelessWidget {
  const LogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LogProvider>(
      builder: (context, logProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.list_alt,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Interaction Log',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const Spacer(),
                    if (logProvider.hasEntries)
                      Text(
                        '${logProvider.entryCount} entries',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Clear log button
                    if (logProvider.hasEntries)
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey[600],
                          size: 18,
                        ),
                        onPressed: () => _showClearLogDialog(context, logProvider),
                        tooltip: 'Clear log',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Log entries
              Expanded(
                child: logProvider.hasEntries
                    ? ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: logProvider.logEntries.length,
                        reverse: true, // Show newest entries at the bottom
                        itemBuilder: (context, index) {
                          final reversedIndex = logProvider.logEntries.length - 1 - index;
                          final entry = logProvider.logEntries[reversedIndex];
                          return _buildLogEntry(entry);
                        },
                      )
                    : _buildEmptyState(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogEntry(LogEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getEntryBackgroundColor(entry.type),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _getEntryBorderColor(entry.type),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type icon
          Icon(
            _getEntryIcon(entry.type),
            size: 16,
            color: _getEntryIconColor(entry.type),
          ),
          const SizedBox(width: 8),
          
          // Message and timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.formattedTime,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No log entries yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "Open Gate" to start interacting with the device',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getEntryBackgroundColor(LogEntryType type) {
    switch (type) {
      case LogEntryType.info:
        return Colors.blue[50]!;
      case LogEntryType.success:
        return Colors.green[50]!;
      case LogEntryType.warning:
        return Colors.orange[50]!;
      case LogEntryType.error:
        return Colors.red[50]!;
    }
  }

  Color _getEntryBorderColor(LogEntryType type) {
    switch (type) {
      case LogEntryType.info:
        return Colors.blue[200]!;
      case LogEntryType.success:
        return Colors.green[200]!;
      case LogEntryType.warning:
        return Colors.orange[200]!;
      case LogEntryType.error:
        return Colors.red[200]!;
    }
  }

  Color _getEntryIconColor(LogEntryType type) {
    switch (type) {
      case LogEntryType.info:
        return Colors.blue[600]!;
      case LogEntryType.success:
        return Colors.green[600]!;
      case LogEntryType.warning:
        return Colors.orange[600]!;
      case LogEntryType.error:
        return Colors.red[600]!;
    }
  }

  IconData _getEntryIcon(LogEntryType type) {
    switch (type) {
      case LogEntryType.info:
        return Icons.info_outline;
      case LogEntryType.success:
        return Icons.check_circle_outline;
      case LogEntryType.warning:
        return Icons.warning_amber_outlined;
      case LogEntryType.error:
        return Icons.error_outline;
    }
  }

  void _showClearLogDialog(BuildContext context, LogProvider logProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Log'),
        content: const Text('Are you sure you want to clear all log entries? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              logProvider.clearLog();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}