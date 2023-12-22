import 'package:comind/markdown_display.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // TODO Probably actually use this at some point instead of MarkdownBody
import 'package:intl/intl.dart';
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
      create: (_) => ThemeProvider(),
      child: const ComindApp(),
    ),
  ));
}

class ComindApp extends StatelessWidget {
  const ComindApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, ComindColorsNotifier>(
      builder: (context, themeProvider, colorNotifier, child) {
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
                        MainTextField(
                            primaryController: _primaryController,
                            colorIndex: publicMode ? 2 : 1),

                        // Single row with time on the right
                        // Time
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                          child: Opacity(
                            opacity: 0.5,
                            child: Text(
                              DateFormat('h:mm a').format(DateTime.now()),
                              style: Provider.of<ComindColorsNotifier>(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontSize: 12,
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
                    //           // color: Provider.of<ComindColorsNotifier>(context).colorScheme.background,
                    //           child: Padding(
                    //             padding: const EdgeInsets.all(16.0),
                    //             child: InkWell(
                    //               child: Container(
                    //                 height: 100,
                    //                 // Make it a rounded rectangle
                    //                 decoration: BoxDecoration(
                    //                   borderRadius: BorderRadius.circular(42),
                    //                   // color: Provider.of<ComindColorsNotifier>(context)
                    //                   //     .colorScheme
                    //                   //     .surface
                    //                   //     .withAlpha(32),
                    //                 ),

                    //                 // color: BoxDecoration(
                    //                 //     child: Provider.of<ComindColorsNotifier>(context)
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

  Widget thoughtBox(BuildContext context, int index,
      {required BoxConstraints constraints}) {
    return MarkdownThought(thought: thoughts[index], context: context);

    // return Padding(
    //   padding: constraints.maxWidth > 600
    //       ? const EdgeInsets.fromLTRB(0, 0, 0, 32)
    //       : const EdgeInsets.fromLTRB(16, 8, 16, 24),
    //   child: Container(
    //       decoration: BoxDecoration(
    //           border:
    //               Border.all(color: Provider.of<ComindColorsNotifier>(context).dialogBackgroundColor)),
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.start,
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           // Show name & date
    //           nameAndDate(index, context, compact: constraints.maxWidth < 600),

    //           // Thought body
    //           Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Padding(
    //                   padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    //                   child: MarkdownThought(
    //                       thought: thoughts[index], context: context)),
    //             ],
    //           ),

    //           // Text editing row, thought box
    //           Visibility(
    //             visible: editVisibilityList[index],
    //             child: Row(
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               children: [
    //                 Expanded(
    //                   child: Padding(
    //                     padding: const EdgeInsets.fromLTRB(0, 2, 0, 4),
    //                     child: TextField(
    //                       autofocus: false,
    //                       controller: _controllers[index],
    //                       maxLines: null,
    //                       style: Provider.of<ComindColorsNotifier>(context)
    //                           .textTheme
    //                           .bodyMedium
    //                           ?.copyWith(fontSize: 16),
    //                       cursorColor: Provider.of<ComindColorsNotifier>(context).colorScheme.onPrimary,
    //                       decoration: InputDecoration(
    //                         contentPadding:
    //                             const EdgeInsets.fromLTRB(8, 8, 8, 8),
    //                         enabledBorder: OutlineInputBorder(
    //                           borderSide: BorderSide(
    //                             color: Provider.of<ComindColorsNotifier>(context)
    //                                 .colorScheme
    //                                 .onPrimary
    //                                 .withAlpha(32),
    //                           ),
    //                         ),
    //                         focusedBorder: OutlineInputBorder(
    //                           borderSide: BorderSide(
    //                             color: Provider.of<ComindColorsNotifier>(context)
    //                                 .colorScheme
    //                                 .onPrimary
    //                                 .withAlpha(64),
    //                           ),
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),

    //           ///////////////////////
    //           // Verbs (hehe vebs) //
    //           ///////////////////////
    //           MouseRegion(
    //             onEnter: (event) {
    //               setState(() {
    //                 verbBarHoverList[index] = true;
    //               });
    //             },
    //             onExit: (event) {
    //               setState(() {
    //                 verbBarHoverList[index] = false;
    //               });
    //             },
    //             child: Opacity(
    //               opacity: verbBarHoverList[index] ? 1.0 : 0.5,
    //               child: Padding(
    //                 padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
    //                 child: Row(
    //                   mainAxisAlignment: editVisibilityList[index]
    //                       ? MainAxisAlignment.end
    //                       : MainAxisAlignment.center,
    //                   children: [
    //                     // User name
    //                     // Padding(
    //                     //     padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
    //                     //     child: constraints.maxWidth > 600
    //                     //         ? nameAndDate(index, context)
    //                     //         : nameAndDate(index, context, compact: true)),

    //                     // Divider line
    //                     // Visibility(
    //                     //   // visible: !editVisibilityList[index],
    //                     //   visible: true,
    //                     //   child: Expanded(
    //                     //     child: Container(
    //                     //       height: 2,
    //                     //       color: Provider.of<ComindColorsNotifier>(context)
    //                     //           .colorScheme
    //                     //           .onBackground
    //                     //           .withAlpha(32),
    //                     //     ),
    //                     //   ),
    //                     // ),

    //                     // Divider line
    //                     // Visibility(
    //                     //   // visible: !editVisibilityList[index],
    //                     //   visible: true,
    //                     //   child: Expanded(
    //                     //     child: Container(
    //                     //       height: 2,
    //                     //       color: Provider.of<ComindColorsNotifier>(context)
    //                     //           .colorScheme
    //                     //           .onBackground
    //                     //           .withAlpha(32),
    //                     //     ),
    //                     //   ),
    //                     // ),

    //                     //////////////////////////
    //                     /// VERB ROW BUTTONS ///
    //                     //////////////////////////
    //                     thoughtBoxVerbBar(context, index),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ],
    //       )),
    // );
  }

  Expanded thoughtBoxVerbBar(BuildContext context, int index) {
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
              //     color: Provider.of<ComindColorsNotifier>(context).colorScheme.onPrimary,
              //   ),
              //   iconSize: 16,
              //   splashRadius: 16,
              //   padding: const EdgeInsets.all(8),
              //   constraints: const BoxConstraints(),
              //   color: Provider.of<ComindColorsNotifier>(context).colorScheme.onPrimary,
              //   hoverColor: Provider.of<ComindColorsNotifier>(context).colorScheme.primary,
              //   focusColor: Provider.of<ComindColorsNotifier>(context).colorScheme.onPrimary,
              //   highlightColor: Provider.of<ComindColorsNotifier>(context).colorScheme.onPrimary,
              //   disabledColor: Provider.of<ComindColorsNotifier>(context).colorScheme.onPrimary,
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
                  colorIndex: 2,
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
      // color: Provider.of<ComindColorsNotifier>(context).colorScheme.primary,
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
                            ? Provider.of<ComindColorsNotifier>(context)
                                .currentColors
                                .secondaryColor
                                .withAlpha(200)
                            : color == 3
                                ? Provider.of<ComindColorsNotifier>(context)
                                    .currentColors
                                    .tertiaryColor
                                    .withAlpha(200)
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
              color: Provider.of<ComindColorsNotifier>(context)
                  .colorScheme
                  .onBackground
                  .withAlpha(64),
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
                    // decorationColor: Provider.of<ComindColorsNotifier>(context).primaryColor,
                    decorationColor: thoughts[index].isPublic
                        ? Provider.of<ComindColorsNotifier>(context)
                            .currentColors
                            .secondaryColor
                        : Provider.of<ComindColorsNotifier>(context)
                            .currentColors
                            .tertiaryColor,
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
                  color: Provider.of<ComindColorsNotifier>(context)
                      .colorScheme
                      .onBackground
                      .withAlpha(32),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: Opacity(
                opacity: 0.5,
                child: Text(
                  formatTimestamp(thoughts[index].dateUpdated),
                  style: Provider.of<ComindColorsNotifier>(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
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
