import 'package:comind/api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// Generate a new UUID5
String generateUUID4(String username) {
  const uuid = Uuid();
  return uuid.v4();
}

class Thought {
  String title;
  String body;
  final String username;
  final String dateCreated;
  final String dateUpdated;
  final int revision;
  final String id;
  bool isPublic;
  final bool isSynthetic;
  final String origin;
  final int accepts;
  final int rejects;
  final int rethinks;
  final int refs;
  final int? numLinks;
  final double? cosineSimilarity;
  final String? associatedId;
  final bool? linkedFrom;
  final bool? linkedTo;
  final String? relevance; // Used to track why a thought is relevant

  Thought({
    required this.title,
    required this.body,
    required this.username,
    required this.dateCreated,
    required this.dateUpdated,
    required this.revision,
    required this.id,
    required this.isPublic,
    required this.isSynthetic,
    required this.origin,
    required this.accepts,
    required this.rejects,
    required this.rethinks,
    required this.refs,
    this.numLinks = 0,
    this.cosineSimilarity = 0.0,
    this.associatedId = '',
    this.linkedFrom = false,
    this.linkedTo = false,
    this.relevance = '',
  });

  factory Thought.fromJson(Map<String, dynamic> json) {
    return Thought(
        title: json['title'],
        body: json['body'],
        username: json['username'],
        dateCreated: json['date_created'],
        dateUpdated: json['date_updated'],
        revision: json['revision'],
        id: json['id'],
        isPublic: json['public'],
        isSynthetic: json['synthetic'],
        origin: json['origin'],
        accepts: json['accepts'],
        rejects: json['rejects'],
        rethinks: json['rethinks'],
        refs: json['refs'],
        numLinks: json['numlinks'],
        cosineSimilarity: json['cosinesimilarity'],
        associatedId: json['associated_id'],
        linkedFrom: json['linked_to'],
        linkedTo: json['linked_from'],
        relevance: json['relevance']
        //
        );
  }

  // Constructor to accept a string and return a thought. Optional parameters
  // for titles
  factory Thought.fromString(String text, String username, bool isPublic,
      {String title = ''}) {
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
    var formattedDate = formatter.format(now);

    // If the title is empty, check if there's a markdown header in the first line
    // after trimming leading and trailing whitespace.
    if (title.isEmpty) {
      var lines = text.split('\n');
      if (lines[0].trim().startsWith('# ')) {
        title = lines[0].trim().substring(2);
        text = lines.sublist(1).join('\n');
      }
    }

    // https://pub.dev/packages/uuid
    return Thought(
      title: title,
      body: text,
      username: username,
      dateCreated: formattedDate,
      dateUpdated: formattedDate,
      revision: 0,
      // Generate a UUID5
      id: generateUUID4(username),
      isPublic: isPublic,
      isSynthetic: false,
      origin: '',
      accepts: 0,
      rejects: 0,
      rethinks: 0,
      refs: 0,
    );
  }

  // Setter function for body
  void setBody(String body) {
    this.body = body;
  }

  // Toggle public
  void togglePublic(BuildContext context) {
    isPublic = !isPublic;

    // Send a request to the server to update the thought
    setPublic(context, id, isPublic);
  }
}
