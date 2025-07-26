import '../utils/constants.dart';

/// App settings model for BLE configuration
class AppSettings {
  final String deviceName;
  final String secret;
  final String serviceUuid;
  final String writeCharacteristicUuid;
  final String notifyCharacteristicUuid;

  const AppSettings({
    required this.deviceName,
    required this.secret,
    required this.serviceUuid,
    required this.writeCharacteristicUuid,
    required this.notifyCharacteristicUuid,
  });

  /// Create settings with default values
  factory AppSettings.defaults() {
    return const AppSettings(
      deviceName: BleConstants.defaultDeviceName,
      secret: BleConstants.defaultSecret,
      serviceUuid: BleConstants.serviceUuid,
      writeCharacteristicUuid: BleConstants.writeCharacteristicUuid,
      notifyCharacteristicUuid: BleConstants.notifyCharacteristicUuid,
    );
  }

  /// Create settings from a map (for storage/retrieval)
  factory AppSettings.fromMap(Map<String, String> map) {
    return AppSettings(
      deviceName: map[BleConstants.deviceNameKey] ?? BleConstants.defaultDeviceName,
      secret: map[BleConstants.secretKey] ?? BleConstants.defaultSecret,
      serviceUuid: map[BleConstants.serviceUuidKey] ?? BleConstants.serviceUuid,
      writeCharacteristicUuid: map[BleConstants.writeUuidKey] ?? BleConstants.writeCharacteristicUuid,
      notifyCharacteristicUuid: map[BleConstants.notifyUuidKey] ?? BleConstants.notifyCharacteristicUuid,
    );
  }

  /// Convert settings to a map (for storage)
  Map<String, String> toMap() {
    return {
      BleConstants.deviceNameKey: deviceName,
      BleConstants.secretKey: secret,
      BleConstants.serviceUuidKey: serviceUuid,
      BleConstants.writeUuidKey: writeCharacteristicUuid,
      BleConstants.notifyUuidKey: notifyCharacteristicUuid,
    };
  }

  /// Create a copy with updated values
  AppSettings copyWith({
    String? deviceName,
    String? secret,
    String? serviceUuid,
    String? writeCharacteristicUuid,
    String? notifyCharacteristicUuid,
  }) {
    return AppSettings(
      deviceName: deviceName ?? this.deviceName,
      secret: secret ?? this.secret,
      serviceUuid: serviceUuid ?? this.serviceUuid,
      writeCharacteristicUuid: writeCharacteristicUuid ?? this.writeCharacteristicUuid,
      notifyCharacteristicUuid: notifyCharacteristicUuid ?? this.notifyCharacteristicUuid,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          deviceName == other.deviceName &&
          secret == other.secret &&
          serviceUuid == other.serviceUuid &&
          writeCharacteristicUuid == other.writeCharacteristicUuid &&
          notifyCharacteristicUuid == other.notifyCharacteristicUuid;

  @override
  int get hashCode =>
      deviceName.hashCode ^
      secret.hashCode ^
      serviceUuid.hashCode ^
      writeCharacteristicUuid.hashCode ^
      notifyCharacteristicUuid.hashCode;

  @override
  String toString() {
    return 'AppSettings{deviceName: $deviceName, serviceUuid: $serviceUuid, writeUuid: $writeCharacteristicUuid, notifyUuid: $notifyCharacteristicUuid}';
  }
}