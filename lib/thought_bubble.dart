import 'package:comind/types/thought.dart';
import 'package:flutter/material.dart';

class ThoughtDisplay extends StatefulWidget {
  // Accept a thought
  final Thought thought;

  const ThoughtDisplay({super.key, required this.thought});

  @override
  ThoughtDisplayState createState() => ThoughtDisplayState();
}

class ThoughtDisplayState extends State<ThoughtDisplay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Thought'),
    );
  }
}
