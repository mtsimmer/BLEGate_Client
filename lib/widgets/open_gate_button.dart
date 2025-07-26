import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ble_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/log_provider.dart';
import '../utils/constants.dart';

/// Large button widget for opening the gate
class OpenGateButton extends StatelessWidget {
  const OpenGateButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<BleProvider, SettingsProvider, LogProvider>(
      builder: (context, bleProvider, settingsProvider, logProvider, child) {
        final isEnabled = bleProvider.hasPermissions && 
                         !settingsProvider.isLoading &&
                         !bleProvider.isConnecting;
        
        return Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isEnabled ? () => _openGate(context, bleProvider, settingsProvider, logProvider) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled ? Colors.green[600] : Colors.grey[400],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (bleProvider.isConnecting) ...[
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getButtonText(bleProvider),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else ...[
                  Icon(
                    _getButtonIcon(bleProvider),
                    size: 36,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getButtonText(bleProvider),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                
                // Subtitle with additional info
                if (!bleProvider.hasPermissions) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Permissions Required',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ] else if (bleProvider.error != null) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Check Error Above',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _getButtonText(BleProvider bleProvider) {
    if (!bleProvider.hasPermissions) {
      return 'Grant Permissions';
    }
    
    switch (bleProvider.connectionState) {
      case BleConnectionState.disconnected:
        return 'Open Gate';
      case BleConnectionState.scanning:
        return 'Scanning...';
      case BleConnectionState.connecting:
        return 'Connecting...';
      case BleConnectionState.connected:
        return 'Open Gate';
      case BleConnectionState.authenticating:
        return 'Authenticating...';
      case BleConnectionState.authenticated:
        return 'Gate Ready';
      case BleConnectionState.error:
        return 'Retry';
    }
  }

  IconData _getButtonIcon(BleProvider bleProvider) {
    if (!bleProvider.hasPermissions) {
      return Icons.security;
    }
    
    switch (bleProvider.connectionState) {
      case BleConnectionState.disconnected:
        return Icons.lock_open;
      case BleConnectionState.connected:
      case BleConnectionState.authenticated:
        return Icons.lock_open;
      case BleConnectionState.error:
        return Icons.refresh;
      default:
        return Icons.bluetooth_searching;
    }
  }

  Future<void> _openGate(
    BuildContext context,
    BleProvider bleProvider,
    SettingsProvider settingsProvider,
    LogProvider logProvider,
  ) async {
    // Check permissions first
    if (!bleProvider.hasPermissions) {
      logProvider.addWarning('Requesting permissions...');
      final granted = await bleProvider.checkAndRequestPermissions();
      if (!granted) {
        logProvider.addError('Permissions denied');
        return;
      }
    }

    // Log the attempt
    logProvider.addInfo('Opening gate...');
    
    try {
      // Attempt to open the gate
      final success = await bleProvider.openGate(settingsProvider.settings);
      
      if (success) {
        logProvider.addSuccess('Gate opening command sent');
        
        // Listen for notifications
        bleProvider.notificationStream.listen(
          (notification) {
            logProvider.logNotification(notification);
          },
          onError: (error) {
            logProvider.addError('Notification error: $error');
          },
        );
      } else {
        logProvider.addError('Failed to open gate');
        _showErrorDialog(context, 'Failed to open gate. Please check that the device is nearby and powered on.');
      }
    } catch (e) {
      logProvider.addError('Gate operation failed: $e');
      _showErrorDialog(context, 'An error occurred: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}