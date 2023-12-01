class Thought {
  String title;
  String body;
  final String username;
  final String dateCreated;
  final String dateUpdated;
  final int revision;
  final String id;
  final bool isPublic;
  final bool isSynthetic;
  final String origin;
  final int accepts;
  final int rejects;
  final int rethinks;
  final int refs;

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
    );
  }

  // Make a basic thought constructor for testing
  factory Thought.basic() {
    return Thought(
      title: 'Test Thought',
      body: 'This is a test thought.',
      username: 'cameron',
      dateCreated: '2021-10-10T00:00:00.000000Z',
      dateUpdated: '2021-10-10T00:00:00.000000Z',
      revision: 0,
      id: '',
      isPublic: true,
      isSynthetic: false,
      origin: '0',
      accepts: 0,
      rejects: 0,
      rethinks: 0,
      refs: 0,
    );
  }

  // Make an empty thought constructor for testing
  factory Thought.empty() {
    return Thought(
      title: '',
      body: '',
      username: '',
      dateCreated: '',
      dateUpdated: '',
      revision: 0,
      id: '',
      isPublic: false,
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
}
