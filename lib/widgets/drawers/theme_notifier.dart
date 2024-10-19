import 'package:flutter/material.dart';
import 'package:toptanci_uygulamasi/widgets/drawers/theme_setting.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeData _currentTheme = ThemeSettings.standardTheme; // Varsayılan tema

  ThemeData get currentTheme => _currentTheme;

  void setTheme(ThemeData theme) {
    _currentTheme = theme;
    notifyListeners();
  }

  void setDarkTheme() {
    _currentTheme = ThemeSettings.darkTheme; //siyah tema
    notifyListeners();
  }

  void setWhiteTheme() {
    _currentTheme = ThemeSettings.whiteTheme; //beyaz tema
    notifyListeners();
  }

  void setStandardTheme() {
    _currentTheme = ThemeSettings.standardTheme; //standart tema
    notifyListeners();
  }
}
