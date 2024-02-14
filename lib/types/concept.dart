// The concept class
class Concept {
  final String name;
  final String? id;
  final int numThoughts;
  final String? description;

  Concept(
      {required this.name,
      required this.id,
      this.numThoughts = 0,
      this.description});

  Concept.fromJson(Map<String, dynamic> json)
      : name = json['concept'],
        id = json['id'],
        numThoughts = json['n_thoughts'],
        description = json['description'];
}
