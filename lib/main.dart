import 'dart:math';

import 'package:comind/color_picker.dart';
import 'package:comind/markdown_display.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_markdown/flutter_markdown.dart'; // TODO Probably actually use this at some point instead of MarkdownBody
import 'package:provider/provider.dart';
// import 'package:comind/comind_div.dart';
// Expand button

// Comind imports
import 'package:comind/input_field.dart';
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

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => ComindColorsNotifier(),
    child: ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const ComindApp(),
    ),
  ));
}

class ComindApp extends StatelessWidget {
  const ComindApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ComindColorsNotifier>(
      builder: (context, authProvider, colorNotifier, child) {
        return MaterialApp(
          // home: const LoginScreen(),
          // home: ThoughtEditorScreen(
          //   thought: Thought.basic(),
          // ),
          home: const ThoughtListScreen(),
          // home: StreamScreen(),
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: colorNotifier.currentColors.colorScheme,
            textTheme: colorNotifier.currentColors.textTheme,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            // colorScheme: ComindColors.darkColorScheme,
            colorScheme: colorNotifier.currentColors.colorScheme,
            textTheme: colorNotifier.currentColors.textTheme,
            dialogTheme: DialogTheme(
              backgroundColor: colorNotifier.currentColors.colorScheme.surface,
            ),
          ),
          debugShowCheckedModeBanner: false,
          themeMode: colorNotifier.darkMode
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

  // Make a new thought and go to the text editor
  void _addNote(BuildContext context) {
    // This function will be called when you want to add a new note.
    final newThought = Thought.fromString(
        "",
        Provider.of<AuthProvider>(context, listen: false).username,
        Provider.of<ComindColorsNotifier>(context).publicMode);

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

  // Add a note
  // void _sendThought(BuildContext context, String body,
  //     {String? parentId, String? childId}) async {
  //   // This function will be called when you want to add a new note.
  //   final newThought =
  //       await saveQuickThought(body, publicMode, parentId, childId);

  //   setState(() {
  //     thoughts.add(newThought);
  //     editVisibilityList.add(false);
  //     expandedVisibilityList.add(false);
  //     verbBarHoverList.add(false);
  //     _controllers.add(TextEditingController());
  //   });

  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ThoughtEditorScreen(thought: newThought),
  //     ),
  //   );
  // }

  // Fetch concepts
  void _fetchConcepts(BuildContext context) {
    // This function will be called when the page loads.
    setState(() {
      // fetchConcepts();
    });
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => const ThoughtEditorScreen(thought: newThought),
    //   ),
    // );
  }

  // Delete a note
  @override
  Widget build(BuildContext context) {
    bool publicMode = Provider.of<ComindColorsNotifier>(context).publicMode;

    // Check if we're still loading
    if (!loaded) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor:
              Provider.of<ComindColorsNotifier>(context).colorScheme.background,
          // title: ComindLogo(key: UniqueKey()),
          // elevation: 0,
          // Add toolbar
        ),
        body: Center(
          // Set background color
          child: Scaffold(
            backgroundColor: Provider.of<ComindColorsNotifier>(context)
                .colorScheme
                .background,
            body: const ComindIsLoading(),
          ),
        ),
      );
    }

    // Check if we have thoughts, make a widget for each one
    return LayoutBuilder(
      builder: (context, constraints) {
        if (thoughts.isNotEmpty) {
          const edgeInsets = const EdgeInsets.fromLTRB(8, 2, 8, 2);
          return Scaffold(
            backgroundColor: Provider.of<ComindColorsNotifier>(context)
                .colorScheme
                .background,
            appBar: comindAppBar(context),
            drawer: Drawer(
              backgroundColor: Provider.of<ComindColorsNotifier>(context)
                  .colorScheme
                  .background,
              child: const Nav(),
            ),
            bottomNavigationBar: SizedBox(
              height: 30,
              // color: Provider.of<ComindColorsNotifier>(context)
              //     .colorScheme
              //     .background,
              child: Flex(
                direction: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Add a text field
                  // MainTextField(primaryController: _primaryController),

                  // Add a public/private button
                  // ComindTextButton(
                  //   text: Provider.of<ComindColorsNotifier>(context).publicMode
                  //       ? "Public"
                  //       : "Private",
                  //   onPressed: () {
                  //     Provider.of<ComindColorsNotifier>(context, listen: false)
                  //         .togglePublicMode(!publicMode);
                  //   },
                  //   colorIndex: 2,
                  //   opacity: 0.8,
                  //   textStyle: const TextStyle(
                  //       fontFamily: "Bungee",
                  //       fontSize: 16,
                  //       color: Colors.white),
                  // ),

                  // Add current color scheme dot
                  Material(
                    color: Provider.of<ComindColorsNotifier>(context)
                        .colorScheme
                        .primary,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        colorDialog(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Provider.of<ComindColorsNotifier>(context)
                              .colorScheme
                              .primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 30,
                        height: 20,
                        margin: const EdgeInsets.all(0),
                      ),
                    ),
                  ),
                  // Container(
                  //   width: 20,
                  //   height: 20,
                  //   decoration: BoxDecoration(
                  //     color: Provider.of<ComindColorsNotifier>(context)
                  //         .colorScheme
                  //         .primary,
                  //     borderRadius: BorderRadius.circular(10),
                  //   ),
                  // ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: VerticalDivider(
                      color: Provider.of<ComindColorsNotifier>(context)
                          .colorScheme
                          .onPrimary
                          ?.withAlpha(32),
                      thickness: 1,
                      width: 1,
                    ),
                  ),

                  // Separate public and private buttons.
                  // The public button is on the left, the private button is on the right.
                  // when one is active, the other has no line
                  Row(
                    children: [
                      Padding(
                        padding: edgeInsets,
                        child: ComindTextButton(
                          text: "Public",
                          onPressed: () {
                            Provider.of<ComindColorsNotifier>(context,
                                    listen: false)
                                .togglePublicMode(true);
                          },
                          colorIndex: publicMode ? 1 : 0,
                          opacity: publicMode ? 1.0 : 0.4,
                          // opacity: 1,
                          textStyle: const TextStyle(
                              fontFamily: "Bungee", fontSize: 16),
                        ),
                      ),

                      // Add a private button
                      Padding(
                        padding: edgeInsets,
                        child: ComindTextButton(
                          text: "Private",
                          onPressed: () {
                            Provider.of<ComindColorsNotifier>(context,
                                    listen: false)
                                .togglePublicMode(false);
                          },
                          colorIndex: !publicMode ? 1 : 0,
                          opacity: !publicMode ? 1.0 : 0.4,
                          // opacity: 1,
                          textStyle: const TextStyle(
                            fontFamily: "Bungee",
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            body: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Add all the columns

                  // Left column
                  Visibility(
                    visible: MediaQuery.of(context).size.width > 800,
                    child: OutsideColumn(
                      child: Column(
                        children: [
                          // Add a note button
                          ComindTextButton(
                            text: "Concepts",
                            onPressed: () {
                              _fetchConcepts(context);
                            },
                            colorIndex: 2,
                            opacity: 0.8,
                            textStyle: const TextStyle(
                                fontFamily: "Bungee",
                                fontSize: 16,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Center column
                  centerColumn(context, constraints),

                  // Right column
                  Visibility(
                    visible: MediaQuery.of(context).size.width > 800,
                    child: OutsideColumn(
                      child: Column(
                        children: [
                          // Add a note button
                          ComindTextButton(
                            text: "Add note",
                            onPressed: () {
                              _addNote(
                                  context); // Call _addNote with the context
                            },
                            colorIndex: 2,
                            opacity: 0.8,
                            textStyle: const TextStyle(
                                fontFamily: "Bungee",
                                fontSize: 16,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        // Add your else condition here if needed
        return Container(); // Return an empty container if thoughts is empty
      },
    );
  }

  Future<dynamic> colorDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // Get the current color scheme
        final colorScheme =
            Provider.of<ComindColorsNotifier>(context).colorScheme;

        var fontSize = 14.0;
        var unselectedOpacity = 0.4;
        return AlertDialog(
          backgroundColor: colorScheme.background,
          title: const Text('Current Color Scheme'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Color scheme  ',
                      style: Provider.of<ComindColorsNotifier>(context)
                          .textTheme
                          .labelLarge),
                  // TODO #6 Support left line location for text buttons
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: ComindTextButton(
                            lineLocation: LineLocation.left,
                            colorIndex:
                                Provider.of<ComindColorsNotifier>(context)
                                            .colorMethod ==
                                        ColorMethod.triadic
                                    ? 1
                                    : 0,
                            opacity: Provider.of<ComindColorsNotifier>(context)
                                        .colorMethod ==
                                    ColorMethod.triadic
                                ? 1
                                : unselectedOpacity,
                            fontSize: fontSize,
                            text: "triadic",
                            onPressed: () {
                              Provider.of<ComindColorsNotifier>(context,
                                      listen: false)
                                  .setColorMethod(ColorMethod.triadic);
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: ComindTextButton(
                            lineLocation: LineLocation.left,
                            colorIndex:
                                Provider.of<ComindColorsNotifier>(context)
                                            .colorMethod ==
                                        ColorMethod.complementary
                                    ? 1
                                    : 0,
                            opacity: Provider.of<ComindColorsNotifier>(context)
                                        .colorMethod ==
                                    ColorMethod.complementary
                                ? 1
                                : unselectedOpacity,
                            fontSize: fontSize,
                            text: "complementary",
                            onPressed: () {
                              Provider.of<ComindColorsNotifier>(context,
                                      listen: false)
                                  .setColorMethod(ColorMethod.complementary);
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: ComindTextButton(
                            lineLocation: LineLocation.left,
                            colorIndex:
                                Provider.of<ComindColorsNotifier>(context)
                                            .colorMethod ==
                                        ColorMethod.splitComplementary
                                    ? 1
                                    : 0,
                            opacity: Provider.of<ComindColorsNotifier>(context)
                                        .colorMethod ==
                                    ColorMethod.splitComplementary
                                ? 1
                                : unselectedOpacity,
                            fontSize: fontSize,
                            text: "split complementary",
                            onPressed: () {
                              Provider.of<ComindColorsNotifier>(context,
                                      listen: false)
                                  .setColorMethod(
                                      ColorMethod.splitComplementary);
                            }),
                      ),
                      // Analogous
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: ComindTextButton(
                            lineLocation: LineLocation.left,
                            colorIndex:
                                Provider.of<ComindColorsNotifier>(context)
                                            .colorMethod ==
                                        ColorMethod.analogous
                                    ? 1
                                    : 0,
                            opacity: Provider.of<ComindColorsNotifier>(context)
                                        .colorMethod ==
                                    ColorMethod.analogous
                                ? 1
                                : unselectedOpacity,
                            fontSize: fontSize,
                            text: "analogous",
                            onPressed: () {
                              Provider.of<ComindColorsNotifier>(context,
                                      listen: false)
                                  .setColorMethod(ColorMethod.analogous);
                            }),
                      ),

                      // Monochromatic
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: ComindTextButton(
                            lineLocation: LineLocation.left,
                            colorIndex:
                                Provider.of<ComindColorsNotifier>(context)
                                            .colorMethod ==
                                        ColorMethod.monochromatic
                                    ? 1
                                    : 0,
                            opacity: Provider.of<ComindColorsNotifier>(context)
                                        .colorMethod ==
                                    ColorMethod.monochromatic
                                ? 1
                                : unselectedOpacity,
                            fontSize: fontSize,
                            text: "monochromatic",
                            onPressed: () {
                              Provider.of<ComindColorsNotifier>(context,
                                      listen: false)
                                  .setColorMethod(ColorMethod.monochromatic);
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            // TextButton(
            //   child: Text('Close'),
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //   },
            // ),

            // ComindTextButton
            ComindTextButton(
              text: "Close",
              onPressed: () {
                Navigator.of(context).pop();
              },
              colorIndex: 2,
              opacity: 0.8,
              fontSize: 16,
            ),
          ],
        );
      },
    );
  }

  SizedBox centerColumn(BuildContext context, BoxConstraints constraints) {
    return SizedBox(
      width: min(600, MediaQuery.of(context).size.width),
      child: Column(
        children: [
          // DEBUG FOR PIXEL WIDTH PIXEL HEIGHT
          // Text(
          //   "${constraints.maxWidth} wide, ${constraints.minHeight} tall",
          // ),
          // Text("Set colors"),

          // TODO #4 Find a design for the color picker that works.
          ColorPicker(onColorSelected: (Color color) {
            Provider.of<ComindColorsNotifier>(context, listen: false)
                .modifyColors(color);
          }),

          // Main text field
          MainTextField(
              onThoughtSubmitted: (Thought thought) async {
                // Send the thought
                // await saveThought(thought, newThought: true);

                // Add the new thought to the list
                setState(() {
                  // DEBUG replace thoughts with just new thought
                  thoughts = [thought];

                  // thoughts.add(thought);
                  // editVisibilityList.add(false);
                  // expandedVisibilityList.add(false);
                  // verbBarHoverList.add(false);
                  // _controllers.add(TextEditingController());
                  // _fetchThoughts();
                });
              },
              primaryController: _primaryController,
              colorIndex: Provider.of<ComindColorsNotifier>(context).publicMode
                  ? 2
                  : 1),

          /// THOUGHTS LIST VIEW / STREAM OF CONCIOUSNESS
          ///////////////////////////
          Expanded(
            child: Center(
              child: ListView.builder(
                itemCount: thoughts.length,
                itemBuilder: (context, index) {
                  return thoughtBox(context, index, constraints: constraints);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  double buttonSize(BoxConstraints constraints) {
    return constraints.maxWidth > 600 ? 16 : 14;
  } // Edit a note

  // void _editNote(BuildContext context, int index) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ThoughtEditorScreen(thought: thoughts[index]),
  //     ),
  //   ).then((updatedThought) {
  //     if (updatedThought != null) {
  //       setState(() {
  //         thoughts[index] = updatedThought;
  //       });
  //     }
  //   });
  // }

  Widget thoughtBox(BuildContext context, int index,
      {required BoxConstraints constraints}) {
    return MarkdownThought(thought: thoughts[index], context: context);
  }

  Expanded thoughtBoxVerbBar(BuildContext context, int index) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Opacity(
          opacity: 1,
          child: Row(
            children: [
              ComindTextButton(
                  // lineOnly: !verbBarHoverList[index],
                  colorIndex: 3,
                  onPressed: () async {
                    bool? shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor:
                              Provider.of<ComindColorsNotifier>(context)
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
              // ComindTextButton(
              //     text: "Think",
              //     // lineOnly: !verbBarHoverList[index],
              //     opacity: 0.8,
              //     colorIndex: 2,
              //     textStyle:
              //         const TextStyle(fontFamily: "Bungee", fontSize: 16),
              //     onPressed: () {
              //       // Save the parent thought if the text has length > 0
              //       if (_controllers[index].text.isNotEmpty) {
              //         // Send the thought
              //         saveQuickThought(_controllers[index].text, publicMode,
              //             thoughts[index].id);

              //         // Clear the text field
              //         _controllers[index].clear();

              //         // Refresh the thoughts
              //         _fetchThoughts();
              //       }
              //     }),

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
                  textStyle:
                      const TextStyle(fontFamily: "Bungee", fontSize: 16)),
            ],
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
            foregroundColor: Provider.of<ComindColorsNotifier>(context)
                .colorScheme
                .onPrimary,
            backgroundColor: Provider.of<ComindColorsNotifier>(context)
                .colorScheme
                .background,
            textStyle: Provider.of<ComindColorsNotifier>(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontSize: 14)),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: child,
        ));
  }
}

class OutsideColumn extends StatelessWidget {
  const OutsideColumn({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: min((MediaQuery.of(context).size.width - 650) / 2, 400),
        child: child);
  }
}

class Nav extends StatelessWidget {
  const Nav({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Provider.of<ComindColorsNotifier>(context).colorScheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blubble bar thing (not sure what to call it)
          // Anyway it's just for testing rn to fill hte column
          Expanded(
            // color: Provider.of<ComindColorsNotifier>(context).colorScheme.background,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                child: Container(
                  height: 100,
                  // Make it a rounded rectangle
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(42),
                    color: Provider.of<ComindColorsNotifier>(context)
                        .colorScheme
                        .background,
                  ),

                  // color: BoxDecoration(
                  //     child: Provider.of<ComindColorsNotifier>(context)
                  //         .colorScheme
                  //         .surface
                  //         .withAlpha(32)),
                  child: Material(
                    // color: Provider.of<ComindColorsNotifier>(context).colorScheme.primary,
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
