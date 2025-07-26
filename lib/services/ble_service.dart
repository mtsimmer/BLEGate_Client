import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../models/ble_device_info.dart';
import '../models/app_settings.dart';
import '../utils/constants.dart';

/// Service for managing BLE operations
class BleService {
  static final FlutterReactiveBle _ble = FlutterReactiveBle();
  
  // Stream controllers for reactive updates
  final _connectionStateController = StreamController<BleConnectionState>.broadcast();
  final _deviceController = StreamController<BleDeviceInfo?>.broadcast();
  final _notificationController = StreamController<String>.broadcast();
  
  // Current state
  BleConnectionState _connectionState = BleConnectionState.disconnected;
  BleDeviceInfo? _connectedDevice;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  StreamSubscription<List<int>>? _notificationSubscription;
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  
  // Getters for current state
  BleConnectionState get connectionState => _connectionState;
  BleDeviceInfo? get connectedDevice => _connectedDevice;
  
  // Streams for reactive updates
  Stream<BleConnectionState> get connectionStateStream => _connectionStateController.stream;
  Stream<BleDeviceInfo?> get deviceStream => _deviceController.stream;
  Stream<String> get notificationStream => _notificationController.stream;

  /// Initialize the BLE service
  Future<void> initialize() async {
    _updateConnectionState(BleConnectionState.disconnected);
  }

  /// Scan for devices with the specified name
  Future<BleDeviceInfo?> scanForDevice(String deviceName, {Duration? timeout}) async {
    if (_connectionState != BleConnectionState.disconnected) {
      throw Exception('Cannot scan while connected or connecting');
    }

    _updateConnectionState(BleConnectionState.scanning);
    
    final completer = Completer<BleDeviceInfo?>();
    final scanTimeout = timeout ?? BleConstants.scanTimeout;
    
    // Set up timeout
    Timer(scanTimeout, () {
      if (!completer.isCompleted) {
        _scanSubscription?.cancel();
        _updateConnectionState(BleConnectionState.disconnected);
        completer.complete(null);
      }
    });

    try {
      _scanSubscription = _ble.scanForDevices(
        withServices: [], // Scan for all devices
        scanMode: ScanMode.lowLatency,
      ).listen((device) {
        if (device.name == deviceName && !completer.isCompleted) {
          _scanSubscription?.cancel();
          final deviceInfo = BleDeviceInfo.fromDiscoveredDevice(device);
          completer.complete(deviceInfo);
        }
      });
    } catch (e) {
      _updateConnectionState(BleConnectionState.error);
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    }

    return completer.future;
  }

  /// Connect to a BLE device
  Future<bool> connectToDevice(BleDeviceInfo deviceInfo, {Duration? timeout}) async {
    if (_connectionState != BleConnectionState.disconnected && 
        _connectionState != BleConnectionState.scanning) {
      throw Exception('Already connected or connecting');
    }

    _updateConnectionState(BleConnectionState.connecting);
    _connectedDevice = deviceInfo;
    _deviceController.add(_connectedDevice);

    final completer = Completer<bool>();
    final connectionTimeout = timeout ?? BleConstants.connectionTimeout;
    
    // Set up timeout
    Timer(connectionTimeout, () {
      if (!completer.isCompleted) {
        _connectionSubscription?.cancel();
        _updateConnectionState(BleConnectionState.error);
        completer.complete(false);
      }
    });

    try {
      _connectionSubscription = _ble.connectToDevice(
        id: deviceInfo.id,
        connectionTimeout: connectionTimeout,
      ).listen((connectionState) {
        switch (connectionState.connectionState) {
          case DeviceConnectionState.connected:
            _updateConnectionState(BleConnectionState.connected);
            if (!completer.isCompleted) {
              completer.complete(true);
            }
            break;
          case DeviceConnectionState.disconnected:
            _updateConnectionState(BleConnectionState.disconnected);
            _connectedDevice = null;
            _deviceController.add(null);
            if (!completer.isCompleted) {
              completer.complete(false);
            }
            break;
          case DeviceConnectionState.connecting:
            // Stay in connecting state
            break;
          case DeviceConnectionState.disconnecting:
            _updateConnectionState(BleConnectionState.disconnected);
            break;
        }
      });
    } catch (e) {
      _updateConnectionState(BleConnectionState.error);
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    }

    return completer.future;
  }

