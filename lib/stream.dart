import 'package:comind/api.dart';
import 'package:comind/bottom_sheet.dart';
import 'package:comind/cine_wave.dart';
import 'package:comind/colors.dart';
import 'package:comind/hover_icon_button.dart';
import 'package:comind/input_field.dart';
import 'package:comind/main.dart';
import 'package:comind/markdown_display.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/providers.dart';
import 'package:comind/text_button_simple.dart';
import 'package:comind/types/thought.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Stream extends StatefulWidget {
  const Stream({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _StreamState createState() => _StreamState();
}

class _StreamState extends State<Stream> {
  // the text controller
  final _primaryController = TextEditingController();

  // Method to fetch thoughts related to the top of mind thought.
  // These are stored in the ThoughtsProvider.
  void fetchRelatedThoughts() async {
    // Get the top of mind thought
    final topOfMind = getTopOfMind(context);

    // If the top of mind thought is null, do nothing
    if (topOfMind == null) {
      return;
    }

    // Search for related thoughts
    final relatedThoughts = await searchThoughts(context, topOfMind.body);

    // Add the related thoughts to the provider
    setState(() {
      // Add the thought to the provider
      Provider.of<ThoughtsProvider>(context, listen: false)
          .addThoughts(relatedThoughts);

      // Set the top of mind
      setTopOfMind(context, topOfMind);
    });
  }

  @override
  void initState() {
    super.initState();

    // Fetch related thoughts
    fetchRelatedThoughts();
  }

  @override
  Widget build(BuildContext context) {
    // Debug initialize the top of mind thought to coThought
    // topOfMind = Thought.fromString(
    //     "I'm happy to have you here :smiley:", "Co", true,
    //     title: "Welcome to comind");
    return Scaffold(
      // App bar
      appBar: comindAppBar(context),

      // Bottom sheet
      bottomSheet: ComindBottomSheet(),

      // Body
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Consumer2<AuthProvider, ThoughtsProvider>(
            builder: (context, authProvider, thoughtsProvider, child) {
              // Your code here
              // Use authProvider to access authentication related data
              // Return the desired widget tree
              return mainStream(constraints, context);
            },
          );
        },
      ),
    );
  }

  SingleChildScrollView mainStream(
      BoxConstraints constraints, BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left column
            Visibility(
              visible: showSideColumns(context),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: leftColumnWidth(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Action row under the text box
                      Visibility(
                        visible: !Provider.of<ThoughtsProvider>(context)
                            .hasTopOfMind,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Wrap(direction: Axis.vertical, children: [
                            // // Color picker
                            // ColorPicker(onColorSelected: (Color color) {
                            //   Provider.of<ComindColorsNotifier>(context, listen: false)
                            //       .modifyColors(color);
                            // }),

                            Text("Menu",
                                style: getTextTheme(context).titleSmall),
                            SizedBox(height: 0),

                            // Public/private button
                            TextButtonSimple(
                                text: Provider.of<ComindColorsNotifier>(context)
                                        .publicMode
                                    ? "Public"
                                    : "Private",
                                onPressed: () {
                                  Provider.of<ComindColorsNotifier>(context,
                                          listen: false)
                                      .togglePublicMode(
                                          !Provider.of<ComindColorsNotifier>(
                                                  context,
                                                  listen: false)
                                              .publicMode);
                                }),

                            // Color picker button
                            TextButtonSimple(
                                text: "Color",
                                onPressed: () async {
                                  Color color = await colorDialog(context);
                                  Provider.of<ComindColorsNotifier>(context,
                                          listen: false)
                                      .modifyColors(color);
                                }),

                            // Login button
                            Visibility(
                              visible: !Provider.of<AuthProvider>(context)
                                  .isLoggedIn,
                              child: TextButtonSimple(
                                  text: "Log in",
                                  // Navigate to login page.
                                  onPressed: () {
                                    Navigator.pushNamed(context, "/login");
                                  }),
                            ),

                            // Sign up button
                            Visibility(
                              visible: !Provider.of<AuthProvider>(context)
                                  .isLoggedIn,
                              child: TextButtonSimple(
                                  text: "Sign up",
                                  // Navigate to sign up page.
                                  onPressed: () {
                                    Navigator.pushNamed(context, "/signup");
                                  }),
                            ),

                            // Settings
                            // Visibility(
                            //   child: TextButtonSimple(
                            //       text: "Settings",
                            //       onPressed: () {
                            //         Navigator.pushNamed(
                            //             context, "/settings");
                            //       }),
                            // ),

                            const SizedBox(height: 20),
                            Text("Dev buttons",
                                style: getTextTheme(context).titleSmall),

                            // Debug button to add a top of mind thought
                            Visibility(
                              visible: true,
                              child: TextButtonSimple(
                                  text: "TOM",
                                  onPressed: () {
                                    Provider.of<ThoughtsProvider>(context,
                                            listen: false)
                                        .setTopOfMind(Thought.fromString(
                                            "I'm happy to have you here :smiley:",
                                            "Co",
                                            true,
                                            title: "Welcome to comind"));
                                  }),
                            ),

                            const SizedBox(height: 20),
                            Text("Other stuff",
                                style: getTextTheme(context).titleSmall),

                            // Logout button
                            Visibility(
                              visible:
                                  Provider.of<AuthProvider>(context).isLoggedIn,
                              child: TextButtonSimple(
                                  text: "Log out",
                                  onPressed: () => {
                                        // Logout
                                        Provider.of<AuthProvider>(context,
                                                listen: false)
                                            .logout()
                                      }),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Center column
            CenterColumn(context),

            // Right column
            Visibility(
              visible: showSideColumns(context),
              child: SizedBox(
                width: rightColumnWidth(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Notifications",
                        style: getTextTheme(context).titleSmall),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Column CenterColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: centerColumnWidth(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                children: [
                  // columnOfThings(context),

                  // Make column of things a consumer of thoughtprovider,
                  // so that it rebuilds when the thoughts change.
                  Consumer<ThoughtsProvider>(
                    builder: (context, thoughtsProvider, child) {
                      return columnOfThings(context);
                    },
                  ),

                  // MarkdownThought(
                  //     type: MarkdownDisplayType.newThought,
                  //     thought: Thought.fromString(
                  //         "",
                  //         Provider.of<AuthProvider>(context).username,
                  //         true,
                  //         title: "Good morning")),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  ConstrainedBox columnOfThings(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height - 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
              visible: !Provider.of<ThoughtsProvider>(context).hasTopOfMind,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: const SectionHeader(text: "Think something"),
              )),

          // Top of mind divider
          Visibility(
              visible: Provider.of<ThoughtsProvider>(context).hasTopOfMind,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: const SectionHeader(text: "Top of Mind", waves: true),
              )),

          // The top of mind thought
          Visibility(
            visible: Provider.of<ThoughtsProvider>(context).hasTopOfMind,
            child: Stack(
                // Stack settings
                alignment: Alignment.topLeft,
                clipBehavior: Clip.none,

                // Stack children
                children: [
                  MarkdownThought(
                    // type: MarkdownDisplayType,
                    thought: getTopOfMind(context) ??
                        Thought.fromString(
                            "testing", "this is a testing thought", true),
                    viewOnly: true,
                    noTitle: true,
                  ),

                  // // X button on top left to close top of mind
                  // Positioned(
                  //   top: -16,
                  //   left: 0,
                  //   child: IconButton(
                  //     icon: const Icon(Icons.close),
                  //     onPressed: () {
                  //       // Remove the top of mind thought
                  //       Provider.of<ThoughtsProvider>(context, listen: false)
                  //           .setTopOfMind(null);
                  //     },
                  //   ),
                  // ),
                ]),
          ),

          // The main text box
          thinkBox(context),

          // Widget for the action bar
          ActionBar(),

          // Top of mind divider
          Visibility(
              visible: getTopOfMind(context) != null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const SectionHeader(text: "The Stream"),
              )),

          // The rest of the thoughts
          ListView.builder(
            shrinkWrap: true,
            itemCount: Provider.of<ThoughtsProvider>(context).thoughts.length,
            itemBuilder: (context, index) {
              return Container(
                color: Colors.red.withOpacity(
                    Provider.of<ThoughtsProvider>(context)
                            .thoughts[index]
                            .cosineSimilarity ??
                        1),
                child: MarkdownThought(
                  // type: MarkdownDisplayType,
                  thought:
                      Provider.of<ThoughtsProvider>(context).thoughts[index],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Visibility thinkBox(BuildContext context) {
    return Visibility(
      visible: Provider.of<AuthProvider>(context).isLoggedIn &&
          Provider.of<AuthProvider>(context).username != "",
      child: MainTextField(
          primaryController: _primaryController,
          onThoughtSubmitted: (String body) {
            // If the body is empty, do nothing
            if (body.isEmpty) {
              return;
            }

            // Create a new thought
            final thought = Thought.fromString(
                body,
                Provider.of<AuthProvider>(context, listen: false).username,
                Provider.of<ComindColorsNotifier>(context, listen: false)
                    .publicMode);

            // Send the thought
            saveThought(context, thought, newThought: true).then((value) {
              // Add the thought to the providerthis
              Provider.of<ThoughtsProvider>(context, listen: false)
                  .addThought(thought);

              // Search for related thoughts
              searchThoughts(context, thought.body, associatedId: thought.id)
                  .then((value) {
                // Add the related thoughts to the provider
                Provider.of<ThoughtsProvider>(context, listen: false)
                    .addThoughts(value);

                // Update the UI
                // setState(() {
                //   relatedThoughts = value;
                // });
              });

              // Lastly, update the UI
              setState(() {
                Provider.of<ThoughtsProvider>(context, listen: false)
                    .setTopOfMind(thought);
              });
            });
          }),
    );
  }

  bool showSideColumns(BuildContext context) =>
      MediaQuery.of(context).size.width > 800;
  // MediaQuery.of(context).size.width > 800 && getTopOfMind(context) != null;

  //
  // Column width methods
  //
  double leftColumnWidth(BuildContext context) {
    return (MediaQuery.of(context).size.width -
            centerColumnWidth(context) -
            25) /
        2;
  }

  double centerColumnWidth(BuildContext context) {
    return MediaQuery.of(context).size.width > 550
        ? 550
        : MediaQuery.of(context).size.width;
  }

  double rightColumnWidth(BuildContext context) {
    return (MediaQuery.of(context).size.width -
            centerColumnWidth(context) -
            25) /
        2;
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.text,
    this.style,
    this.waves = true,
  });

  final String text;
  final TextStyle? style;
  final bool waves;

  @override
  Widget build(BuildContext context) {
    const outsidePadding = 8.0;
    const insidePadding = 0.0;
    const cineEdgeInsetsLeft =
        EdgeInsets.fromLTRB(outsidePadding, 0, insidePadding, 0);
    const cineEdgeInsetsRight =
        EdgeInsets.fromLTRB(insidePadding, 0, outsidePadding, 0);

    // CineWave shape parameters
    const double waveAmplitude = 3.0;
    const double waveFrequency = 10;

    // Render
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (waves)
        Expanded(
            child: Padding(
          padding: cineEdgeInsetsLeft,
          child: CineWave(
            amplitude: waveAmplitude,
            frequency: waveFrequency,
          ),
        )),
      Text(
        text,
        style: style ??
            Provider.of<ComindColorsNotifier>(context)
                .currentColors
                .textTheme
                .titleMedium,
      ),
      if (waves)
        Expanded(
            child: Padding(
          padding: cineEdgeInsetsRight,
          child: CineWave(
            amplitude: waveAmplitude,
            frequency: waveFrequency,
            goLeft: true,
          ),
        )),
    ]);
  }
}

class ActionBar extends StatelessWidget {
  const ActionBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Settings button
          HoverIconButton(
            size: 18,
            icon: Icons.settings,
            onPressed: () {
              // TODO: Implement back button functionality
            },
          ),

          // Public / private button
          HoverIconButton(
            size: 18,
            icon: Provider.of<ComindColorsNotifier>(context).publicMode
                ? Icons.public
                : Icons.lock,
            onPressed: () {
              Provider.of<ComindColorsNotifier>(context, listen: false)
                  .togglePublicMode(
                      !Provider.of<ComindColorsNotifier>(context, listen: false)
                          .publicMode);
            },
          ),

          // Color picker button
          HoverIconButton(
            size: 18,
            icon: Icons.color_lens,
            onPressed: () async {
              colorDialog(context).then((value) {
                Provider.of<ComindColorsNotifier>(context, listen: false)
                    .modifyColors(value);
              });
            },
          ),
        ],
      ),
    );
  }
}
