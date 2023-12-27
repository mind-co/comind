import 'package:flutter/material.dart';

// Authentication provider
class AuthProvider extends ChangeNotifier {
  String username = '';
  bool _isLoggedIn = false;
  bool publicMode = true;

  bool get isLoggedIn => _isLoggedIn;

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
