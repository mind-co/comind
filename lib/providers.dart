import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDarkMode = true;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}
