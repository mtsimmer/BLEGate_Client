import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/ble_device_info.dart';
import '../models/app_settings.dart';
import '../services/ble_service.dart';
import '../services/permission_service.dart';
import '../utils/constants.dart';

/// Provider for managing BLE operations and state
class BleProvider with ChangeNotifier {
  final BleService _bleService = BleService();
  
  // State variables
  BleConnectionState _connectionState = BleConnectionState.disconnected;
  BleDeviceInfo? _connectedDevice;
  bool _hasPermissions = false;
  String? _error;
  
  // Stream subscriptions
  StreamSubscription<BleConnectionState>? _connectionStateSubscription;
  StreamSubscription<BleDeviceInfo?>? _deviceSubscription;
  StreamSubscription<String>? _notificationSubscription;

  // Getters
  BleConnectionState get connectionState => _connectionState;
  BleDeviceInfo? get connectedDevice => _connectedDevice;
  bool get hasPermissions => _hasPermissions;
  String? get error => _error;
  bool get isConnected => _connectionState == BleConnectionState.connected || 
                         _connectionState == BleConnectionState.authenticated;
  bool get isConnecting => _connectionState == BleConnectionState.connecting ||
                          _connectionState == BleConnectionState.scanning;

  // Streams
  Stream<String> get notificationStream => _bleService.notificationStream;

  /// Initialize the BLE provider
  Future<void> initialize() async {
    await _bleService.initialize();
    await _checkPermissions();
    _setupStreamListeners();
  }

  /// Check and request BLE permissions
  Future<bool> checkAndRequestPermissions() async {
    _hasPermissions = await PermissionService.hasAllPermissions();
    
    if (!_hasPermissions) {
      _hasPermissions = await PermissionService.requestPermissions();
    }
    
    notifyListeners();
    return _hasPermissions;
  }

  /// Open the gate (main functionality)
  Future<bool> openGate(AppSettings settings) async {
    if (!_hasPermissions) {
      _setError('Permissions not granted');
      return false;
    }

    _clearError();
    
    try {
      final success = await _bleService.openGate(
        settings.deviceName,
        settings.secret,
        settings,
      );
      
      if (!success) {
        _setError('Failed to open gate - device not found or connection failed');
      }
      
      return success;
    } catch (e) {
      _setError('Error opening gate: $e');
      return false;
    }
  }

  /// Manually scan for devices
  Future<BleDeviceInfo?> scanForDevice(String deviceName) async {
    if (!_hasPermissions) {
      _setError('Permissions not granted');
      return null;
    }

    _clearError();
    
    try {
      return await _bleService.scanForDevice(deviceName);
    } catch (e) {
      _setError('Error scanning for device: $e');
      return null;
    }
  }

  /// Manually connect to a device
  Future<bool> connectToDevice(BleDeviceInfo deviceInfo) async {
    if (!_hasPermissions) {
      _setError('Permissions not granted');
      return false;
    }

    _clearError();
    
    try {
      return await _bleService.connectToDevice(deviceInfo);
    } catch (e) {
      _setError('Error connecting to device: $e');
      return false;
    }
  }

  /// Disconnect from current device
  Future<void> disconnect() async {
    _clearError();
    await _bleService.disconnect();
  }

  /// Get connection state display text
  String get connectionStateText {
    switch (_connectionState) {
      case BleConnectionState.disconnected:
        return 'Disconnected';
      case BleConnectionState.scanning:
        return 'Scanning...';
      case BleConnectionState.connecting:
        return 'Connecting...';
      case BleConnectionState.connected:
        return 'Connected';
      case BleConnectionState.authenticating:
        return 'Authenticating...';
      case BleConnectionState.authenticated:
        return 'Authenticated';
      case BleConnectionState.error:
        return 'Error';
    }
  }

  /// Get connection state color
  int get connectionStateColor {
    switch (_connectionState) {
      case BleConnectionState.disconnected:
        return 0xFFFF5722; // Red
      case BleConnectionState.scanning:
      case BleConnectionState.connecting:
      case BleConnectionState.authenticating:
        return 0xFFFF9800; // Orange
      case BleConnectionState.connected:
      case BleConnectionState.authenticated:
        return 0xFF4CAF50; // Green
      case BleConnectionState.error:
        return 0xFFF44336; // Dark Red
    }
  }

  /// Check if permissions are permanently denied
  Future<bool> arePermissionsPermanentlyDenied() async {
    return await PermissionService.hasPermissionsPermanentlyDenied();
  }

  /// Open app settings for manual permission management
  Future<bool> openAppSettings() async {
    return await PermissionService.openAppSettings();
  }

  void _setupStreamListeners() {
    _connectionStateSubscription = _bleService.connectionStateStream.listen((state) {
      _connectionState = state;
      notifyListeners();
    });

    _deviceSubscription = _bleService.deviceStream.listen((device) {
      _connectedDevice = device;
      notifyListeners();
    });
  }

  Future<void> _checkPermissions() async {
    _hasPermissions = await PermissionService.hasAllPermissions();
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

  @override
  void dispose() {
    _connectionStateSubscription?.cancel();
    _deviceSubscription?.cancel();
    _notificationSubscription?.cancel();
    _bleService.dispose();
    super.dispose();
  }
}