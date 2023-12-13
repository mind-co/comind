import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:comind/comind_div.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as md;
// Expand button

// Firebase imports
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:comind/firebase_options.dart';

// Comind imports
import 'package:comind/colors.dart';
import 'package:comind/api.dart';
import 'package:comind/providers.dart';
// import 'package:comind/comind_div.dart';
import 'package:comind/text_button.dart';
import 'package:comind/misc/comind_logo.dart';
import 'package:comind/types/thought.dart';
import 'package:comind/thought_editor_basic.dart';
// import 'package:comind/thought_editor_super.dart';
// import 'package:comind/thought_editor_quill.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
          home: const LoginScreen(),
          // home: ThoughtEditorScreen(
          //   thought: Thought.basic(),
          // ),
          // home: const ThoughtListScreen(),
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ComindColors().colorScheme,
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
  List<bool> verbBarHoverList = [];

  // Menu bools for the top bar
  bool editorVisible = false;
  bool moreMenuExpanded = false;

  // List of text controllers
  List<TextEditingController> _controllers = [];
  TextEditingController _primaryController = TextEditingController();

  // Set up public/private writing mode
  bool publicMode = false;
  bool searchMode = false;

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
      verbBarHoverList = List<bool>.filled(thoughts.length, false);

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
      expandedVisibilityList.add(false);
      verbBarHoverList.add(false);
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
    return LayoutBuilder(
      builder: (context, constraints) {
        var smallScreen = constraints.maxWidth < 600;
        if (thoughts.isNotEmpty) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            appBar: comindAppBar(context),
            drawer: Drawer(
              backgroundColor: Theme.of(context).colorScheme.background,
              child: const Nav(),
            ),
            body: Stack(
              children: [
                // Center column
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left column
                    // Nav bar
                    // if (constraints.maxWidth > 600)
                    //   SizedBox(
                    //     width: constraints.maxWidth * 0.2 - 10,
                    //     child: const Nav(),
                    //   ),
                    // center column
                    Column(
                      children: [
                        // DEBUG FOR PIXEL WIDTH PIXEL HEIGHT
                        // Text(
                        //   "${constraints.maxWidth} wide, ${constraints.minHeight} tall",
                        // ),

                        // Main text field
                        Container(
                          width: constraints.maxWidth > 600
                              ? 600
                              : constraints.maxWidth,
                          child: Padding(
                            padding: constraints.maxWidth > 600
                                ? const EdgeInsets.fromLTRB(0, 16, 0, 16)
                                : const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceVariant
                                  .withAlpha(128),
                              child: TextField(
                                cursorWidth: 10,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontSize: 16),
                                autofocus: false,
                                controller: _primaryController,
                                maxLines: null,
                                onTap: () {
                                  // Toggle the visibility
                                  // setState(() {
                                  //   editVisibilityList[0] = true;
                                  // });
                                },
                                cursorColor:
                                    Theme.of(context).colorScheme.primary,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withAlpha(200),
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    minWidth: 0,
                                    minHeight: 0,
                                  ),
                                  prefix: searchMode
                                      ? Text("search ",
                                          style: TextStyle(
                                            fontFamily: "Bungee",
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground
                                                .withAlpha(164),
                                          ))
                                      : null,
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withAlpha(200)),
                                  contentPadding:
                                      EdgeInsets.fromLTRB(4, 4, 4, 4),
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
                        ),

                        ///////////////////////
                        // Verb bar for top editor (hehe vebs) //
                        ///////////////////////
                        SizedBox(
                          width: constraints.maxWidth > 600
                              ? 600
                              : constraints.maxWidth,
                          child: Opacity(
                            opacity: 1,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
                              child: Row(
                                mainAxisAlignment: moreMenuExpanded
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.center,
                                children: [
                                  // User name
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(4, 0, 4, 0),
                                    child: Column(
                                      children: [
                                        ComindTextButton(
                                          onPressed: () {
                                            setState(() {
                                              publicMode = !publicMode;
                                            });
                                          },
                                          text: publicMode
                                              ? "Public mode"
                                              : "Private mode",
                                          opacity: 1,
                                          opacityOnHover: 1,
                                          colorIndex: publicMode ? 1 : 3,
                                          textStyle: const TextStyle(
                                              fontFamily: "Bungee",
                                              fontSize: 18),
                                        ),

                                        // clock
                                        if (constraints.maxWidth > 600)
                                          Opacity(
                                            opacity: 0.5,
                                            child: Text(
                                              // Show current time in locale format
                                              // DateFormat.yMMMd().format(
                                              //         DateTime.now()) +
                                              // " at " +
                                              DateFormat.jm().format(
                                                DateTime.now(),
                                              ),

                                              style: const TextStyle(
                                                  // fontFamily: "Bungee",
                                                  fontSize: 12),
                                            ),
                                          ),
                                      ],
                                    ),
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

                                  //////////////////////////
                                  /// whether it's public or not
                                  /////

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

                                  //////////////////////////
                                  /// VERB ROW BUTTONS ///
                                  //////////////////////////
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: Opacity(
                                      opacity: 1.0,
                                      child: Row(
                                        children: [
                                          //////////////////////////////
                                          /// SEARCH BUTTON
                                          /// ///////////////////////////
                                          ComindTextButton(
                                              text: "Search",
                                              onPressed: () {
                                                setState(() {
                                                  searchMode = !searchMode;
                                                });
                                              },
                                              colorIndex: 1,
                                              opacity: 1.0,
                                              textStyle: const TextStyle(
                                                  fontFamily: "Bungee",
                                                  fontSize: 16)),

                                          /////////////////////////////////
                                          /// REFRESH BUTTON
                                          ///////////////////////////
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ComindTextButton(
                                                text: "Refresh",
                                                onPressed: () {
                                                  _fetchThoughts();
                                                },
                                                colorIndex: 3,
                                                opacity: 1.0,
                                                textStyle: const TextStyle(
                                                    fontFamily: "Bungee",
                                                    fontSize: 16)),
                                          ),

                                          ///////////////////////
                                          // Think BUTTON, main text field
                                          ///////////////////////
                                          Padding(
                                            padding: constraints.maxWidth > 800
                                                ? const EdgeInsets.fromLTRB(
                                                    0, 0, 0, 0)
                                                : const EdgeInsets.fromLTRB(
                                                    0, 0, 16, 0),
                                            // const EdgeInsets.all(8.0),
                                            child: ComindTextButton(
                                                opacity: 1,
                                                text: "Think",
                                                onPressed: () {
                                                  setState(() {
                                                    // Save a quick thought for the main text field
                                                    saveQuickThought(
                                                        _primaryController.text,
                                                        publicMode,
                                                        null);
                                                  });
                                                  // Clear the text field
                                                  _primaryController.clear();

                                                  // Refresh the thoughts
                                                  _fetchThoughts();
                                                },
                                                colorIndex: 1),
                                          ),

                                          ///////////////////////////
                                          /// MORE BUTTON ///
                                          ///////////////////////////
                                          // funButton(
                                          //   -1,
                                          //   onTap: () {
                                          //     setState(() {
                                          //       moreMenuExpanded =
                                          //           !moreMenuExpanded;
                                          //     });
                                          //   },
                                          //   size: buttonSize(constraints),
                                          //   color: 3,
                                          //   text: moreMenuExpanded
                                          //       ? "Less"
                                          //       : "More",
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        /// THOUGHTS LIST VIEW / STREAM OF CONCIOUSNESS
                        ///////////////////////////
                        Expanded(
                          // Thought list view
                          child: Column(
                            children: [
                              Expanded(
                                child: Center(
                                  child: SizedBox(
                                    width: constraints.maxWidth > 600
                                        ? 600
                                        : constraints.maxWidth > 600
                                            ? 600
                                            : constraints.maxWidth,
                                    child: ListView.builder(
                                      itemCount: thoughts.length,
                                      itemBuilder: (context, index) {
                                        return thoughtBox(context, index,
                                            constraints: constraints);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    ////////////////
                    // Right column
                    ////////////////
                    // if (constraints.maxWidth > 600)
                    //   SizedBox(
                    //     width: constraints.maxWidth * 0.2 - 10,
                    //     child: Column(
                    //       children: [
                    //         // Blubble bar thing (not sure what to call it)
                    //         // Anyway it's just for testing rn to fill hte column
                    //         Expanded(
                    //           // color: Theme.of(context).colorScheme.background,
                    //           child: Padding(
                    //             padding: const EdgeInsets.all(16.0),
                    //             child: InkWell(
                    //               child: Container(
                    //                 height: 100,
                    //                 // Make it a rounded rectangle
                    //                 decoration: BoxDecoration(
                    //                   borderRadius: BorderRadius.circular(42),
                    //                   // color: Theme.of(context)
                    //                   //     .colorScheme
                    //                   //     .surface
                    //                   //     .withAlpha(32),
                    //                 ),

                    //                 // color: BoxDecoration(
                    //                 //     child: Theme.of(context)
                    //                 //         .colorScheme
                    //                 //         .surface
                    //                 //         .withAlpha(32)),
                    //                 child: const Column(
                    //                   children: [
                    //                     Text(
                    //                       "Blubble bar thing",
                    //                       style: TextStyle(
                    //                           fontFamily: "Bungee",
                    //                           fontSize: 14),
                    //                     )
                    //                   ],
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                  ],
                ),
              ],
            ),
          );
        }
        // Add your else condition here if needed
        return Container(); // Return an empty container if thoughts is empty
      },
    );
  }

  double buttonSize(BoxConstraints constraints) {
    return constraints.maxWidth > 600 ? 16 : 14;
  }

  Padding thoughtBox(BuildContext context, int index,
      {required BoxConstraints constraints}) {
    return Padding(
      padding: constraints.maxWidth > 600
          ? const EdgeInsets.fromLTRB(0, 0, 0, 32)
          : const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Container(
          decoration: BoxDecoration(
              border:
                  Border.all(color: Theme.of(context).dialogBackgroundColor)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show name & date
              nameAndDate(index, context, compact: constraints.maxWidth < 600),

              // Thought body
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: bodyCell(index, context)),
                ],
              ),

              // Text editing row, thought box
              Visibility(
                visible: editVisibilityList[index],
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 2, 0, 4),
                        child: TextField(
                          autofocus: false,
                          controller: _controllers[index],
                          maxLines: null,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontSize: 16),
                          cursorColor: Theme.of(context).colorScheme.onPrimary,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.fromLTRB(8, 8, 8, 8),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimary
                                    .withAlpha(32),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
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

              ///////////////////////
              // Verbs (hehe vebs) //
              ///////////////////////
              MouseRegion(
                onEnter: (event) {
                  setState(() {
                    verbBarHoverList[index] = true;
                  });
                },
                onExit: (event) {
                  setState(() {
                    verbBarHoverList[index] = false;
                  });
                },
                child: Opacity(
                  opacity: verbBarHoverList[index] ? 1.0 : 0.5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                    child: Row(
                      mainAxisAlignment: editVisibilityList[index]
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.center,
                      children: [
                        // User name
                        // Padding(
                        //     padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                        //     child: constraints.maxWidth > 600
                        //         ? nameAndDate(index, context)
                        //         : nameAndDate(index, context, compact: true)),

                        // Divider line
                        // Visibility(
                        //   // visible: !editVisibilityList[index],
                        //   visible: true,
                        //   child: Expanded(
                        //     child: Container(
                        //       height: 2,
                        //       color: Theme.of(context)
                        //           .colorScheme
                        //           .onBackground
                        //           .withAlpha(32),
                        //     ),
                        //   ),
                        // ),

                        // Divider line
                        // Visibility(
                        //   // visible: !editVisibilityList[index],
                        //   visible: true,
                        //   child: Expanded(
                        //     child: Container(
                        //       height: 2,
                        //       color: Theme.of(context)
                        //           .colorScheme
                        //           .onBackground
                        //           .withAlpha(32),
                        //     ),
                        //   ),
                        // ),

                        //////////////////////////
                        /// VERB ROW BUTTONS ///
                        //////////////////////////
                        thoughtBoxVerbBar(context, index),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Expanded thoughtBoxVerbBar(BuildContext context, int index) {
    var smallScreen = MediaQuery.of(context).size.width < 600;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Opacity(
          opacity: 1,
          child: Row(
            children: [
              /////////////////
              // EDIT BUTTON //
              /////////////////
              // IconButton.outlined(
              //   onPressed: () {
              //     setState(() {
              //       editVisibilityList[index] = !editVisibilityList[index];
              //     });
              //   },
              //   icon: Icon(
              //     Icons.edit,
              //     color: Theme.of(context).colorScheme.onPrimary,
              //   ),
              //   iconSize: 16,
              //   splashRadius: 16,
              //   padding: const EdgeInsets.all(8),
              //   constraints: const BoxConstraints(),
              //   color: Theme.of(context).colorScheme.onPrimary,
              //   hoverColor: Theme.of(context).colorScheme.primary,
              //   focusColor: Theme.of(context).colorScheme.onPrimary,
              //   highlightColor: Theme.of(context).colorScheme.onPrimary,
              //   disabledColor: Theme.of(context).colorScheme.onPrimary,
              //   // shape: RoundedRectangleBorder(
              //   //   borderRadius: BorderRadius.circular(10),
              //   // ),
              // ),
              ComindTextButton(
                  text: "Edit",
                  onPressed: () {
                    _editNote(
                        context, index); // Call _editNote with the context
                  },
                  colorIndex: 1,
                  // lineOnly: !verbBarHoverList[index],
                  opacity: 0.8,
                  textStyle:
                      const TextStyle(fontFamily: "Bungee", fontSize: 16)),

              ///////////////////
              // DELETE BUTTON //
              ///////////////////
              // if (expandedVisibilityList[index])

              ComindTextButton(
                  // lineOnly: !verbBarHoverList[index],
                  colorIndex: 3,
                  onPressed: () async {
                    bool? shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor:
                              Theme.of(context).colorScheme.background,
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
                            ComindTextButton(
                              text: "Cancel",
                              colorIndex: 1,
                              textStyle: const TextStyle(
                                  fontFamily: "Bungee", fontSize: 14),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                            ComindTextButton(
                              text: "Delete",
                              colorIndex: 2,
                              textStyle: const TextStyle(
                                  fontFamily: "Bungee", fontSize: 14),
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
                  },
                  text: "Delete",
                  opacity: 0.8,
                  textStyle:
                      const TextStyle(fontFamily: "Bungee", fontSize: 16)),

              ///////////////////////
              // Think BUTTON //
              ///////////////////////
              ComindTextButton(
                  text: "Think",
                  // lineOnly: !verbBarHoverList[index],
                  opacity: 0.8,
                  colorIndex: 2,
                  textStyle:
                      const TextStyle(fontFamily: "Bungee", fontSize: 16),
                  onPressed: () {
                    // Save the parent thought if the text has length > 0
                    if (_controllers[index].text.isNotEmpty) {
                      // Send the thought
                      saveQuickThought(_controllers[index].text, publicMode,
                          thoughts[index].id);

                      // Clear the text field
                      _controllers[index].clear();

                      // Refresh the thoughts
                      _fetchThoughts();
                    }
                  }),

              ///////////////////////////
              /// THINK BUTTON BUTTON ///
              ///////////////////////////
              ComindTextButton(
                  colorIndex: 1,
                  // lineOnly: !verbBarHoverList[index],
                  onPressed: () {
                    setState(() {
                      expandedVisibilityList[index] =
                          !expandedVisibilityList[index];
                    });
                  },
                  opacity: 0.8,
                  text: expandedVisibilityList[index] ? "Less" : "More",
                  textStyle: TextStyle(fontFamily: "Bungee", fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  // the fun hyperlink button
  Material funButton(int index,
      {void Function()? onTap,
      String text = "No clue",
      bool comma = false,
      int color = 1,
      bool hovering = false,
      double size = 16,
      bool underline = true}) {
    return Material(
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
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: color == 1
                            ? ComindColors().secondaryColor.withAlpha(200)
                            : color == 3
                                ? ComindColors().tertiaryColor.withAlpha(200)
                                : color == 0
                                    ? Colors.transparent
                                    : ComindColors()
                                        .primaryColor
                                        .withAlpha(200),
                        width: hovering ? 5.0 : 2.5,
                      ),
                    ),
                  ),
                  child: Text(text,
                      style: TextStyle(
                        fontFamily: "Bungee",
                        fontSize: size,
                      )),
                ),
                if (comma)
                  const Text(",",
                      style: TextStyle(fontSize: 12, fontFamily: "Bungee")),
              ],
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

  Padding nameAndDate(int index, BuildContext context, {bool compact = false}) {
    return Padding(
      padding: compact
          ? const EdgeInsets.fromLTRB(0, 0, 0, 8)
          : const EdgeInsets.fromLTRB(0, 0, 12, 0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              thoughts[index].username,
              style: const TextStyle(
                fontFamily: "Bungee",
                fontSize: 12,
              ),
            ),
            VerticalDivider(
              color: Theme.of(context).colorScheme.onBackground.withAlpha(64),
              thickness: 2,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
              child: Opacity(
                opacity: 0.8,
                child: Text(
                  thoughts[index].isPublic ? "Public" : "Private",
                  style: TextStyle(
                    fontFamily: "Bungee",
                    fontSize: 12,
                    decorationThickness: 2,
                    decoration: TextDecoration.underline,
                    // decorationColor: ComindColors().primaryColor,
                    decorationColor: thoughts[index].isPublic
                        ? ComindColors().secondaryColor
                        : ComindColors().tertiaryColor,
                  ),
                ),
              ),
            ),
            // Divider line
            Visibility(
              // visible: !editVisibilityList[index],
              visible: true,
              child: Expanded(
                child: Container(
                  height: 2,
                  color:
                      Theme.of(context).colorScheme.onBackground.withAlpha(32),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: Opacity(
                opacity: 0.5,
                child: Text(
                  formatTimestamp(thoughts[index].dateUpdated),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                ),
              ),
            ),
          ],
        ),
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
      extensionSet: md.ExtensionSet(
        md.ExtensionSet.gitHubFlavored.blockSyntaxes,
        <md.InlineSyntax>[
          md.EmojiSyntax(),
          ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
        ],
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

    return FloatingActionButton.large(
      // Center it
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
      splashColor: ComindColors().secondaryColor,
      backgroundColor: Theme.of(context).colorScheme.background,
      child: funButton(-1 /*index*/, onTap: () {
        // _addNote(context); // Call _addNote with the context
      }, text: "New", underline: false),
    );
  }
}

class Nav extends StatelessWidget {
  const Nav({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blubble bar thing (not sure what to call it)
          // Anyway it's just for testing rn to fill hte column
          Expanded(
            // color: Theme.of(context).colorScheme.background,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                child: Container(
                  height: 100,
                  // Make it a rounded rectangle
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(42),
                    color: Theme.of(context).colorScheme.background,
                  ),

                  // color: BoxDecoration(
                  //     child: Theme.of(context)
                  //         .colorScheme
                  //         .surface
                  //         .withAlpha(32)),
                  child: Material(
                    // color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                          child: Opacity(
                            opacity: 1.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ///////////////
                                ///YOU ARE HERE
                                /// ///////////
                                ComindTextButton(
                                  text: "You",
                                  onPressed: () {
                                    // _addNote(context); // Call _addNote with the context
                                  },
                                ),

                                ///////////////
                                /// Spacing ///
                                /// ///////////
                                const SizedBox(height: 16),

                                ///////////////
                                ///ABOUT THIS //
                                /// ///////////
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ComindTextButton(
                                      text: "About",
                                      colorIndex: 1,
                                      onPressed: () {
                                        // Navigate to the about page
                                      },
                                    ),

                                    ///////////////
                                    ///SETTINGS ///
                                    /// ///////////
                                    ComindTextButton(
                                      text: "Settings",
                                      onPressed: () {
                                        // Navigate to the settings page
                                      },
                                    ),

                                    ///////////////
                                    ///LOGOUT ////
                                    /// ///////////
                                    ComindTextButton(
                                        text: "Logout", onPressed: () {}),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
