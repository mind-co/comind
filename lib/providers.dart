import 'package:comind/api.dart';
import 'package:comind/types/thought.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  // Brain buffer
  static const maxBufferSize = 3;
  List<Thought> brainBuffer = [];

  final List<Thought> _thoughts = [];

  List<Thought> get thoughts => _thoughts;
  bool get hasThoughts => _thoughts.isNotEmpty;
  bool get hasTopOfMind => brainBuffer.isNotEmpty;

  // Add a thought to the top of mind
  void addTopOfMind(Thought thought) {
    brainBuffer.add(thought);

    // Remove the oldest thought if the buffer is too big
    if (brainBuffer.length > maxBufferSize) {
      brainBuffer.removeAt(0);
    }

    notifyListeners();
  }

  // Add a list of thoughts but only if they don't already exist
  void addThoughts(List<Thought> thoughts) {
    thoughts.forEach(addThought);
  }

  void addThought(Thought thought) {
    // Add thought if it doesn't already exist. Search by id.
    if (!_thoughts.any((element) => element.id == thought.id)) {
      _thoughts.add(thought);
    }

    // Sort the thoughts by date
    _thoughts.sort((a, b) => b.dateUpdated.compareTo(a.dateUpdated));

    notifyListeners();
  }

  void removeThought(Thought thought) {
    _thoughts.removeWhere((element) => element.id == thought.id);

    print("Removing ${thought.id}");
    notifyListeners();
  }

  // Remove all thoughts/brain buffer
  void clear() {
    _thoughts.clear();
    brainBuffer.clear();
    notifyListeners();
  }
}

Thought? getTopOfMind(BuildContext context) {
  // return Provider.of<ThoughtsProvider>(context, listen: false).brainBuffer.last;
  if (Provider.of<ThoughtsProvider>(context, listen: false).hasTopOfMind) {
    return Provider.of<ThoughtsProvider>(context, listen: false)
        .brainBuffer
        .last;
  } else {
    return null;
  }
}

void addTopOfMind(BuildContext context, Thought thought) {
  return Provider.of<ThoughtsProvider>(context, listen: false)
      .addTopOfMind(thought);
}

void linkToTopOfMind(BuildContext context, String id) {
  // iterate through all top of mind thoughts and link them to the thought
  // with the given id
  Provider.of<ThoughtsProvider>(context, listen: false)
      .brainBuffer
      .forEach((element) {
    linkThoughts(context, element.id, id);
  });
}
