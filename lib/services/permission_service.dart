import 'package:permission_handler/permission_handler.dart';

/// Service for managing BLE and location permissions
class PermissionService {
  /// Check if all required permissions are granted
  static Future<bool> hasAllPermissions() async {
    final permissions = await _getRequiredPermissions();
    
    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        return false;
      }
    }
    
    return true;
  }

  /// Request all required permissions
  static Future<bool> requestPermissions() async {
    final permissions = await _getRequiredPermissions();
    
    // Request all permissions at once
    final statuses = await permissions.request();
    
    // Check if all permissions were granted
    for (final status in statuses.values) {
      if (!status.isGranted) {
        return false;
      }
    }
    
    return true;
  }

  /// Get the status of each required permission
  static Future<Map<Permission, PermissionStatus>> getPermissionStatuses() async {
    final permissions = await _getRequiredPermissions();
    final Map<Permission, PermissionStatus> statuses = {};
    
    for (final permission in permissions) {
      statuses[permission] = await permission.status;
    }
    
    return statuses;
  }

  /// Check if any permission is permanently denied
  static Future<bool> hasPermissionsPermanentlyDenied() async {
    final permissions = await _getRequiredPermissions();
    
    for (final permission in permissions) {
      final status = await permission.status;
      if (status.isPermanentlyDenied) {
        return true;
      }
    }
    
    return false;
  }

  /// Open app settings for manual permission management
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Get list of required permissions based on Android version
  static Future<List<Permission>> _getRequiredPermissions() async {
    final List<Permission> permissions = [];
    
    // Always required for BLE
    permissions.add(Permission.bluetoothConnect);
    permissions.add(Permission.bluetoothScan);
    
    // Location permission is required for BLE scanning on Android
    permissions.add(Permission.locationWhenInUse);
    
    return permissions;
  }

  /// Get user-friendly permission names
  static String getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.bluetoothConnect:
        return 'Bluetooth Connect';
      case Permission.bluetoothScan:
        return 'Bluetooth Scan';
      case Permission.locationWhenInUse:
        return 'Location Access';
      default:
        return permission.toString();
    }
  }

  /// Get user-friendly permission descriptions
  static String getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.bluetoothConnect:
        return 'Required to connect to the gate controller device';
      case Permission.bluetoothScan:
        return 'Required to scan for nearby Bluetooth devices';
      case Permission.locationWhenInUse:
        return 'Required for Bluetooth device scanning on Android';
      default:
        return 'Required for app functionality';
    }
  }
}