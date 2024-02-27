import 'dart:convert';
import 'package:comind/colors.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/providers.dart';
import 'package:comind/types/concept.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:comind/types/thought.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

// logging
// import 'package:logging/logging.dart';

// Initialize Dio
final dio = Dio();

String endpoint(String path) {
  // String serverUrl = dotenv.env['COMIND_SERVER_URL'] ?? 'http://localhost:8000';
  String serverUrl = const String.fromEnvironment('COMIND_SERVER_URL');

  // If the server url is not set, fallback to https://nimbus.pfiffer.org and warn
  if (serverUrl == "") {
    serverUrl = 'https://nimbus.pfiffer.org';
    Logger.root.warning(
        'COMIND_SERVER_URL is not set, falling back to https://nimbus.pfiffer.org');
  }

  return serverUrl + path;
}

// Function to get the base headers for a request,
// handles auth and username if in the context
Map<String, String> getBaseHeaders(BuildContext context) {
  final headers = <String, String>{};

  // Add the username to the headers if it exists
  final username = Provider.of<AuthProvider>(context, listen: false).username;
  headers['ComindUsername'] = username;

  // Add the auth token to the headers if it exists
  final token = Provider.of<AuthProvider>(context, listen: false).token;
  headers['Authorization'] = 'Bearer $token';

  return headers;
}

// Gets all user thoughts
Future<List<Thought>> fetchThoughts(BuildContext context) async {
  final url = Uri.parse(endpoint('/api/user-thoughts/cameron/'));
  final headers = getBaseHeaders(context);
  headers['ComindPageNo'] = '0';
  headers['ComindLimit'] = '10';

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    final List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((thought) => Thought.fromJson(thought)).toList();
  } else {
    throw Exception(
        'Failed to load thoughts, status code: ${response.statusCode} and body: ${response.body}');
  }
}

// Method to save a quick thought that has only
// body, isPublic, and an optional parentThoughtId
Future<Thought> saveQuickThought(BuildContext context, String body,
    bool isPublic, String? parentThoughtId, String? childThoughtId) async {
  final url = Uri.parse(endpoint('/api/thoughts/'));

  final headers = getBaseHeaders(context);

  final bodyJson = <String, dynamic>{
    'body': body,
    'public': isPublic,
    'synthetic': false,
    'origin': "app",
  };

  // If the thought has a parentThoughtId, add it to the body
  if (parentThoughtId != null) {
    bodyJson['parent_thought_id'] = parentThoughtId;
  }

  // If the thought has a childThoughtId, add it to the body
  if (childThoughtId != null) {
    bodyJson['child_thought_id'] = childThoughtId;
  }

  final response = await http.post(
    url,
    headers: headers,
    body: jsonEncode(bodyJson),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to save thought');
  }

  // Try to parse the response as json
  try {
    final jsonResponse = json.decode(response.body);
    return Thought.fromJson(jsonResponse);
  } catch (e) {
    throw Exception('Failed to parse new thought as JSON');
  }
}

