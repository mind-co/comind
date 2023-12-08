import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:comind/types/thought.dart';

Future<List<Thought>> fetchThoughts() async {
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
Future<void> saveQuickThought(
    String body, bool isPublic, String? parentThoughtId) async {
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
