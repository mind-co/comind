import 'dart:math';

import 'package:comind/color_picker.dart';
import 'package:comind/login.dart';
import 'package:comind/markdown_display.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'package:comind/dispatch.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ComindColorsNotifier()),
        ChangeNotifierProvider(create: (_) => ThoughtsProvider()),
      ],
      builder: (context, child) {
        return MaterialApp(
          // home: const LoginScreen(),
          // home: ThoughtEditorScreen(
          //   thought: Thought.basic(),
          // ),
          // home: const ThoughtListScreen(),

          // Set up the routes
          routes: {
            // '/': (context) =>
            //     ThoughtEditorScreen(id: "881750f4-cb3d-521a-92ce-70024e6fb3fe"),
            '/': (context) => const Dispatch(),
            '/login': (context) => const LoginScreen(),
          },

          // home: StreamScreen(),
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: Provider.of<ComindColorsNotifier>(context).colorScheme,
            textTheme: Provider.of<ComindColorsNotifier>(context)
                .currentColors
                .textTheme,
            snackBarTheme: SnackBarThemeData(
              backgroundColor: Provider.of<ComindColorsNotifier>(context)
                  .colorScheme
                  .surfaceVariant,
              contentTextStyle: Provider.of<ComindColorsNotifier>(context)
                  .currentColors
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: Provider.of<ComindColorsNotifier>(context)
                        .colorScheme
                        .onSurface,
                  ),
            ),
            bottomSheetTheme: const BottomSheetThemeData(
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.transparent,
            ),
          ),
          darkTheme: ThemeData(
              useMaterial3: true,
              // colorScheme: ComindColors.darkColorScheme,
              colorScheme:
                  Provider.of<ComindColorsNotifier>(context).colorScheme,
              textTheme: Provider.of<ComindColorsNotifier>(context)
                  .currentColors
                  .textTheme,
              snackBarTheme: SnackBarThemeData(
                backgroundColor: Provider.of<ComindColorsNotifier>(context)
                    .colorScheme
                    .surfaceVariant,
                contentTextStyle: Provider.of<ComindColorsNotifier>(context)
                    .currentColors
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: Provider.of<ComindColorsNotifier>(context)
                          .colorScheme
                          .onSurface,
                    ),
              ),
              dialogTheme: DialogTheme(
                backgroundColor: Provider.of<ComindColorsNotifier>(context)
                    .colorScheme
                    .surface,
              ),
              bottomSheetTheme: const BottomSheetThemeData(
                surfaceTintColor: Colors.transparent,
                backgroundColor: Colors.transparent,
              )),
          debugShowCheckedModeBanner: false,
          themeMode: Provider.of<ComindColorsNotifier>(context).darkMode
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
  bool loaded = false;

  // Menu bools for the top bar
  bool editorVisible = false;
  bool moreMenuExpanded = false;

  // List of text controllers
  final TextEditingController _primaryController = TextEditingController();

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
    List<Thought> fetchedThoughts = await fetchThoughts(context);

    // Add all thoughts to the provider
    // ignore: use_build_context_synchronously
    Provider.of<ThoughtsProvider>(context, listen: false)
        .addThoughts(fetchedThoughts);

    setState(() {
      loaded = true;
    });
  }

  // Make a new thought and go to the text editor
  void _addNote(BuildContext context) {
    // This function will be called when you want to add a new note.
    final newThought = Thought.fromString(
        "",
        Provider.of<AuthProvider>(context, listen: false).username,
        Provider.of<ComindColorsNotifier>(context).publicMode);

    Provider.of(context, listen: false).addThoughts([newThought]);

    setState(() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ThoughtEditorScreen(thought: newThought),
        ),
      );
    });
  }

  // Delete a note
  @override
  Widget build(BuildContext context) {
    bool publicMode = Provider.of<ComindColorsNotifier>(context).publicMode;

    // Check if we're logged in
    if (!Provider.of<AuthProvider>(context).isLoggedIn) {
      return const LoginScreen();
    }

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
        if (getThoughts(context).isNotEmpty) {
          const edgeInsets = EdgeInsets.fromLTRB(8, 2, 8, 2);
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
            bottomNavigationBar: bottomBar(context, edgeInsets, publicMode),
            body: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Add all the columns

                  // Left column
                  // Visibility(
                  //   visible: MediaQuery.of(context).size.width > 800,
                  //   child: OutsideColumn(
                  //     child: Column(
                  //       children: [
                  //         // Add a note button
                  //         ComindTextButton(
                  //           text: "Concepts",
                  //           onPressed: () {
                  //             // TODO #9 add a concepts column
                  //           },
                  //           colorIndex: 0,
                  //           opacity: 0.8,
                  //           textStyle: const TextStyle(
                  //               fontFamily: "Bungee",
                  //               fontSize: 16,
                  //               color: Colors.white),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  // Center column
                  centerColumn(context, constraints),

                  // Right column
                  // Visibility(
                  //   visible: MediaQuery.of(context).size.width > 800,
                  //   child: OutsideColumn(
                  //     child: Column(
                  //       children: [
                  //         // Add a note button
                  //         ComindTextButton(
                  //           text: "Suggested",
                  //           onPressed: () {
                  //             _addNote(
                  //                 context); // Call _addNote with the context
                  //           },
                  //           colorIndex: 0,
                  //           opacity: 0.8,
                  //           textStyle: const TextStyle(
                  //               fontFamily: "Bungee",
                  //               fontSize: 16,
                  //               color: Colors.white),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
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

  List<Thought> getThoughts(BuildContext context) =>
      Provider.of<ThoughtsProvider>(context).thoughts;

  Container bottomBar(
      BuildContext context, EdgeInsets edgeInsets, bool publicMode) {
    return Container(
      decoration: BoxDecoration(
        color:
            Provider.of<ComindColorsNotifier>(context).colorScheme.background,
        border: Border(
          top: BorderSide(
            color: Provider.of<ComindColorsNotifier>(context)
                .colorScheme
                .onBackground
                .withAlpha(128),
            width: 1,
          ),
        ),
      ),
      height: 60,
      width: ComindColors.maxWidth,
      // color: Provider.of<ComindColorsNotifier>(context)
      //     .colorScheme
      //     .background,
      child: Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Add a text field
          // TODO #10 Move text field to the bottom bar
          // MainTextField(primaryController: _primaryController),

          // Add current color scheme dot
          Material(
            color:
                Provider.of<ComindColorsNotifier>(context).colorScheme.primary,
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
                  border: Border.all(
                    color: Provider.of<ComindColorsNotifier>(context)
                        .colorScheme
                        .onPrimary,
                    width: 1,
                  ),
                ),
                width: 30,
                height: 30,
                margin: const EdgeInsets.all(0),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: VerticalDivider(
              color: Provider.of<ComindColorsNotifier>(context)
                  .colorScheme
                  .onPrimary
                  .withAlpha(32),
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
                    Provider.of<ComindColorsNotifier>(context, listen: false)
                        .togglePublicMode(true);
                  },
                  colorIndex: publicMode ? 1 : 0,
                  opacity: publicMode ? 1.0 : 0.4,
                  // opacity: 1,
                  textStyle:
                      const TextStyle(fontFamily: "Bungee", fontSize: 16),
                ),
              ),

              // Add a private button
              Padding(
                padding: edgeInsets,
                child: ComindTextButton(
                  text: "Private",
                  onPressed: () {
                    Provider.of<ComindColorsNotifier>(context, listen: false)
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
        const edgeInsets = EdgeInsets.fromLTRB(0, 4, 0, 4);

        return AlertDialog(
          backgroundColor: colorScheme.background,
          title: const Text('Current Color Scheme'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hey, pick a color! It's fun probably",
                      style: Provider.of<ComindColorsNotifier>(context)
                          .textTheme
                          .bodyMedium),
                  const SizedBox(height: 16),
                  ComindLogo(
                      colors: Provider.of<ComindColorsNotifier>(context)),
                  const SizedBox(height: 16),
                  Text('Primary color  ',
                      style: Provider.of<ComindColorsNotifier>(context)
                          .textTheme
                          .labelLarge),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Divider(
                      color: colorScheme.onPrimary.withAlpha(32),
                      thickness: 1,
                      height: 1,
                    ),
                  ),
                  ColorPicker(onColorSelected: (Color color) {
                    Provider.of<ComindColorsNotifier>(context, listen: false)
                        .modifyColors(color);
                  }),
                  const SizedBox(height: 16),
                  Text('Color scheme  ',
                      style: Provider.of<ComindColorsNotifier>(context)
                          .textTheme
                          .labelLarge),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Divider(
                      color: colorScheme.onPrimary.withAlpha(32),
                      thickness: 1,
                      height: 1,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: edgeInsets,
                        child: ComindTextButton(
                            lineLocation: LineLocation.left,
                            colorIndex: isTriadic(context) ? 1 : 0,
                            opacity: isTriadic(context) ? 1 : unselectedOpacity,
                            fontSize: fontSize,
                            text: "triadic",
                            onPressed: () {
                              Provider.of<ComindColorsNotifier>(context,
                                      listen: false)
                                  .setColorMethod(ColorMethod.triadic);

                              // Calculate the new scheme for the primary color
                              Provider.of<ComindColorsNotifier>(context,
                                      listen: false)
                                  .modifyColors(
                                      Provider.of<ComindColorsNotifier>(context)
                                          .currentColors
                                          .primaryColor);
                            }),
                      ),
                      Padding(
                        padding: edgeInsets,
                        child: ComindTextButton(
                            lineLocation: LineLocation.left,
                            colorIndex: isComplementary(context) ? 1 : 0,
                            opacity: isComplementary(context)
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
                        padding: edgeInsets,
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
                        padding: edgeInsets,
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
                        padding: edgeInsets,
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

  bool isComplementary(BuildContext context) {
    return Provider.of<ComindColorsNotifier>(context).colorMethod ==
        ColorMethod.complementary;
  }

  bool isTriadic(BuildContext context) {
    return Provider.of<ComindColorsNotifier>(context).colorMethod ==
        ColorMethod.triadic;
  }

  SizedBox centerColumn(BuildContext context, BoxConstraints constraints) {
    return SizedBox(
      width: min(ComindColors.maxWidth, MediaQuery.of(context).size.width),
      child: Column(
        children: [
          // DEBUG FOR PIXEL WIDTH PIXEL HEIGHT
          // Text(
          //   "${constraints.maxWidth} wide, ${constraints.minHeight} tall",
          // ),
          // Text("Set colors"),

          // Main text field
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: MainTextField(
                onThoughtSubmitted: (Thought thought) async {
                  // Push the thought to the provider
                  // ignore: use_build_context_synchronously
                  Provider.of<ThoughtsProvider>(context, listen: false)
                      .addThought(thought);

                  print("Thought submitted: ${thought.body}");

                  // Send the thought
                  await saveThought(context, thought, newThought: true);
                },
                primaryController: _primaryController,
                colorIndex:
                    Provider.of<ComindColorsNotifier>(context).publicMode
                        ? 2
                        : 1),
          ),

          // SizedBox(
          //   width:
          //       min(ComindColors.maxWidth, MediaQuery.of(context).size.width),
          //   height: 900,
          //   child: Consumer<ThoughtsProvider>(
          //     builder: (context, thoughtsProvider, child) {
          //       return ListView.builder(
          //         itemCount: thoughtsProvider.thoughts.length,
          //         itemBuilder: (context, index) {
          //           final thought = thoughtsProvider.thoughts[index];
          //           return SizedBox(
          //               width: 600, height: 100, child: Text(thought.body));
          //           // Use 'thought' to build your widgets.
          //         },
          //       );
          //     },
          //   ),
          // )

          /// THOUGHTS LIST VIEW / STREAM OF CONCIOUSNESS
          ///////////////////////////
          Expanded(
            child: Center(
              child: Consumer<ThoughtsProvider>(
                builder: (BuildContext context, ThoughtsProvider value,
                    Widget? child) {
                  return ListView.builder(
                    itemCount: value.thoughts.length,
                    itemBuilder: (context, index) {
                      // return thoughtBox(context, index, constraints: constraints);

                      // Add vertical spacer if index != thoughts.length
                      return Column(
                        children: [
                          // Add a vertical spacer if index != 0
                          // if (index != 0) const SizedBox(height: 16),

                          // Add the thought box
                          thoughtBox(context, index, constraints: constraints),

                          // Add a vertical spacer if index != thoughts.length
                          // if (index != getThoughts(context).length - 1)
                          //   Container(
                          //     height: 64,
                          //     width: 2,
                          //     color: Provider.of<ComindColorsNotifier>(context)
                          //         .colorScheme
                          //         .onPrimary
                          //         .withAlpha(32),
                          //   )
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget thoughtBox(BuildContext context, int index,
      {required BoxConstraints constraints}) {
    //

    return MarkdownThought(
        thought: Provider.of<ThoughtsProvider>(context).thoughts[index]);
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
                                  colorIndex: 0,
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
                                      colorIndex: 0,
                                      onPressed: () {
                                        // Navigate to the about page
                                      },
                                    ),

                                    ///////////////
                                    ///SETTINGS ///
                                    /// ///////////
                                    ComindTextButton(
                                      text: "Settings",
                                      colorIndex: 0,
                                      onPressed: () {
                                        // Navigate to the settings page
                                      },
                                    ),

                                    ///////////////
                                    ///LOGOUT ////
                                    /// ///////////
                                    ComindTextButton(
                                        text: "Logout",
                                        colorIndex: 0,
                                        onPressed: () {
                                          // Logout
                                          Provider.of<AuthProvider>(context,
                                                  listen: false)
                                              .logout();
                                        }),
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
