import 'dart:convert';

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
  final String? linkedFrom;
  final String? linkedTo;

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
    this.linkedFrom = '',
    this.linkedTo = '',
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
    );
  }

  // Constructor to accept a string and return a thought. Optional parameters
  // for titles
  factory Thought.fromString(String text, String username, bool isPublic,
      {String title = ''}) {
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
    var formattedDate = formatter.format(now);

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

  // Make an empty thought constructor for testing
  factory Thought.empty() {
    // Generate a new UUID5
    String generateUUID4() {
      var uuid = Uuid();
      return uuid.v5(Uuid.NAMESPACE_URL, 'example.com');
    }

    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
    var formattedDate = formatter.format(now);

    // https://pub.dev/packages/uuid

    return Thought(
      title: '',
      body: '',
      username: '',
      dateCreated: formattedDate,
      dateUpdated: formattedDate,
      revision: 0,
      // Generate a UUID5
      id: generateUUID4(),
      isPublic: false,
      isSynthetic: false,
      origin: '',
      accepts: 0,
      rejects: 0,
      rethinks: 0,
      refs: 0,
    );
  }

  // Constructor for a brief screenplay in markdown
  factory Thought.screenplay() {
    return Thought(
      title: 'Screenplay',
      body: '**Mary**\n'
          'Tom, I simple __cannot__ believe you would do this to me.\n\n'
          '**Tom**\n'
          'I\'m sorry, Mary. I just can\'t help myself.\nI see a bat and I just have to hit it.\n\n'
          '**Mary**\n'
          'You\'re a monster, Tom. A monster.\n\n'
          '**Tom**\n'
          'I know, Mary. I know.\n\n',
      username: 'streamtest',
      dateCreated: '2021-10-10T00:00:00.000000Z',
      dateUpdated: '2021-10-10T00:00:00.000000Z',
      revision: 0,
      id: generateUUID4('streamtest'),
      isPublic: true,
      isSynthetic: false,
      origin: '0',
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
