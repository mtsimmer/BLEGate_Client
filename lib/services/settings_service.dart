import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/app_settings.dart';
import '../utils/constants.dart';

/// Service for managing app settings with secure storage
class SettingsService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Load settings from secure storage
  static Future<AppSettings> loadSettings() async {
    try {
      final Map<String, String> settingsMap = {};
      
      // Load all settings from secure storage
      final deviceName = await _storage.read(key: BleConstants.deviceNameKey);
      final secret = await _storage.read(key: BleConstants.secretKey);
      final serviceUuid = await _storage.read(key: BleConstants.serviceUuidKey);
      final writeUuid = await _storage.read(key: BleConstants.writeUuidKey);
      final notifyUuid = await _storage.read(key: BleConstants.notifyUuidKey);

      // Only add non-null values to the map
      if (deviceName != null) settingsMap[BleConstants.deviceNameKey] = deviceName;
      if (secret != null) settingsMap[BleConstants.secretKey] = secret;
      if (serviceUuid != null) settingsMap[BleConstants.serviceUuidKey] = serviceUuid;
      if (writeUuid != null) settingsMap[BleConstants.writeUuidKey] = writeUuid;
      if (notifyUuid != null) settingsMap[BleConstants.notifyUuidKey] = notifyUuid;

      return AppSettings.fromMap(settingsMap);
    } catch (e) {
      // If secure storage fails, return default settings
      return AppSettings.defaults();
    }
  }

  /// Save settings to secure storage
  static Future<void> saveSettings(AppSettings settings) async {
    try {
      final settingsMap = settings.toMap();
      
      // Save each setting individually
      await Future.wait([
        _storage.write(key: BleConstants.deviceNameKey, value: settingsMap[BleConstants.deviceNameKey]!),
        _storage.write(key: BleConstants.secretKey, value: settingsMap[BleConstants.secretKey]!),
        _storage.write(key: BleConstants.serviceUuidKey, value: settingsMap[BleConstants.serviceUuidKey]!),
        _storage.write(key: BleConstants.writeUuidKey, value: settingsMap[BleConstants.writeUuidKey]!),
        _storage.write(key: BleConstants.notifyUuidKey, value: settingsMap[BleConstants.notifyUuidKey]!),
      ]);
    } catch (e) {
      // If secure storage fails, we'll just use the current settings in memory
      throw Exception('Failed to save settings: $e');
    }
  }

  /// Clear all settings from secure storage
  static Future<void> clearSettings() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to clear settings: $e');
    }
  }

  /// Reset settings to defaults and save them
  static Future<AppSettings> resetToDefaults() async {
    final defaultSettings = AppSettings.defaults();
    await saveSettings(defaultSettings);
    return defaultSettings;
  }

  /// Check if secure storage is available
  static Future<bool> isSecureStorageAvailable() async {
    try {
      await _storage.containsKey(key: 'test');
      return true;
    } catch (e) {
      return false;
    }
  }
}