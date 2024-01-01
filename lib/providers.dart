import 'package:comind/types/thought.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Authentication provider
class AuthProvider extends ChangeNotifier {
  String username = '';
  bool _isLoggedIn = false;
  bool publicMode = true;
  String token = '';

  bool get isLoggedIn => _isLoggedIn;

  // Init method
  AuthProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  // Init method should load the token
  // from shared preferences
  void init() async {
    // Load the token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? maybeToken = prefs.getString('token');

    if (maybeToken != null) {
      _isLoggedIn = true;
      token = maybeToken;

      // Get the username from the token
      try {
        final jwt = JWT.decode(token);
        username = jwt.payload['username'] as String;

        notifyListeners();
      } catch (e) {
        throw ('Error parsing JWT: $e');
      }
    }
  }

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    // Remove the token from shared preferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('token');
    });
    notifyListeners();
  }
}

// Thought provider
class ThoughtsProvider extends ChangeNotifier {
  final List<Thought> _thoughts = [];

  List<Thought> get thoughts => _thoughts;

  void addThought(Thought thought) {
    // Add thought if it doesn't already exist. Search by id.
    if (!_thoughts.any((element) => element.id == thought.id)) {
      _thoughts.add(thought);
    }

    notifyListeners();
  }

  void removeThought(Thought thought) {
    _thoughts.removeWhere((element) => element.id == thought.id);
    notifyListeners();
  }
}
