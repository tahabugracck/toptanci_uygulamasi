  import 'package:flutter/material.dart';

class ThemeSettings {
  // Karanlık Tema
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.white,
    ),
    // Menü için daha açık bir ton
    drawerTheme: DrawerThemeData(
      backgroundColor: Colors.grey[850], // Menü arka planı
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );

  // Beyaz Tema
  static final ThemeData whiteTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[200],
      foregroundColor: Colors.black,
    ),
    // Menü için daha koyu bir ton
    drawerTheme: DrawerThemeData(
      backgroundColor: Colors.grey[300], // Menü arka planı
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
  );

  // Standart Tema
  static final ThemeData standardTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFFFF6F61),
    scaffoldBackgroundColor: const Color(0xFFFFE0E0),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFF6F61),
      foregroundColor: Colors.white,
    ),
    // Menü için daha açık bir ton
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFFFFC1C1), // Menü arka planı
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF333333)),
      bodyMedium: TextStyle(color: Color(0xFF666666)),
    ),
  );
}
