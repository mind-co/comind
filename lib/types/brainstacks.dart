import 'package:comind/types/thought.dart';
import 'package:flutter/material.dart';

// A container for a brainstack, which is an arbitrary
// collection of thoughts.
class Brainstack {
  final String title;
  final String description;
  final String brainstackId;
  final String? groupId; // group id for shared stacks, not currently used
  final List<String>? thoughtIds;
  final List<Thought>? thoughts;
  final Color color;

  get length => thoughtIds?.length ?? thoughts?.length ?? -1;

  const Brainstack({
    required this.title,
    required this.description,
    required this.brainstackId,
    required this.thoughtIds,
    this.color = Colors.white30,
    this.thoughts,
    this.groupId,
  });

  // From JSON method. Converts a JSON object to a Brainstack instance.
  factory Brainstack.fromJson(Map<String, dynamic> json) {
    return Brainstack(
      title: json['title'],
      description: json['description'],
      brainstackId: json['id'],
      thoughts: json['thoughts'],
      thoughtIds: (json['thought_ids'] as List<dynamic>)
          .map((id) => id.toString())
          .toList(),
    );
  }
}

// A container for a list of brainstacks.
class Brainstacks {
  final List<Brainstack> brainstacks;

  get length => brainstacks.length;

  // Index operator
  Brainstack operator [](int index) => brainstacks[index];

  const Brainstacks({required this.brainstacks});

  // removeAt method
  void removeAt(int index) {
    brainstacks.removeAt(index);
  }

  // Add method. Puts a new brainstack at the top of the list.
  void add(Brainstack brainstack) {
    brainstacks.insert(0, brainstack);
  }

  // From JSON method. The server returns
  // a JSON object with keys "stacks" and "user_id".
  factory Brainstacks.fromJson(Map<String, dynamic> json) {
    final brainstacks = json['stacks'] as List;
    return Brainstacks(
      brainstacks: brainstacks
          .map((brainstack) => Brainstack.fromJson(brainstack))
          .toList(),
    );
  }
}
