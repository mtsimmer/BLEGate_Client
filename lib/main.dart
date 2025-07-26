import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/ble_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/log_provider.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const BleGateControllerApp());
}

/// Main application widget for BLE Gate Controller
class BleGateControllerApp extends StatelessWidget {
  const BleGateControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Settings provider - manages app configuration
        ChangeNotifierProvider(
          create: (context) => SettingsProvider(),
        ),
        
        // BLE provider - manages Bluetooth operations
        ChangeNotifierProvider(
          create: (context) => BleProvider(),
        ),
        
        // Log provider - manages interaction logging
        ChangeNotifierProvider(
          create: (context) => LogProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'BLE Gate Controller',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Modern Material Design 3 theme
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          
          // App bar theme
          appBarTheme: AppBarTheme(
            centerTitle: true,
            elevation: 2,
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          // Elevated button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          
          // Card theme
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          
          // Input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue[600]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          
          // Snackbar theme
          snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        
        // Dark theme (optional)
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),
        
        // Use system theme mode
        themeMode: ThemeMode.system,
        
        // Main screen as home
        home: const MainScreen(),
      ),
    );
  }
}
