import 'package:comind/api.dart';
import 'package:comind/stream.dart';
import 'package:comind/types/concept.dart';
import 'package:comind/types/thought.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:comind/colors.dart';
import 'package:web_socket_channel/status.dart' as status;

// Authentication provider
class AuthProvider extends ChangeNotifier {
  String username = '';
  String userId = '';
  bool _isLoggedIn = false;
  bool _loginFailed = false;
  String token = '';

  bool get isLoggedIn => _isLoggedIn;
  bool get loginFailed => _loginFailed;

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
      token = maybeToken;
      _isLoggedIn = true;

      // Get the username from the token
      try {
        final jwt = JWT.decode(token);
        print(jwt.payload);
        username = jwt.payload['username'] as String;
        userId = jwt.payload['user_id'] as String;

        notifyListeners();
      } catch (e) {
        throw ('Error parsing JWT: $e');
      }
    }
  }

  void login() {
    _isLoggedIn = true;

    // Grab the token, set the username
    SharedPreferences.getInstance().then((prefs) {
      token = prefs.getString('token')!;
      try {
        final jwt = JWT.decode(token);
        username = jwt.payload['username'] as String;
      } catch (e) {
        _loginFailed = true;
        throw ('Error parsing JWT: $e');
      }
    });

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
  // Brain buffer list size
  static const maxBufferSize = 20;

  // How many thoughts to display in the top of mind.
  // A chain can be as long as maxBufferSize, but only the
  // first maxBufferDisplaySize thoughts will be displayed.
  static const maxBufferDisplaySize = 3;
  List<Thought> brainBuffer = [];

  final List<Thought> _thoughts = [];
  final List<Thought> _relatedThoughts = [];

  List<Thought> get relatedThoughts => _relatedThoughts;

  // Set method for related thoughts
  void setRelatedThoughts(List<Thought> thoughts) {
    _relatedThoughts.clear();
    _relatedThoughts.addAll(thoughts);
    notifyListeners();
  }

  // Only get thoughts not in the top of mind
  List<Thought> get thoughts {
    return _thoughts.where((element) {
      return !brainBuffer.any((brainElement) => brainElement.id == element.id);
    }).toList();
  }

  bool get hasThoughts => _thoughts.isNotEmpty;
  bool get hasTopOfMind => brainBuffer.isNotEmpty;
  bool get hasRelatedThoughts => _relatedThoughts.isNotEmpty;

  // Add a thought to the top of mind
  void addTopOfMind(BuildContext context, Thought thought) {
    // First, check that it is not already in the buffer
    if (brainBuffer.any((element) => element.id == thought.id)) {
      return;
    }

    // Link the most recent top of mind thought to the new thought
    if (getTopOfMind(context) != null) {
      linkToMostRecentTopOfMind(context, thought.id);
    }

    brainBuffer.add(thought);

    // Remove the oldest thought if the buffer is too big
    if (brainBuffer.length > maxBufferSize) {
      brainBuffer.removeAt(0);
    }

    // Any time the top of mind changes, we want to fetch related thoughts.
    _relatedThoughts.clear();

    // Similarly, we want to send our current top of mind to the server.
    sendTopOfMind(context);

    // Update related thoughts
    fetchRelatedThoughts(context);

    notifyListeners();
  }

  // Method to send the top of mind thought to the server. It also returns a list
  // of related thoughts. The context is required to access the API.
  Future<List<Thought>> sendTopOfMind(BuildContext context) async {
    // If there is no top of mind thought, do nothing
    if (!hasTopOfMind) {
      return [];
    }

    // Get a list of IDs of the top of mind thoughts
    final ids = brainBuffer.map((e) => e.id).toList();

    // Send the top of mind thought to the server
    final relatedThoughts = await updateTopOfMind(context, ids);

    // Clear the related thoughts
    _thoughts.clear();

    // Add the related thoughts to the provider
    addThoughts(relatedThoughts);

    return relatedThoughts;
  }

  // Method to fetch thoughts related to the top of mind thought.
  // These are stored in the ThoughtsProvider. the context is
  // required to access the API.
  void fetchRelatedThoughts(BuildContext context) async {
    // If there is no top of mind thought, do nothing
    if (!hasTopOfMind) {
      return;
    }

    // Get the top of mind thought
    final topOfMind = brainBuffer.last;

    // Search for related thoughts
    final relatedThoughts = await searchThoughts(context, topOfMind.body);

    // Clear the related thoughts
    _relatedThoughts.clear();

    // Set the related thoughts
    _relatedThoughts.addAll(relatedThoughts);

    // Add the related thoughts to the provider
    Provider.of<ThoughtsProvider>(context, listen: false)
        .addThoughts(relatedThoughts);
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

    Logger.root.info('Removed thought ${thought.id} from TOM');
    notifyListeners();
  }

  // Remove all thoughts/brain buffer
  void clearBrainBuffer() {
    brainBuffer.clear();
    notifyListeners();
  }

  // Clear the related thoughts
  void clearRelatedThoughts() {
    _relatedThoughts.clear();
    notifyListeners();
  }

  // Clear EVERYTHING
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

void linkToTopOfMind(BuildContext context, String id) {
  // iterate through all top of mind thoughts and link them to the thought
  // with the given id
  Provider.of<ThoughtsProvider>(context, listen: false)
      .brainBuffer
      .forEach((element) {
    linkThoughts(context, element.id, id);
  });
}

// Link the most recent top of mind thought to the thought with the given id
void linkToMostRecentTopOfMind(BuildContext context, String id) {
  // Get the most recent top of mind thought
  final topOfMind =
      Provider.of<ThoughtsProvider>(context, listen: false).brainBuffer.last;

  linkThoughts(context, topOfMind.id, id);
}

// Concept provider
class ConceptsProvider extends ChangeNotifier {
  final List<Concept> _concepts = [];

  List<Concept> get concepts => _concepts;

  void addConcepts(List<Concept> concepts) {
    concepts.forEach(addConcept);
  }

  void addConcept(Concept concept) {
    // Add concept if it doesn't already exist. Search by id.
    concepts.add(concept);
    // if (!_concepts.any((element) => element.id == concept.id)) {
    //   _concepts.add(concept);
    // }

    notifyListeners();
  }

  void removeConcept(Concept concept) {
    _concepts.removeWhere((element) => element.id == concept.id);
    notifyListeners();
  }

  void clear() {
    _concepts.clear();
    notifyListeners();
  }
}

//////////////////////////////
////// Notifications /////////
//////////////////////////////

// Notification type
class ComindNotification {
  final int id;
  final String userId;
  final String type;
  final String message;
  final DateTime createdAt;
  bool readStatus;
  final String userThoughtId;
  final String thoughtTitle;
  final String thoughtBody;
  final String linkingThoughtId;
  final String linkingUserId;
  final String linkingUsername;
  final String linkingBody;
  final String linkingTitle;

  ComindNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    required this.createdAt,
    required this.readStatus,
    required this.userThoughtId,
    required this.linkingThoughtId,
    required this.linkingUserId,
    required this.linkingBody,
    required this.linkingTitle,
    required this.thoughtTitle,
    required this.thoughtBody,
    required this.linkingUsername,
  });

  static ComindNotification fromJson(Map<String, dynamic> json) {
    return ComindNotification(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      readStatus: json['read_status'],
      userThoughtId: json['user_thought_id'],
      linkingThoughtId: json['linking_thought_id'],
      linkingUserId: json['linking_user_id'],
      linkingBody: json['linking_thought_body'],
      linkingTitle: json['linking_thought_title'],
      thoughtTitle: json['user_thought_title'],
      thoughtBody: json['user_thought_body'],
      linkingUsername: json['linking_username'],
    );
  }
}

