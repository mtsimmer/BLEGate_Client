import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// Information about a discovered BLE device
class BleDeviceInfo {
  final String id;
  final String name;
  final int rssi;
  final DiscoveredDevice discoveredDevice;

  const BleDeviceInfo({
    required this.id,
    required this.name,
    required this.rssi,
    required this.discoveredDevice,
  });

  factory BleDeviceInfo.fromDiscoveredDevice(DiscoveredDevice device) {
    return BleDeviceInfo(
      id: device.id,
      name: device.name,
      rssi: device.rssi,
      discoveredDevice: device,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BleDeviceInfo &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BleDeviceInfo{id: $id, name: $name, rssi: $rssi}';
  }
}