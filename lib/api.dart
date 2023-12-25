import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:comind/types/thought.dart';
import 'package:dio/dio.dart';

// Initialize Dio
final dio = Dio();

Future<List<Thought>> fetchThoughts() async {
  // TODO convert to dio
  final url =
      Uri.parse('http://nimbus.pfiffer.org:8000/api/user-thoughts/cameron/');
  final headers = {
    'ComindUsername': 'cameron',
    'ComindPageNo': '0',
  };

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    final List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((thought) => Thought.fromJson(thought)).toList();
  } else {
    throw Exception('Failed to load thoughts');
  }
}

// Method to save a quick thought that has only
// body, isPublic, and an optional parentThoughtId
Future<void> saveQuickThought(String body, bool isPublic,
    String? parentThoughtId, String? childThoughtId) async {
  // TODO convert to dio
  final url = Uri.parse('http://nimbus.pfiffer.org:8000/api/thoughts/');

  final headers = {
    'ComindUsername': 'cameron',
  };

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
    print(Thought.fromJson(jsonResponse));
  } catch (e) {
    print(e);
    print("Failed to parse response as JSON, printing response body.");
    print(response.body);
  }
}

Future<void> saveThought(Thought thought) async {
  // TODO convert to dio
  final url = Uri.parse('http://nimbus.pfiffer.org:8000/api/thoughts/');

  // If the thought has an ID, we're updating an existing thought.
  // By default empty thoughts have and ID of length 0.
  if (thought.id.isEmpty) {
    final headers = {
      'ComindUsername': 'cameron',
    };

    final body = jsonEncode(<String, dynamic>{
      'body': thought.body,
      'public': thought.isPublic,
      'synthetic': false,
      'origin': "app",
    });

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    String rawData = await response.bodyBytes.toString();
    print(rawData);

    // Try to parse the response as json
    try {
      final jsonResponse = json.decode(response.body);
      print(Thought.fromJson(jsonResponse));
    } catch (e) {
      print(e);
      print("Failed to parse response as JSON, printing response body.");
      print(response.body);
    }
  } else {
    // Otherwise, we are updating an existing thought.
    // We use the PATCH method to update the thought.
    final headers = {
      'ComindUsername': 'cameron',
      'ComindThoughtId': thought.id,
    };

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
      throw Exception('Failed to save thought');
    }

    // Try to parse the response as json
    try {
      final jsonResponse = json.decode(response.body);
      print(Thought.fromJson(jsonResponse));
    } catch (e) {
      print(e);
      print("Failed to parse response as JSON, printing response body.");
      print(response.body);
    }
  }
}

Future<void> deleteThought(String thoughtId) async {
  // TODO convert to dio
  final url = Uri.parse('http://nimbus.pfiffer.org:8000/api/thoughts/');
  final headers = {
    'ComindUsername': 'cameron',
    'ComindThoughtId': thoughtId,
  };

  final response = await http.delete(url, headers: headers);

  if (response.statusCode != 200) {
    throw Exception('Failed to delete thought');
  }
  print(response.body);

  // Try to parse the response as json
  try {
    final jsonResponse = json.decode(response.body);
    print(Thought.fromJson(jsonResponse));
  } catch (e) {
    print(e);
    print("Failed to parse response as JSON, printing response body.");
    print(response.body);
  }
}

// The basic version of authentication
// 1. Alice hashes her password.
// 2. Alice sends the hashed password to Bob.
// 3. Bob hits it with bcrypt and checks if the password is valid.
// 4. If valid, Bob sends a JWT to Alice so they can use the page.
// 5. Alice parties.

Future<bool> newUser(String username, String email, String password) async {
  // TODO convert to dio
  final url = Uri.parse('http://nimbus.pfiffer.org:8000/api/new-user/');
  final headers = {
    'ComindUsername': username,
    'ComindHashedPassword': password,
    'ComindEmail': email,
  };

  print(headers);

  final response = await http.post(url, headers: headers);

  print(response.body);

  // if (response.statusCode != 200) {
  //   return false;
  //   throw Exception('Failed to create user');
  // }

  return true;
}

Future<bool> userExists(String username) async {
  // TODO convert to dio
  final url = Uri.parse('http://nimbus.pfiffer.org:8000/api/user-exists/');
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
  // TODO convert to dio
  final url = Uri.parse('http://nimbus.pfiffer.org:8000/api/email-taken/');
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

Future<List<Thought>> searchThoughts(String query,
    {String? associatedId}) async {
  final url = Uri.parse("http://nimbus.pfiffer.org:8000/api/search");
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

  final headers = {
    'ComindUsername': 'cameron',
    "Content-Type": "application/json",
    "Content-Length": "${encodedBody.length}"
  };

  print(headers);
  print(encodedBody);

  final response = await dio.post(
    url.toString(),
    data: {
      'query': query,
      'limit': 5,
      'pageno': 0,
    },
    options: Options(
      headers: headers,
    ),
  );

  if (response.statusCode == 200 && response.data is List) {
    final jsonResponse = response.data as List;
    var result = jsonResponse.map((thought) {
      if (thought is Map<String, dynamic>) {
        return Thought.fromJson(thought);
      } else {
        throw Exception('Invalid data format');
      }
    }).toList();

    return result;
  } else {
    throw Exception('Failed to search');
  }
}
