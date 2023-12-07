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
  List<bool> visibilityList = [];

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
      visibilityList = List<bool>.filled(thoughts.length, false);
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
                  // Non ListTile version
                  return Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).dialogBackgroundColor)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              nameAndDate(index, context),
                            ],
                          ),
                          // Add some space
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              bodyCell(index, context),
                            ],
                          ),

                          Container(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                              child: TextField(
                                onTap: () {
                                  // Toggle the visibility
                                  setState(() {
                                    visibilityList[index] = true;
                                  });
                                },
                                cursorColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                decoration: InputDecoration(
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
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withAlpha(32),
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withAlpha(32),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withAlpha(255),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Fit width
                            // decoration: BoxDecoration(
                            //   borderRadius: BorderRadius.circular(14),

                            //   // Border color
                            //   border: Border.all(
                            //     color: Theme.of(context).colorScheme.surface,
                            //   ),
                            //   // color: Theme.of(context).colorScheme.surface,
                            // ),
                            // width: double.infinity,
                          ),

                          //
                          Visibility(
                            visible: visibilityList[index],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    thoughtListButton(context,
                                        child: const Text("Edit",
                                            style: TextStyle(
                                                fontFamily: "Bungee")),
                                        onPressed: () {
                                      _editNote(context, index);
                                      setState(() {
                                        visibilityList[index] =
                                            !visibilityList[index];
                                      });
                                    }),
                                    thoughtListButton(context,
                                        child: const Text("Delete",
                                            style: TextStyle(
                                                fontFamily: "Bungee")),
                                        onPressed: () {
                                      // _editNote(context, index);
                                      // setState(() {
                                      //   visibilityList[index] =
                                      //       !visibilityList[index];
                                      // });
                                    }),
                                    thoughtListButton(context,
                                        child: const Text("X",
                                            style: TextStyle(
                                                fontFamily: "Bungee")),
                                        onPressed: () {
                                      // _editNote(context, index);
                                      setState(() {
                                        visibilityList[index] =
                                            !visibilityList[index];
                                      });
                                    }),

                                    // Horitzonal divider
                                    const VerticalDivider(
                                      color: Colors.red,
                                      thickness: 1,
                                      width: 24,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Divider
                          Divider(
                            color: index % 2 == 0
                                ? ComindColors.primaryColor
                                : index % 3 == 0
                                    ? ComindColors.secondaryColor
                                    : ComindColors.tertiaryColor,
                            thickness: 1,
                            height: 24,
                          ),
                        ],
                      ));

                  // return ListTile(
                  //   title: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       Column(
                  //         children: [
                  //           Text(
                  //             thoughts[index].username,
                  //             style: const TextStyle(
                  //               fontFamily: "Bungee",
                  //               fontSize: 16,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       Text(
                  //         formatTimestamp(thoughts[index].dateUpdated),
                  //         style:
                  //             Theme.of(context).textTheme.bodyMedium?.copyWith(
                  //                   fontSize: 12,
                  //                 ),
                  //       )
                  //     ],
                  //   ),
                  //   subtitle: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       MarkdownBody(
                  //         // Use the thought content
                  //         data: thoughts[index].body,

                  //         // Set the markdown styling
                  //         styleSheet: MarkdownStyleSheet(
                  //           blockquoteDecoration: BoxDecoration(
                  //             color:
                  //                 Theme.of(context).colorScheme.surfaceVariant,
                  //             borderRadius: BorderRadius.circular(4),
                  //           ),
                  //           codeblockDecoration: BoxDecoration(
                  //             color:
                  //                 Theme.of(context).colorScheme.surfaceVariant,
                  //             borderRadius: BorderRadius.circular(4),
                  //           ),
                  //           code: GoogleFonts.ibmPlexMono(
                  //             backgroundColor:
                  //                 Theme.of(context).colorScheme.surfaceVariant,
                  //             fontWeight: FontWeight.w400,
                  //             fontSize: 14,
                  //           ),
                  //           blockquote: TextStyle(
                  //             color: Theme.of(context).colorScheme.onPrimary,
                  //             fontFamily: "Bungee",
                  //             fontSize: 14,
                  //           ),
                  //         ),
                  //       ),
                  //       // Text(
                  //       //   thoughts[index].body,
                  //       //   style: Theme.of(context).textTheme.bodyMedium,
                  //       // ),
                  //       const Divider()
                  //     ],
                  //   ),
                  //   onTap: () {
                  //     _editNote(context, index);
                  //   },
                  // );
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

  Column nameAndDate(int index, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
              ),
        ),
      ],
    );
  }

  MarkdownBody bodyCell(int index, BuildContext context) {
    return MarkdownBody(
      // Use the thought content
      data: thoughts[index].body,
      selectable: true,

      // Set the markdown styling
      styleSheet: MarkdownStyleSheet(
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

// Some dead code for an expandy button
// Row(
//                             children: [
//                               // A circle button with a plus icon in the middle
//                               Material(
//                                 //Set border width
//                                 borderRadius: BorderRadius.circular(10),

//                                 //Set inkwell color
//                                 color: Theme.of(context).colorScheme.background,

//                                 //Set inkwell radius
//                                 child: InkWell(
//                                   hoverColor: ComindColors.primaryColor,
//                                   borderRadius: BorderRadius.circular(10),
//                                   onTap: () {
//                                     setState(() {
//                                       visibilityList[index] =
//                                           !visibilityList[index];
//                                     });
//                                   },
//                                   child: Container(
//                                     padding: const EdgeInsets.all(4),
//                                     // decoration: BoxDecoration(
//                                     //   shape: BoxShape.circle,
//                                     //   border: Border.all(
//                                     //     color: Colors.white,
//                                     //   ),
//                                     // ),
//                                     child: visibilityList[index]
//                                         ? Text("<",
//                                             style:
//                                                 TextStyle(fontFamily: "Bungee"))
//                                         : Text(">>",
//                                             style: TextStyle(
//                                                 fontFamily: "Bungee")),
//                                     // color:
//                                     //     Theme.of(context).colorScheme.onPrimary,
//                                   ),
//                                 ),
//                               ),
//                               // IconButton(
//                               //     onPressed: () {
//                               //       setState(() {
//                               //         visibilityList[index] =
//                               //             !visibilityList[index];
//                               //       });
//                               //     },
//                               //     icon: Icon(Icons.expand_more)),

//                               // Bottom row, toggled by button
//                               Visibility(
//                                 visible: visibilityList[index],
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceAround,
//                                   children: [
//                                     thoughtListButton(context,
//                                         child: const Text("Edit",
//                                             style: TextStyle(
//                                                 fontFamily: "Bungee")),
//                                         onPressed: () {
//                                       _editNote(context, index);
//                                       setState(() {
//                                         visibilityList[index] =
//                                             !visibilityList[index];
//                                       });
//                                     }),
//                                     thoughtListButton(context,
//                                         child: const Text("Delete",
//                                             style: TextStyle(
//                                                 fontFamily: "Bungee")),
//                                         onPressed: () {
//                                       // _editNote(context, index);
//                                       // setState(() {
//                                       //   visibilityList[index] =
//                                       //       !visibilityList[index];
//                                       // });
//                                     }),
//                                   ],
//                                 ),
//                               ),
//                             ],

//                             // Untoggled version
//                             // Row(children: [
//                             //   thoughtListButton(context,
//                             //       child: Icon(Icons.edit),
//                             //       // child: Text("Edit"),
//                             //       onPressed: () => _editNote(context, index)),
//                             // ]),
//                             // Divider(
//                             //     // color: Theme.of(context).colorScheme.primary,
//                             //     // thickness: 2,
//                             //     // height: 2,
//                             //     ),
//                           ),
