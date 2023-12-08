import 'package:comind/comind_div.dart';
import 'package:comind/misc/comind_logo.dart';
// import 'package:comind/thought_editor_quill.dart';
import 'package:comind/types/thought.dart';
import 'package:comind/thought_editor_basic.dart';
import 'package:flutter/material.dart';
import 'package:comind/colors.dart';
import 'package:comind/api.dart';
import 'package:comind/providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
// import 'package:comind/comind_div.dart';
import 'package:comind/misc/util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as md;
// Expand button
import 'package:flutter/material.dart';

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
            dialogTheme: DialogTheme(
              backgroundColor: ComindColors.darkColorScheme.background,
            ),
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

  // List of menu bools
  List<bool> editVisibilityList = [];
  List<bool> expandedVisibilityList = [];

  // List of text controllers
  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _fetchThoughts();
  }

  // Fetch thoughts
  void _fetchThoughts() async {
    // Replace with your API call
    List<Thought> fetchedThoughts = await fetchThoughts();
    setState(() {
      thoughts = fetchedThoughts;
      editVisibilityList = List<bool>.filled(thoughts.length, false);
      expandedVisibilityList = List<bool>.filled(thoughts.length, false);

      // Make a new controller for each thought
      for (var i = 0; i < thoughts.length; i++) {
        _controllers.add(TextEditingController());
      }
    });
    loaded = true;
  }

  // Add a note
  void _addNote(BuildContext context) {
    // This function will be called when you want to add a new note.
    final newThought = Thought.basic();
    setState(() {
      thoughts.add(newThought);
      editVisibilityList.add(false);
      _controllers.add(TextEditingController());
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThoughtEditorScreen(thought: newThought),
      ),
    );
  }

  // Edit a note
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

  // Delete a note
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
          body: Column(
            children: [
              // ComindDiv(),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 600, // Set your desired maximum width here
                    child: ListView.builder(
                      itemCount: thoughts.length,
                      itemBuilder: (context, index) {
                        // Non ListTile version
                        return thoughtBox(context, index);
                      },
                    ),
                  ),
                ),
              ),
            ],
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

  Padding thoughtBox(BuildContext context, int index) {
    // Track hover region for each button
    bool hoverEdit = false;
    bool hoverDelete = false;
    bool hoverThink = false;
    bool hoverMore = false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
      child: Container(
          decoration: BoxDecoration(
              border:
                  Border.all(color: Theme.of(context).dialogBackgroundColor)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add some space
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: bodyCell(index, context),
                  ),
                ],
              ),

              // Text editing row
              Visibility(
                visible: editVisibilityList[index],
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: TextField(
                          autofocus: true,
                          controller: _controllers[index],
                          maxLines: null,
                          onTap: () {
                            // Toggle the visibility
                            setState(() {
                              editVisibilityList[index] = true;
                            });
                          },
                          cursorColor: Theme.of(context).colorScheme.onPrimary,
                          decoration: InputDecoration(
                            // hintText: "What do you think about that?",
                            // hintStyle: Theme.of(context)
                            //     .textTheme
                            //     .bodyMedium
                            //     ?.copyWith(
                            //         fontSize: 14,
                            //         color: Theme.of(context)
                            //             .colorScheme
                            //             .onPrimary
                            //             .withAlpha(64)),
                            contentPadding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                            // labelText: 'What do you think?',
                            // labelStyle: Theme.of(context)
                            //     .textTheme
                            //     .bodyMedium
                            //     ?.copyWith(
                            //         fontSize: 14,
                            //         color: Theme.of(context)
                            //             .colorScheme
                            //             .onPrimary
                            //             .withAlpha(128)),
                            enabledBorder: OutlineInputBorder(
                              // borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimary
                                    .withAlpha(32),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              // borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimary
                                    .withAlpha(64),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              ///////////////
              // Action row
              ///////////////
              Opacity(
                opacity: 0.9,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 56),
                  child: Row(
                    mainAxisAlignment: editVisibilityList[index]
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.center,
                    children: [
                      // User name
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                        child: nameAndDate(index, context),
                      ),

                      // Divider line
                      Visibility(
                        // visible: !editVisibilityList[index],
                        visible: true,
                        child: Expanded(
                          child: Container(
                            height: 2,
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withAlpha(32),
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: 1.0,
                        child: Row(
                          children: [
                            /////////////////
                            // EDIT BUTTON //
                            /////////////////
                            funButton(index, onTap: () {
                              _editNote(context,
                                  index); // Call _editNote with the context
                            }, text: "Change"),
                            ///////////////////
                            // DELETE BUTTON //
                            ///////////////////
                            if (expandedVisibilityList[index])
                              funButton(index, onTap: () async {
                                bool? shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      surfaceTintColor: Colors.black,
                                      title: const Text(
                                        'Delete thought',
                                        style: TextStyle(
                                            fontFamily: "Bungee",
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      content: const Text(
                                          'You sure you wanna delete this note? Cameron is really, really bad at making undo buttons. \n\nIf you delete this it will prolly be gone forever.'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Cancel',
                                              style: TextStyle(
                                                  fontFamily: "Bungee",
                                                  fontSize: 14)),
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('Delete',
                                              style: TextStyle(
                                                  fontFamily: "Bungee",
                                                  fontSize: 14)),
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (shouldDelete == true) {
                                  deleteThought(thoughts[index].id);
                                  _fetchThoughts();
                                }
                              }, text: "Delete"),

                            ///////////////////////
                            // Think BUTTON //
                            ///////////////////////
                            MouseRegion(
                              onEnter: (PointerEnterEvent event) {
                                setState(() {
                                  hoverThink = true;
                                });
                              },
                              onExit: (PointerExitEvent event) {
                                setState(() {
                                  hoverThink = false;
                                });
                              },
                              child: funButton(index, onTap: () {
                                setState(() {
                                  editVisibilityList[index] =
                                      !editVisibilityList[index];
                                });
                              },
                                  color: 2,
                                  text: editVisibilityList[index]
                                      ? "Close"
                                      : "Think"),
                            ),

                            ///////////////////////
                            /// SEND IT BUTTON ///
                            /// ///////////////////
                            if (editVisibilityList[index])
                              funButton(index, onTap: () async {
                                // Update the thought
                                thoughts[index].body = _controllers[index].text;
                                await saveThought(thoughts[index]);
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   SnackBar(content: Text('Note saved')),
                                // );
                                Navigator.pop(context, thoughts[index]);
                              }, color: 2, text: "Send it"),

                            ///////////////////////////
                            /// THINK BUTTON BUTTON ///
                            ///////////////////////////
                            funButton(
                              index,
                              onTap: () {
                                setState(() {
                                  expandedVisibilityList[index] =
                                      !expandedVisibilityList[index];
                                });
                              },
                              color: 3,
                              text: expandedVisibilityList[index]
                                  ? "Less"
                                  : "More",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  MouseRegion funButton(int index,
      {void Function()? onTap,
      String text = "No clue",
      bool comma = false,
      int color = 1}) {
    return MouseRegion(
      child: Material(
        // color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
              child: Row(
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontFamily: "Bungee",
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                      decorationThickness: 3,
                      decorationColor: color == 1
                          ? ComindColors.secondaryColor.withAlpha(200)
                          : color == 3
                              ? ComindColors.tertiaryColor.withAlpha(200)
                              : ComindColors.primaryColor.withAlpha(200),
                    ),
                  ),
                  if (comma)
                    const Text(",",
                        style: TextStyle(fontSize: 12, fontFamily: "Bungee")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextButton thoughtListButton(BuildContext context,
      {Widget child = const Text("[missing]"), void Function()? onPressed}) {
    return TextButton(
        style: TextButton.styleFrom(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            shape:
                BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)),
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context).colorScheme.background,
            textStyle:
                Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14)),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: child,
        ));
  }

  Padding nameAndDate(int index, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            thoughts[index].username,
            style: const TextStyle(
              fontFamily: "Bungee",
              fontSize: 12,
            ),
          ),
          Text(
            formatTimestamp(thoughts[index].dateUpdated),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }

  MarkdownBody bodyCell(int index, BuildContext context) {
    return MarkdownBody(
      // Use the thought content
      data: thoughts[index].body,
      selectable: true,

      // Set the markdown styling
      styleSheet: MarkdownStyleSheet(
        // Smush the text together

        blockquoteDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
        ),
        codeblockDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
        ),
        code: GoogleFonts.ibmPlexMono(
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        blockquote: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontFamily: "Bungee",
          fontSize: 14,
        ),
      ),
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
          width: 4.0,
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
