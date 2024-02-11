import 'package:comind/main_layout.dart';
import 'package:comind/markdown_display.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/providers.dart';
import 'package:comind/section.dart';
import 'package:flutter/material.dart';
import 'package:comind/types/thought.dart';
import 'package:comind/api.dart';
import 'package:provider/provider.dart';

// Pre-loads a thought. This is used when we don't have a thought yet --
// we need to fetch it from the API. If a thought is passed in, it will
// return that directly to the editor screen.
class ThoughtLoader {
  static void loadThought(BuildContext context,
      {String? id, Thought? thought}) {
    // We must have a thought or an ID by this point.
    // Just put the thought up.
    if (thought != null && id == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ThoughtEditorScreen(thought: thought)),
      );
      return;
    }

    // If we don't have a thought, fetch it from the API
    if (id != null && thought == null) {
      fetchThought(context, id).then((thought) {
        // After the operation is complete, navigate to the ThoughtEditorScreen
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ThoughtEditorScreen(thought: thought)),
        );
      });

      return;
    }

    // If we don't have a thought or an ID, throw an exception
    throw Exception(
        "ThoughtLoader failed because it didn't have a thought or an ID");
  }
}

class ThoughtEditorScreen extends StatefulWidget {
  final Thought thought;

  const ThoughtEditorScreen({required this.thought, Key? key})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ThoughtEditorScreenState createState() => _ThoughtEditorScreenState();
}

class _ThoughtEditorScreenState extends State<ThoughtEditorScreen> {
  // Child thought and parent thought vectors
  List<Thought> childThoughts = [];
  List<Thought> parentThoughts = [];
  List<Thought> superThoughts = [];

  // When this widget initializes, we need to check if we have a thought.
  // If it's null, we need to fetch it from the API.
  @override
  void initState() {
    super.initState();

    // Get children and parents
    fetchChildren(context, widget.thought.id).then((ts) {
      setState(() {
        childThoughts = ts;
      });
    });

    fetchParents(context, widget.thought.id).then((thoughts) {
      setState(() {
        parentThoughts = thoughts;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Print whether we're logged in
    return Scaffold(
        appBar: comindAppBar(context, appBarTitle("Thought view", context)),
        body: MainLayout(
            middleColumn: Column(
          children: [
            // Put the thought at the top
            MarkdownThought(thought: widget.thought),

            // ListView for children
            Section(
              text: "Children",
              waves: false,
              children: ListView.builder(
                shrinkWrap: true,
                // itemCount: Provider.of<ThoughtsProvider>(context).thoughts.length,
                itemCount: childThoughts
                    .length, // Provider.of<ThoughtsProvider>(context).thoughts.length,
                itemBuilder: (context, index) {
                  return MarkdownThought(
                    thought: childThoughts[
                        index], // Provider.of<ThoughtsProvider>(context).thoughts[index],
                    linkable: true,
                    parentThought: getTopOfMind(context)?.id,
                    // thought: Provider.of<ThoughtsProvider>(context).thoughts[index],
                  );
                },
              ),
            ),

            // ListView for parents
            Section(
              text: "Parents",
              waves: false,
              children: ListView.builder(
                shrinkWrap: true,
                // itemCount: Provider.of<ThoughtsProvider>(context).thoughts.length,
                itemCount: parentThoughts
                    .length, // Provider.of<ThoughtsProvider>(context).thoughts.length,
                itemBuilder: (context, index) {
                  return MarkdownThought(
                    thought: parentThoughts[
                        index], // Provider.of<ThoughtsProvider>(context).thoughts[index],
                    linkable: true,
                    parentThought: getTopOfMind(context)?.id,
                    // thought: Provider.of<ThoughtsProvider>(context).thoughts[index],
                  );
                },
              ),
            ),
          ],
        )));
  }
}