Future<void> saveThought(BuildContext context, Thought thought,
    {bool? newThought}) async {
  // Get URI
  final url = Uri.parse(endpoint('/api/thoughts/'));

  // Log that we're saving the thought
  Logger.root.info(
      "{'location':'saveThought','new_id: ${thought.id}','sending_to':'$url','body':'${thought.body}'}");

  // If the thought has an ID, we're updating an existing thought.
  // By default empty thoughts have and ID of length 0.
  if (newThought == true) {
    final headers = getBaseHeaders(context);

    final body = jsonEncode(<String, dynamic>{
      'id': thought.id,
      'body': thought.body.trim(), // Trim leading and trailing whitespace
      'public': thought.isPublic,
      'synthetic': false,
      'origin': "app",
      'title': thought.title.trim()
    });

    // Logging
    Logger.root.info("Sending thought with POST");
    Logger.root.info("Body: $body");

    // Dio version
    // final dio = Dio();

    // final response = await dio.post(
    //   url.toString(),
    //   options: Options(headers: headers),
    //   data: body,
    // );

    // final result = response.data;

    // Log post response
    // Logger.root.info("saveThought response: ${result}");

    // HTTP version
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save thought');
    }

    final jsonResponse = json.decode(response.body);

    Logger.root.info("saveThought response: ${jsonResponse}");

    // Try to parse the response as json
    try {
      // final jsonResponse = json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to parse new thought as JSON');
    }
  } else {
    // Otherwise, we are updating an existing thought.
    // We use the PATCH method to update the thought.
    final headers = getBaseHeaders(context);
    headers['ComindThoughtId'] = thought.id;

    final body = jsonEncode(<String, dynamic>{
      'body': thought.body,
      'public': thought.isPublic,
      'synthetic': false,
      'origin': "app",
    });

    final response = await http.patch(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to save thought. Status code: ${response.statusCode} and body: ${response.body}');
    }

    // Try to parse the response as json
    try {
      // print("Sent thought with body ${thought.body} to server");
      // final jsonResponse = json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to parse new thought as JSON');
    }
  }
}

Future<void> deleteThought(BuildContext context, String thoughtId) async {
  final url = Uri.parse(endpoint('/api/thoughts/'));
  final headers = getBaseHeaders(context);
  headers['ComindThoughtId'] = thoughtId;

  final response = await http.delete(url, headers: headers);

  if (response.statusCode != 200) {
    throw Exception('Failed to delete thought');
  }
  // Try to parse the response as json
  try {
    // final jsonResponse = json.decode(response.body);
  } catch (e) {
    throw Exception('Failed to delete thought');
  }
}

// The basic version of authentication
// 1. Alice hashes her password.
// 2. Alice sends the hashed password to Bob.
// 3. Bob hits it with bcrypt and checks if the password is valid.
// 4. If valid, Bob sends a JWT to Alice so they can use the page.
// 5. Alice parties.

Future<bool> newUser(String username, String email, String password) async {
  final url = Uri.parse(endpoint('/api/new-user/'));
  final headers = {
    'ComindUsername': username,
    'ComindHashedPassword': password,
    'ComindEmail': email,
  };

  await http.post(url, headers: headers);

  // if (response.statusCode != 200) {
  //   return false;
  //   throw Exception('Failed to create user');
  // }

  return true;
}

Future<bool> userExists(String username) async {
  final url = Uri.parse(endpoint('/api/user-exists/'));
  final headers = {
    'ComindUsername': username,
  };

  final response = await http.get(url, headers: headers);

  if (response.statusCode != 200) {
    throw Exception('Failed to check if user exists');
  }

  final jsonResponse = json.decode(response.body);
  return jsonResponse['exists'];
}

Future<bool> emailExists(String email) async {
  final url = Uri.parse(endpoint('/api/email-taken/'));

  final headers = {
    'ComindEmail': email,
  };

  final response = await http.get(url, headers: headers);

  if (response.statusCode != 200) {
    throw Exception('Failed to check if email exists');
  }

  final jsonResponse = json.decode(response.body);
  return jsonResponse['taken'];
}

// Search result type
class SearchResult {
  final String id;
  final String body;
  final String title;
  final String username;
  final double cosineSimilarity;
  final int? numLinks;
  final bool? linkedTo;
  final bool? linkedFrom;

  SearchResult({
    required this.id,
    required this.body,
    required this.username,
    required this.title,
    required this.cosineSimilarity,
    this.numLinks = 0,
    this.linkedTo = false,
    this.linkedFrom = false,
  });

  static SearchResult fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'],
      body: json['body'],
      username: json['username'],
      title: json['title'],
      cosineSimilarity: json['cosinesimilarity'],
      numLinks: json['numlinks'],
      linkedTo: json['linked_to'],
      linkedFrom: json['linked_from'],
    );
  }
}

