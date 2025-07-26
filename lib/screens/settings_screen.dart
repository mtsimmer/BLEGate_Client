import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/log_provider.dart';
import '../models/app_settings.dart';

/// Settings screen for configuring BLE parameters
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _deviceNameController;
  late TextEditingController _secretController;
  late TextEditingController _serviceUuidController;
  late TextEditingController _writeUuidController;
  late TextEditingController _notifyUuidController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>().settings;
    
    _deviceNameController = TextEditingController(text: settings.deviceName);
    _secretController = TextEditingController(text: settings.secret);
    _serviceUuidController = TextEditingController(text: settings.serviceUuid);
    _writeUuidController = TextEditingController(text: settings.writeCharacteristicUuid);
    _notifyUuidController = TextEditingController(text: settings.notifyCharacteristicUuid);
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    _secretController.dispose();
    _serviceUuidController.dispose();
    _writeUuidController.dispose();
    _notifyUuidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Reset to defaults button
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _showResetDialog,
            tooltip: 'Reset to defaults',
          ),
        ],
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Device Configuration Section
                _buildSectionCard(
                  title: 'Device Configuration',
                  icon: Icons.bluetooth,
                  children: [
                    _buildTextFormField(
                      controller: _deviceNameController,
                      label: 'Device Name',
                      hint: 'Name of the BLE device to connect to',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Device name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _secretController,
                      label: 'BLE Secret',
                      hint: 'Secret key for authentication',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Secret is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // BLE UUIDs Section
                _buildSectionCard(
                  title: 'BLE UUIDs',
                  icon: Icons.settings_bluetooth,
                  children: [
                    _buildTextFormField(
                      controller: _serviceUuidController,
                      label: 'Service UUID',
                      hint: 'BLE service UUID',
                      validator: _validateUuid,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _writeUuidController,
                      label: 'Write Characteristic UUID',
                      hint: 'UUID for writing the secret',
                      validator: _validateUuid,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _notifyUuidController,
                      label: 'Notify Characteristic UUID',
                      hint: 'UUID for receiving notifications',
                      validator: _validateUuid,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: settingsProvider.isLoading ? null : _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: settingsProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Settings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Error Display
                if (settingsProvider.error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
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
                            settingsProvider.error!,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Storage Info
                _buildInfoCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(icon, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[600]!),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Storage Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Settings are stored securely on your device using encrypted storage. '
            'If secure storage is unavailable, default values will be used.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  String? _validateUuid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'UUID is required';
    }
    
    // Basic UUID format validation
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    
    if (!uuidRegex.hasMatch(value.trim())) {
      return 'Invalid UUID format';
    }
    
    return null;
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final settingsProvider = context.read<SettingsProvider>();
    final logProvider = context.read<LogProvider>();

    final newSettings = AppSettings(
      deviceName: _deviceNameController.text.trim(),
      secret: _secretController.text.trim(),
      serviceUuid: _serviceUuidController.text.trim(),
      writeCharacteristicUuid: _writeUuidController.text.trim(),
      notifyCharacteristicUuid: _notifyUuidController.text.trim(),
    );

    try {
      await settingsProvider.updateSettings(newSettings);
      logProvider.logSettingsChange('Settings updated successfully');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      logProvider.logErrorWithContext('Failed to save settings', e.toString());
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _resetToDefaults();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetToDefaults() async {
    final settingsProvider = context.read<SettingsProvider>();
    final logProvider = context.read<LogProvider>();

    try {
      await settingsProvider.resetToDefaults();
      
      // Update controllers with default values
      final defaults = AppSettings.defaults();
      _deviceNameController.text = defaults.deviceName;
      _secretController.text = defaults.secret;
      _serviceUuidController.text = defaults.serviceUuid;
      _writeUuidController.text = defaults.writeCharacteristicUuid;
      _notifyUuidController.text = defaults.notifyCharacteristicUuid;
      
      logProvider.logSettingsChange('Settings reset to defaults');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings reset to defaults'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      logProvider.logErrorWithContext('Failed to reset settings', e.toString());
    }
  }
}