import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';

/// Provider for managing app settings
class SettingsProvider with ChangeNotifier {
  AppSettings _settings = AppSettings.defaults();
  bool _isLoading = false;
  String? _error;

  // Getters
  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize the provider by loading settings
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _settings = await SettingsService.loadSettings();
      _clearError();
    } catch (e) {
      _setError('Failed to load settings: $e');
      // Use defaults if loading fails
      _settings = AppSettings.defaults();
    } finally {
      _setLoading(false);
    }
  }

  /// Update settings and save them
  Future<void> updateSettings(AppSettings newSettings) async {
    _setLoading(true);
    try {
      await SettingsService.saveSettings(newSettings);
      _settings = newSettings;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to save settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update individual setting fields
  Future<void> updateDeviceName(String deviceName) async {
    final newSettings = _settings.copyWith(deviceName: deviceName);
    await updateSettings(newSettings);
  }

  Future<void> updateSecret(String secret) async {
    final newSettings = _settings.copyWith(secret: secret);
    await updateSettings(newSettings);
  }

  Future<void> updateServiceUuid(String serviceUuid) async {
    final newSettings = _settings.copyWith(serviceUuid: serviceUuid);
    await updateSettings(newSettings);
  }

  Future<void> updateWriteCharacteristicUuid(String writeUuid) async {
    final newSettings = _settings.copyWith(writeCharacteristicUuid: writeUuid);
    await updateSettings(newSettings);
  }

  Future<void> updateNotifyCharacteristicUuid(String notifyUuid) async {
    final newSettings = _settings.copyWith(notifyCharacteristicUuid: notifyUuid);
    await updateSettings(newSettings);
  }

  /// Reset settings to defaults
  Future<void> resetToDefaults() async {
    _setLoading(true);
    try {
      _settings = await SettingsService.resetToDefaults();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to reset settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Clear all settings
  Future<void> clearSettings() async {
    _setLoading(true);
    try {
      await SettingsService.clearSettings();
      _settings = AppSettings.defaults();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Check if secure storage is available
  Future<bool> isSecureStorageAvailable() async {
    return await SettingsService.isSecureStorageAvailable();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}