import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ble_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/log_provider.dart';
import '../widgets/connection_status_widget.dart';
import '../widgets/log_widget.dart';
import '../widgets/open_gate_button.dart';
import 'settings_screen.dart';

/// Main screen of the BLE Gate Controller app
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Handle app lifecycle for foreground-only BLE operations
    final bleProvider = context.read<BleProvider>();
    final logProvider = context.read<LogProvider>();
    
    switch (state) {
      case AppLifecycleState.resumed:
        logProvider.addInfo('App resumed');
        break;
      case AppLifecycleState.paused:
        logProvider.addInfo('App paused');
        break;
      case AppLifecycleState.detached:
        logProvider.addInfo('App detached');
        // Disconnect when app is closed
        bleProvider.disconnect();
        break;
      default:
        break;
    }
  }

  Future<void> _initializeApp() async {
    final bleProvider = context.read<BleProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final logProvider = context.read<LogProvider>();

    // Initialize log
    logProvider.initializeWithStartupLog();

    try {
      // Initialize settings
      await settingsProvider.initialize();
      logProvider.addSuccess('Settings loaded');

      // Initialize BLE
      await bleProvider.initialize();
      logProvider.addSuccess('BLE service initialized');

      // Check permissions
      final hasPermissions = await bleProvider.checkAndRequestPermissions();
      if (hasPermissions) {
        logProvider.addSuccess('BLE permissions granted');
      } else {
        logProvider.addWarning('BLE permissions not granted');
        _showPermissionDialog();
      }
    } catch (e) {
      logProvider.addError('Initialization failed: $e');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'This app requires Bluetooth and Location permissions to scan for and connect to the gate controller device.\n\n'
          'Please grant the required permissions to use the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final bleProvider = context.read<BleProvider>();
              final logProvider = context.read<LogProvider>();
              
              final granted = await bleProvider.checkAndRequestPermissions();
              if (granted) {
                logProvider.addSuccess('Permissions granted');
              } else {
                logProvider.addError('Permissions denied');
                // Check if permanently denied
                final permanentlyDenied = await bleProvider.arePermissionsPermanentlyDenied();
                if (permanentlyDenied) {
                  _showOpenSettingsDialog();
                }
              }
            },
            child: const Text('Grant Permissions'),
          ),
        ],
      ),
    );
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Settings'),
        content: const Text(
          'Permissions have been permanently denied. Please open app settings and manually grant Bluetooth and Location permissions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final bleProvider = context.read<BleProvider>();
              await bleProvider.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            // Hidden tap sequence for settings access
            _navigateToSettings();
          },
          child: const Text(
            'BLE Gate Controller',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 2,
        actions: [
          // Settings button in corner for easy access
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _navigateToSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Connection Status
              const ConnectionStatusWidget(),
              
              const SizedBox(height: 24),
              
              // Open Gate Button
              const OpenGateButton(),
              
              const SizedBox(height: 24),
              
              // Error Display
              Consumer<BleProvider>(
                builder: (context, bleProvider, child) {
                  if (bleProvider.error != null) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              bleProvider.error!,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              
              // Log Widget
              const Expanded(
                child: LogWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}