import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:comind/types/thought.dart';

// Future<String> fetchThoughts() async {
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

Future<void> saveThought(Thought thought) async {
  final url = Uri.parse('http://nimbus.pfiffer.org:8000/api/thoughts/');

  // If the thought has an ID, we're updating an existing thought.
  // By default empty thoughts have and ID of length 0.
  // First l
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

    if (response.statusCode != 200) {
      throw Exception('Failed to save thought');
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
  }
}
