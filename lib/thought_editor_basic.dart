import 'package:comind/main_layout.dart';
import 'package:comind/markdown_display.dart';
import 'package:comind/misc/loading.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/providers.dart';
import 'package:comind/section.dart';
import 'package:flutter/material.dart';
import 'package:comind/types/thought.dart';
import 'package:comind/api.dart';
import 'package:provider/provider.dart';

// FIXME remove this ignore
// ignore: must_be_immutable
class ThoughtEditorScreen extends StatefulWidget {
  Thought? thought;
  final String? id;

  ThoughtEditorScreen({this.thought, this.id, Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ThoughtEditorScreenState createState() => _ThoughtEditorScreenState();
}

class _ThoughtEditorScreenState extends State<ThoughtEditorScreen> {
  // Child thought and parent thought vectors
  List<Thought> childThoughts = [];
  List<Thought> parentThoughts = [];

  // When this widget initializes, we need to check if we have a thought.
  // If it's null, we need to fetch it from the API.
  @override
  void initState() {
    super.initState();

    if (widget.thought == null) {
      if (widget.id == null) {
        throw Exception("ThoughtEditorScreen must have a thought or an ID");
      }
      // Fetch the thought from the API
      fetchThought(context, widget.id!).then((thought) {
        setState(() {
          print("Loaded shit");
          widget.thought = thought;
        });
      });

      // Get child and parent thoughts
      fetchChildren(context, widget.id!).then((value) => {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Print whether we're logged in
    print(Provider.of<AuthProvider>(context).isLoggedIn);

    // If we don't have a thought yet, show a loading screen
    if (widget.thought == null) {
      return const Scaffold(appBar: null, body: Loading(text: "Thought"));
    }

    return Scaffold(
        appBar: comindAppBar(context),
        body: MainLayout(
            middleColumn: Column(
          children: [
            // Put the thought at the top
            MarkdownThought(thought: widget.thought!),
          ],
        )));
  }
}