// Notification provider
class NotificationsProvider extends ChangeNotifier {
  final List<ComindNotification> _notifications = [];

  List<ComindNotification> get notifications {
    _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _notifications;
  }

  void addNotifications(List<ComindNotification> notifications) {
    notifications.forEach(addNotification);
  }

  void addNotification(ComindNotification notification) {
    // Add notification if it doesn't already exist. Search by id.
    if (!_notifications.any((element) => element.id == notification.id)) {
      _notifications.add(notification);
    }

    notifyListeners();
  }

  void removeNotification(ComindNotification notification) {
    _notifications.removeWhere((element) => element.id == notification.id);
    notifyListeners();
  }

  void clear() {
    _notifications.clear();
    notifyListeners();
  }
}

// UI provider
enum UIMode { stream, myThoughts, public, consciousness, begin, notifications }

class UIProvider extends ChangeNotifier {
  // The current mode. Modes may be
  // 1. the stream view
  // 2. the user's thoughts
  // 3. the user's top of mind
  // 4. the user's notifications
  // 5. the user's consciousness ("insight view")
  UIMode _mode = UIMode.stream;

  UIMode get mode => _mode;

  void setMode(UIMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void setStreamMode() {
    _mode = UIMode.stream;
    notifyListeners();
  }

  void setMyThoughtsMode() {
    _mode = UIMode.myThoughts;
    notifyListeners();
  }

  void setPublicMode() {
    _mode = UIMode.public;
    notifyListeners();
  }

  void setConsciousnessMode() {
    _mode = UIMode.consciousness;
    notifyListeners();
  }

  void setBeginMode() {
    _mode = UIMode.begin;
    notifyListeners();
  }

  void setNotificationsMode() {
    _mode = UIMode.notifications;
    notifyListeners();
  }
}

// Webscocket provider
// Websocket provider
// class WebsocketProvider extends ChangeNotifier {
//   final String _url = 'wss://nimbus.pfiffer.org/ws';
//   late WebSocketChannel _channel;

//   get stream => _channel.stream;

//   void connect() async {
//     // Connect to the websocket server
//     _channel = WebSocketChannel.connect(
//       Uri.parse(_url),
//     );

//     // Wait for it to be ready
//     await _channel.ready;
//   }

//   void _handleMessage(dynamic message) {
//     // Handle incoming message
//     // TODO: Implement your logic here
//     print("Received message: $message");
//   }

//   void sendMessage(dynamic message) {
//     _channel.sink.add(message);
//     _channel.sink.close(status.goingAway);
//   }

//   void close() {
//     _channel.sink.close();
//   }
// }
