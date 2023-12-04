import 'package:comind/misc/comind_logo.dart';
// import 'package:comind/thought_editor_quill.dart';
import 'package:comind/types/thought.dart';
import 'package:comind/thought_editor_basic.dart';
import 'package:flutter/material.dart';
import 'package:comind/colors.dart';
import 'package:comind/api.dart';
import 'package:comind/providers.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
// import 'package:comind/comind_div.dart';
import 'package:comind/misc/util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as md;

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
    child: const ComindApp(),
  ));
}

class ComindApp extends StatelessWidget {
  const ComindApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          home: const ThoughtListScreen(),
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ComindColors.colorScheme,
            textTheme: ComindColors.textTheme,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ComindColors.darkColorScheme,
            textTheme: ComindColors.textTheme,
          ),
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light, // This line is changed
        );
      },
    );
  }
}

class ThoughtListScreen extends StatefulWidget {
  const ThoughtListScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ThoughtListScreenState createState() => _ThoughtListScreenState();
}

class _ThoughtListScreenState extends State<ThoughtListScreen> {
  List<Thought> thoughts = [];
  bool loaded = true;

  @override
  void initState() {
    super.initState();
    _fetchThoughts();
  }

  void _fetchThoughts() async {
    // Replace with your API call
    List<Thought> fetchedThoughts = await fetchThoughts();
    setState(() {
      thoughts = fetchedThoughts;
    });
    loaded = true;
  }

  void _addNote(BuildContext context) {
    // This function will be called when you want to add a new note.
    final newThought = Thought.basic();
    setState(() {
      thoughts.add(newThought);
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThoughtEditorScreen(thought: newThought),
      ),
    );
  }

  void _editNote(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThoughtEditorScreen(thought: thoughts[index]),
      ),
    ).then((updatedThought) {
      if (updatedThought != null) {
        setState(() {
          thoughts[index] = updatedThought;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're still loading
    if (!loaded) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          // title: ComindLogo(key: UniqueKey()),
          // elevation: 0,
          // Add toolbar
        ),
        body: Center(
          // Set background color
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: const ComindIsLoading(),
          ),
        ),
      );
    }

    // Check if we have thoughts, make a widget for each one
    if (thoughts.isNotEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        // backgroundColor: Theme.of(context).colorScheme.background,
        appBar: comindAppBar(context),
        body: Scaffold(
          // drawer: Drawer(
          //   child: Text("abc"),
          // ),
          body: Center(
            child: SizedBox(
              width: 600, // Set your desired maximum width here
              child: ListView.builder(
                itemCount: thoughts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          thoughts[index].username,
                          style: const TextStyle(
                            fontFamily: "Bungee",
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          formatTimestamp(thoughts[index].dateUpdated),
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MarkdownBody(data: thoughts[index].body),
                        // Text(
                        //   thoughts[index].body,
                        //   style: Theme.of(context).textTheme.bodyMedium,
                        // ),
                        const Divider()
                      ],
                    ),
                    onTap: () {
                      _editNote(context, index);
                    },
                  );
                },
              ),
            ),
          ),
        ),
        floatingActionButton: _newNoteButton(context),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: ComindLogo(key: UniqueKey()),
        centerTitle: true,
        // elevation: 0,
        // Add toolbar
        toolbarHeight: 100,
        actions: [
          // Add dark mode toggle
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () {
              // Toggle the brightness
            },
          ),
        ],
      ),
      body: Center(
        // Set background color
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Center(
            child: Text(
                'You don\'t have any thoughts yet.\n\nHit that + button down there to think something.',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
      ),
      // floatingActionButtonLocation: ,
      persistentFooterButtons: const [],
      floatingActionButton: _newNoteButton(context),
    );
  }

  FloatingActionButton _newNoteButton(BuildContext context) {
    // Iconbutton approach
    // return FloatingActionButton.extended(
    //     onPressed: () {
    //       // _addNote(context); // Call _addNote with the context
    //     },
    //     label: Text("New"));

    // return FloatingActionButton.large(
    //   onPressed: () {
    //     // _addNote(context); // Call _addNote with the context
    //   },

    // );

    return FloatingActionButton(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.onPrimary,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(30.0),
      ),
      onPressed: () {
        _addNote(context); // Call _addNote with the context
      },
      splashColor: ComindColors.secondaryColor,
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Icon(
        Icons.circle_outlined,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
