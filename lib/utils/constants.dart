/// Constants for the BLE Gate Controller app
class BleConstants {
  // Default BLE Configuration
  static const String defaultDeviceName = 'SecureGateController';
  static const String defaultSecret = 'Fuck0ferGates';
  
  // UUIDs from Arduino code
  static const String serviceUuid = '7d63e895-9dab-46cc-b55d-2a1a71469d3a';
  static const String writeCharacteristicUuid = '69aeed94-cf0d-4822-9e50-7de8e84e2d91';
  static const String notifyCharacteristicUuid = '575acadf-8ee3-43be-be4c-fba91b324e45';
  
  // Connection settings
  static const Duration scanTimeout = Duration(seconds: 10);
  static const Duration connectionTimeout = Duration(seconds: 15);
  
  // Secure storage keys
  static const String deviceNameKey = 'device_name';
  static const String secretKey = 'ble_secret';
  static const String writeUuidKey = 'write_uuid';
  static const String notifyUuidKey = 'notify_uuid';
  static const String serviceUuidKey = 'service_uuid';
}

/// Connection states for the BLE device
enum BleConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  authenticating,
  authenticated,
  error
}

/// Log entry types for the interaction log
enum LogEntryType {
  info,
  success,
  warning,
  error
}