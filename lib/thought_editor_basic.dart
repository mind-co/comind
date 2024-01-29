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

// Pre-loads a thought. This is used when we don't have a thought yet --
// we need to fetch it from the API. If a thought is passed in, it will
// return that directly to the editor screen.
class ThoughtLoader {
  static Future<ThoughtEditorScreen> loadThought(BuildContext context,
      {String? id, Thought? thought}) async {
    // If we have a thought, return it directly
    if (thought != null) {
      return ThoughtEditorScreen(thought: thought);
    }

    // If we don't have a thought, fetch it from the API
    if (id != null) {
      Thought? thought = await fetchThought(context, id);
      return ThoughtEditorScreen(thought: thought);
    }

    // If we don't have a thought or an ID, throw an exception
    throw Exception("ThoughtLoader must have a thought or an ID");
  }
}

class ThoughtEditorScreen extends StatefulWidget {
  Thought thought;

  ThoughtEditorScreen({required this.thought, Key? key}) : super(key: key);

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
    // Get child and parent thoughts
    fetchChildren(context, widget.thought.id)
        .then((children) => {childThoughts.addAll(children)});

    fetchParents(context, widget.thought.id)
        .then((parents) => {parentThoughts.addAll(parents)});

    print(childThoughts);
    print(parentThoughts);
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

            //
            Text("Children", style: getTextTheme(context).titleSmall),

            // ListView for children
            ListView.builder(
                shrinkWrap: true,
                itemCount: childThoughts.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(childThoughts[index].title),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              FutureBuilder<ThoughtEditorScreen>(
                                future: ThoughtLoader.loadThought(context,
                                    id: childThoughts[index].id,
                                    thought: childThoughts[index]),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error loading thought');
                                  } else {
                                    return snapshot.data!;
                                  }
                                },
                              )));
                    },
                  );
                }),

            //
            Text("Parents", style: getTextTheme(context).titleSmall),

            // ListView for parents
            ListView.builder(
                shrinkWrap: true,
                itemCount: parentThoughts.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(parentThoughts[index].title),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              FutureBuilder<ThoughtEditorScreen>(
                                future: ThoughtLoader.loadThought(context,
                                    id: parentThoughts[index].id,
                                    thought: parentThoughts[index]),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error loading thought');
                                  } else {
                                    return snapshot.data!;
                                  }
                                },
                              )));
                    },
                  );
                }),
          ],
        )));
  }
}
