import 'package:uuid/uuid.dart';

// Generate a new UUID5
String generateUUID5() {
  var uuid = Uuid();
  return uuid.v5(Uuid.NAMESPACE_URL, 'comind.me');
}

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
  final int numLinks = 0;
  final double cosineSimilarity = 0.0;

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

  // Constructor to accept a string and return a thought
  factory Thought.fromString(String text) {
    // https://pub.dev/packages/uuid
    return Thought(
      title: "",
      body: text,
      username: 'cameron',
      dateCreated: '2021-10-10T00:00:00.000000Z',
      dateUpdated: '2021-10-10T00:00:00.000000Z',
      revision: 0,
      // Generate a UUID5
      id: generateUUID5(),
      isPublic: false,
      isSynthetic: false,
      origin: '',
      accepts: 0,
      rejects: 0,
      rethinks: 0,
      refs: 0,
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
      id: generateUUID5(),
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
    // Generate a new UUID5
    String generateUUID5() {
      var uuid = Uuid();
      return uuid.v5(Uuid.NAMESPACE_URL, 'example.com');
    }
    // https://pub.dev/packages/uuid

    return Thought(
      title: '',
      body: '',
      username: '',
      dateCreated: '',
      dateUpdated: '',
      revision: 0,
      // Generate a UUID5
      id: generateUUID5(),
      isPublic: false,
      isSynthetic: false,
      origin: '',
      accepts: 0,
      rejects: 0,
      rethinks: 0,
      refs: 0,
    );
  }

  // Lorem ipsum thought constructor for testing
  factory Thought.lorem() {
    return Thought(
      title: 'Lorem Ipsum',
      body: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
          'Sed non risus. Suspendisse lectus tortor, dignissim sit amet, '
          'adipiscing nec, ultricies sed, dolor. Cras elementum ultrices diam. '
          'Maecenas ligula massa, varius a, semper congue, euismod non, mi. '
          'Proin porttitor, orci nec nonummy molestie, enim est eleifend mi, '
          'non fermentum diam nisl sit amet erat. Duis semper. Duis arcu massa, '
          'scelerisque vitae, consequat in, pretium a, enim. Pellentesque '
          'congue. Ut in risus volutpat libero pharetra tempor. Cras vestibulum '
          'bibendum augue. Praesent egestas leo in pede. Praesent blandit odio '
          'eu enim. Pellentesque sed dui ut augue blandit sodales. Vestibulum '
          'ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia '
          'Curae; Aliquam nibh. Mauris ac mauris sed pede pellentesque fermentum. '
          'Maecenas adipiscing ante non diam sodales hendrerit.',
      username: 'cameron',
      dateCreated: '2021-10-10T00:00:00.000000Z',
      dateUpdated: '2021-10-10T00:00:00.000000Z',
      revision: 0,
      id: generateUUID5(),
      isPublic: true,
      isSynthetic: false,
      origin: '0',
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
      id: generateUUID5(),
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
}
