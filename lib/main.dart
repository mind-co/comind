import 'package:comind/misc/comind_logo.dart';
// import 'package:comind/thought_editor_quill.dart';
import 'package:comind/types/thought.dart';
import 'package:comind/thought_editor_basic.dart';
import 'package:flutter/material.dart';
import 'package:comind/colors.dart';
import 'package:comind/api.dart';
import 'package:comind/providers.dart';
import 'package:provider/provider.dart';
import 'package:comind/comind_div.dart';
import 'package:comind/misc/util.dart';

void main() {
  List<Thought> thoughts = [];

  runApp(ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
    child: ComindApp(
      thoughts: thoughts,
    ),
  ));
}

class ComindApp extends StatelessWidget {
  List<Thought> thoughts = [];

  ComindApp({required this.thoughts, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          home: ThoughtListScreen(),
          theme: ThemeData(
            colorScheme: ComindColors.colorScheme,
          ),
          darkTheme: ThemeData(
            colorScheme: ComindColors.darkColorScheme,
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
  ThoughtListScreen({Key? key}) : super(key: key);

  @override
  _ThoughtListScreenState createState() => _ThoughtListScreenState();
}

class _ThoughtListScreenState extends State<ThoughtListScreen> {
  List<Thought> thoughts = [];
  bool loaded = false;

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
            body: ComindIsLoading(),
          ),
        ),
      );
    }

    // Check if we have thoughts, make a widget for each one
    if (thoughts.isNotEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        // backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            // backgroundColor: Colors.white,
            title: ComindLogo(key: UniqueKey()),
            centerTitle: true,
            // elevation: 100,
            scrolledUnderElevation: 0,
            // Add toolbar
            toolbarHeight: 100,
            actions: [
              // Add dark mode toggle
              IconButton(
                icon: const Icon(Icons.dark_mode),
                onPressed: () {
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme();
                },
              ),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(4.0),
              child: ComindDiv(),
            )),
        body: Scaffold(
          body: Center(
            child: Container(
              width: 600, // Set your desired maximum width here
              child: ListView.builder(
                itemCount: thoughts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            thoughts[index].username,
                            style: const TextStyle(fontFamily: "Bungee"),
                          ),
                          Text(
                            formatTimestamp(thoughts[index].dateCreated),
                            style: const TextStyle(fontFamily: "monospace"),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text(
                      thoughts[index].body,
                      // style: TextStyle(fontWeight: FontWeight.w300),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ThoughtEditorScreen(
                            thought: thoughts[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _addNote(context); // Call _addNote with the context
          },
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
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
          body: const Center(
            child: Text(
              'You don\'t have any thoughts yet.\n\nHit that + button down there to think something.',
              style: TextStyle(
                // fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNote(context); // Call _addNote with the context
        },
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}