Future<List<Thought>> searchThoughts(BuildContext context, String query,
    {String? associatedId}) async {
  print("FUCK");
  final url = Uri.parse(endpoint('/api/search/'));
  final body = associatedId == null
      ? jsonEncode(<String, dynamic>{
          'query': query,
          'limit': 5,
          'pageno': 0,
        })
      : jsonEncode(<String, dynamic>{
          'query': query,
          'associated_id': associatedId,
          'limit': 5,
          'pageno': 0,
        });

  final encodedBody = utf8.encode(body);

  String token = getToken(context);
  final headers = {
    'ComindUsername': 'cameron',
    "Content-Type": "application/json",
    "Content-Length": "${encodedBody.length}",
    'Authorization': 'Bearer $token'
  };

  final response = await dio.post(
    url.toString(),
    data: body,
    options: Options(
      headers: headers,
    ),
  );

  if (response.statusCode == 200 && response.data is List) {
    final jsonResponse = response.data as List;
    var result = jsonResponse.map((thought) {
      if (thought is Map<String, dynamic>) {
        // Sort in descending order by cosine similarity
        return Thought.fromJson(thought);
      } else {
        throw Exception('Invalid data format');
      }
    }).toList();

    // Sort in descending order by cosine similarity
    result.sort((a, b) => b.cosineSimilarity!.compareTo(a.cosineSimilarity!));

    return result;
  } else {
    throw Exception('Failed to search');
  }
}

// Asks the database for a specific thought by ID
Future<Thought> fetchThought(BuildContext context, String id) async {
  final url = Uri.parse(endpoint('/api/thoughts/'));
  final headers = getBaseHeaders(context);
  headers['ComindThoughtId'] = id;
  headers['Content-Type'] = 'application/json';

  final response = await dio.get(
    url.toString(),
    options: Options(
      headers: headers,
    ),
  );

  if (response.statusCode == 200) {
    final jsonResponse = response.data;
    return Thought.fromJson(jsonResponse);
  } else {
    throw Exception('Failed to load thought');
  }
}

// Login method
class LoginResponse {
  final bool success;
  final String? message;
  final String? token;

  LoginResponse({
    required this.success,
    this.token,
    this.message,
  });

  static LoginResponse fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'],
      token: json['token'],
      message: json['message'],
    );
  }
}

Future<LoginResponse> login(String username, String password) async {
  final url = Uri.parse(endpoint('/api/login/'));

  final body = jsonEncode(<String, dynamic>{
    'username': username,
    'password': password,
  });

  final response = await http.post(url, body: body);

  if (response.statusCode != 200) {
    throw Exception('Failed to login');
  }

  final jsonResponse = json.decode(response.body);
  return LoginResponse.fromJson(jsonResponse);
}

Future<bool> linkThoughts(context, String fromId, String toId) async {
  final url = Uri.parse(endpoint('/api/link/'));

  final headers = getBaseHeaders(context);
  headers['ComindFromId'] = fromId;
  headers['ComindToId'] = toId;

  final response = await dio.post(
    url.toString(),
    options: Options(
      headers: headers,
    ),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Failed to link thoughts');
  }
}

// Fetch children
Future<List<Thought>> fetchChildren(
    BuildContext context, String thoughtId) async {
  final url = Uri.parse(endpoint('/api/children/'));

  // Headers
  final headers = getBaseHeaders(context);
  headers['ComindThoughtId'] = thoughtId;

  final response = await dio.get(
    url.toString(),
    options: Options(
      headers: headers,
    ),
  );

  print("Children response: ${response.data}");

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.data);
    return jsonResponse
        .map<Thought>((thought) => Thought.fromJson(thought))
        .toList();
  } else {
    throw Exception('Failed to load children');
  }
}

// Fetch parents
Future<List<Thought>> fetchParents(
    BuildContext context, String thoughtId) async {
  final url = Uri.parse(endpoint('/api/parents/'));

  final headers = getBaseHeaders(context);
  headers['ComindThoughtId'] = thoughtId;

  final response = await dio.get(
    url.toString(),
    options: Options(
      headers: headers,
    ),
  );

  print("Parents response: ${response.data}");

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.data);
    if (jsonResponse is List) {
      return jsonResponse
          .map((thought) => Thought.fromJson(thought))
          .toList()
          .cast<Thought>();
    } else {
      throw Exception('Decoded data is not a list');
    }
  } else {
    throw Exception('Failed to load parents');
  }
}