  /// Write the secret to the write characteristic
  Future<bool> writeSecret(String secret, AppSettings settings) async {
    if (_connectionState != BleConnectionState.connected || _connectedDevice == null) {
      throw Exception('Not connected to device');
    }

    _updateConnectionState(BleConnectionState.authenticating);

    try {
      final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(settings.serviceUuid),
        characteristicId: Uuid.parse(settings.writeCharacteristicUuid),
        deviceId: _connectedDevice!.id,
      );

      final secretBytes = Uint8List.fromList(secret.codeUnits);
      await _ble.writeCharacteristicWithResponse(characteristic, value: secretBytes);
      
      _updateConnectionState(BleConnectionState.authenticated);
      return true;
    } catch (e) {
      _updateConnectionState(BleConnectionState.error);
      throw Exception('Failed to write secret: $e');
    }
  }

  /// Subscribe to notifications from the notify characteristic
  Future<void> subscribeToNotifications(AppSettings settings) async {
    if (_connectionState != BleConnectionState.connected && 
        _connectionState != BleConnectionState.authenticated || 
        _connectedDevice == null) {
      throw Exception('Not connected to device');
    }

    try {
      final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(settings.serviceUuid),
        characteristicId: Uuid.parse(settings.notifyCharacteristicUuid),
        deviceId: _connectedDevice!.id,
      );

      _notificationSubscription = _ble.subscribeToCharacteristic(characteristic).listen(
        (data) {
          final message = String.fromCharCodes(data);
          _notificationController.add(message);
        },
        onError: (error) {
          _notificationController.addError(error);
        },
      );
    } catch (e) {
      throw Exception('Failed to subscribe to notifications: $e');
    }
  }

  /// Disconnect from the current device
  Future<void> disconnect() async {
    await _connectionSubscription?.cancel();
    await _notificationSubscription?.cancel();
    await _scanSubscription?.cancel();
    
    _connectionSubscription = null;
    _notificationSubscription = null;
    _scanSubscription = null;
    _connectedDevice = null;
    
    _updateConnectionState(BleConnectionState.disconnected);
    _deviceController.add(null);
  }

  /// Scan and connect to device in one operation
  Future<bool> scanAndConnect(String deviceName, AppSettings settings) async {
    try {
      // First scan for the device
      final device = await scanForDevice(deviceName);
      if (device == null) {
        return false;
      }

      // Then connect to it
      final connected = await connectToDevice(device);
      if (!connected) {
        return false;
      }

      // Subscribe to notifications
      await subscribeToNotifications(settings);
      
      return true;
    } catch (e) {
      _updateConnectionState(BleConnectionState.error);
      return false;
    }
  }

  /// Complete gate opening workflow with improved reconnection logic
  Future<bool> openGate(String deviceName, String secret, AppSettings settings) async {
    try {
      // Always ensure we have a fresh connection for reliability
      if (_connectionState != BleConnectionState.connected &&
          _connectionState != BleConnectionState.authenticated) {
        // Need to scan and connect
        final connected = await scanAndConnect(deviceName, settings);
        if (!connected) {
          return false;
        }
      } else {
        // We think we're connected, but let's verify by trying to write
        // If it fails, we'll reconnect
        try {
          // Test the connection by attempting to write
          await writeSecret(secret, settings);
          return true;
        } catch (e) {
          // Connection might be stale, disconnect and reconnect
          await disconnect();
          final connected = await scanAndConnect(deviceName, settings);
          if (!connected) {
            return false;
          }
        }
      }

      // Write the secret (if we haven't already done so above)
      if (_connectionState != BleConnectionState.authenticated) {
        await writeSecret(secret, settings);
      }
      
      return true;
    } catch (e) {
      _updateConnectionState(BleConnectionState.error);
      return false;
    }
  }

  /// Update connection state and notify listeners
  void _updateConnectionState(BleConnectionState newState) {
    _connectionState = newState;
    _connectionStateController.add(_connectionState);
  }

  /// Dispose of the service and clean up resources
  void dispose() {
    disconnect();
    _connectionStateController.close();
    _deviceController.close();
    _notificationController.close();
  }
}