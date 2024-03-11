import 'package:comind/types/thought.dart';
import 'package:flutter/material.dart';

// A container for a brainstack, which is an arbitrary
// collection of thoughts.
class Brainstack {
  final String title;
  final String description;
  final String brainstackId;
  final String? groupId; // group id for shared stacks, not currently used
  final List<String> thoughtIds;
  final List<Thought>? thoughts;
  final Color color;

  get length => thoughtIds.length;

  const Brainstack({
    required this.title,
    required this.description,
    required this.brainstackId,
    required this.thoughtIds,
    this.color = Colors.white30,
    this.thoughts,
    this.groupId,
  });
}

// A container for a list of brainstacks.
class Brainstacks {
  final List<Brainstack> brainstacks;

  get length => brainstacks.length;

  // Index operator
  Brainstack operator [](int index) => brainstacks[index];

  const Brainstacks({required this.brainstacks});

  // From JSON method. The server returns
  // a JSON object with keys "stacks" and "user_id".
  factory Brainstacks.fromJson(Map<String, dynamic> json) {
    final brainstacks = json['stacks'] as List;
    return Brainstacks(
      brainstacks: brainstacks
          .map((brainstack) => Brainstack(
              title: brainstack['title'],
              description: brainstack['description'],
              brainstackId: brainstack['id'],
              thoughts: brainstack['thoughts'],
              thoughtIds: brainstack['thought_ids']))
          .toList(),
    );
  }
}