// Toggle public. To do this, we send a PATCH request to the server
// with the thought ID and the new public value.
Future<void> setPublic(
    BuildContext context, String thoughtId, bool isPublic) async {
  final url = Uri.parse(endpoint('/api/thoughts/'));

  final headers = getBaseHeaders(context);
  headers['ComindThoughtId'] = thoughtId;

  final body = jsonEncode(<String, dynamic>{
    'public': isPublic,
  });

  final response = await dio.patch(
    url.toString(),
    data: body,
    options: Options(
      headers: headers,
    ),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to toggle public');
  }
}

// Fetch all public thoughts
Future<List<Thought>> getStream(BuildContext context) async {
  final url = Uri.parse(endpoint('/api/stream/'));

  final headers = getBaseHeaders(context);
  headers['ComindPageNo'] = '0';
  headers['ComindLimit'] = '10';

  final response = await dio.get(
    url.toString(),
    options: Options(
      headers: headers,
    ),
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.data);
    return jsonResponse
        .map<Thought>((thought) => Thought.fromJson(thought))
        .toList();
  } else {
    throw Exception('Failed to load public thoughts');
  }
}

// Update the server with the current top of mind. The API call
// returns a new list of thoughts.
Future<List<Thought>> updateTopOfMind(
    BuildContext context, List<String> ids) async {
  final url = Uri.parse(endpoint('/api/top-of-mind/'));

  final headers = getBaseHeaders(context);

  final body = jsonEncode(<String, dynamic>{
    'thought_ids': ids,
    'date_updated': DateTime.now().toIso8601String(),
  });

  final response = await dio.post(
    url.toString(),
    data: body,
    options: Options(
      headers: headers,
    ),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update top of mind');
  } else {
    // print(response.data);
    // final jsonResponse = json.decode(response.data);
    final jsonResponse = response.data;
    var newThoughts = jsonResponse
        .map<Thought>((thought) => Thought.fromJson(thought))
        .toList();

    return newThoughts;
  }
}

// Get concepts from the server
Future<List<Concept>> fetchConcepts(BuildContext context) async {
  final url = Uri.parse(endpoint('/api/concepts/'));

  final headers = getBaseHeaders(context);
  headers['ComindPageNo'] = '0';
  headers['ComindLimit'] = '10';

  final response = await dio.get(
    url.toString(),
    options: Options(
      headers: headers,
    ),
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.data);
    return jsonResponse
        .map<Concept>((concept) => Concept.fromJson(concept))
        .toList();
  } else {
    throw Exception('Failed to load concepts');
  }
}

// Send the colors to the server
Future<void> sendColors(
    BuildContext context, ComindColors currentColors) async {
  final url = Uri.parse(endpoint('/api/colors/'));

  final headers = getBaseHeaders(context);

  final body = jsonEncode(<String, dynamic>{
    'primary': currentColors.primary.value.toRadixString(16),
    'secondary': currentColors.secondary.value.toRadixString(16),
    'tertiary': currentColors.tertiary.value.toRadixString(16),
    'color_scheme': currentColors.colorMethod.name,
  });

  final response = await dio.post(
    url.toString(),
    data: body,
    options: Options(
      headers: headers,
    ),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to send colors');
  }
}

// retrieve notifications
Future<List<ComindNotification>> fetchNotifications(
    BuildContext context) async {
  final url = Uri.parse(endpoint('/api/notifications/'));

  final headers = getBaseHeaders(context);
  headers['ComindPageNo'] = '0';
  headers['ComindLimit'] = '10';

  final response = await dio.get(
    url.toString(),
    options: Options(
      headers: headers,
    ),
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.data);
    return jsonResponse
        .map<ComindNotification>(
            (notification) => ComindNotification.fromJson(notification))
        .toList();
  } else {
    throw Exception('Failed to load notifications');
  }
}
