import 'dart:math';

import 'package:comind/api.dart';
import 'package:comind/bottom_sheet.dart';
import 'package:comind/cine_wave.dart';
import 'package:comind/colors.dart';
import 'package:comind/hover_icon_button.dart';
import 'package:comind/input_field.dart';
import 'package:comind/main.dart';
import 'package:comind/main_layout.dart';
import 'package:comind/markdown_display.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/providers.dart';
import 'package:comind/soul_blob.dart';
import 'package:comind/text_button.dart';
import 'package:comind/text_button_simple.dart';
import 'package:comind/types/thought.dart';
import 'package:comind/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // List of related thoughts
  List<Thought> relatedThoughts = [];

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
      addTopOfMind(context, topOfMind);
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

              if (authProvider.isLoggedIn) {
                return mainStream(constraints, context);
              } else {
                return MainLayout(
                    middleColumn: Column(children: [
                  coThought(
                      context, "I see that you're not logged in!", "Howdy"),

                  // Login button
                  TextButtonSimple(
                      text: "Log in",
                      // Navigate to login page.
                      onPressed: () {
                        Navigator.pushNamed(context, "/login");
                      }),
                ]));
              }
            },
          );
        },
      ),
    );
  }

  bool _hover = false;
  Widget leftColumn(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEnterEvent event) {
        setState(() {
          _hover = true;
        });
      },
      onExit: (PointerExitEvent event) {
        setState(() {
          _hover = false;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Action row under the text box
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Opacity(
              opacity: _hover ? 1 : .3,
              child: Wrap(direction: Axis.vertical, children: [
                // // Color picker
                // ColorPicker(onColorSelected: (Color color) {
                //   Provider.of<ComindColorsNotifier>(context, listen: false)
                //       .modifyColors(color);
                // }),

                Text("Menu", style: getTextTheme(context).titleMedium),

                const SizedBox(height: 0),

                // Public/private button
                ComindTextButton(
                    lineLocation: LineLocation.left,
                    text: Provider.of<ComindColorsNotifier>(context).publicMode
                        ? "Public"
                        : "Private",
                    onPressed: () {
                      Provider.of<ComindColorsNotifier>(context, listen: false)
                          .togglePublicMode(!Provider.of<ComindColorsNotifier>(
                                  context,
                                  listen: false)
                              .publicMode);
                    }),

                // Clear top of mind
                ComindTextButton(
                    lineLocation: LineLocation.left,
                    text: "Clear",
                    onPressed: () {
                      Provider.of<ThoughtsProvider>(context, listen: false)
                          .clear();

                      // Remove related thoughts
                      relatedThoughts.clear();
                    }),

                // Color picker button
                ComindTextButton(
                    lineLocation: LineLocation.left,
                    text: "Color",
                    onPressed: () async {
                      Color color = await colorDialog(context);
                      Provider.of<ComindColorsNotifier>(context, listen: false)
                          .modifyColors(color);
                    }),

                // Dark mode
                ComindTextButton(
                    lineLocation: LineLocation.left,
                    text: "Dark mode",
                    onPressed: () {
                      Provider.of<ComindColorsNotifier>(context, listen: false)
                          .toggleTheme(!Provider.of<ComindColorsNotifier>(
                                  context,
                                  listen: false)
                              .darkMode);
                    }),

                // Login button
                Visibility(
                  visible: !Provider.of<AuthProvider>(context).isLoggedIn,
                  child: ComindTextButton(
                      lineLocation: LineLocation.left,
                      text: "Log in",
                      // Navigate to login page.
                      onPressed: () {
                        Navigator.pushNamed(context, "/login");
                      }),
                ),

                // Sign up button
                Visibility(
                  visible: !Provider.of<AuthProvider>(context).isLoggedIn,
                  child: ComindTextButton(
                      lineLocation: LineLocation.left,
                      text: "Sign up",
                      // Navigate to sign up page.
                      onPressed: () {
                        Navigator.pushNamed(context, "/signup");
                      }),
                ),

                // Settings
                // Visibility(
                //   child: ComindTextButton(
                // lineLocation: LineLocation.left,
                //       text: "Settings",
                //       onPressed: () {
                //         Navigator.pushNamed(
                //             context, "/settings");
                //       }),
                // ),

                const SizedBox(height: 20),
                Text("Dev buttons", style: getTextTheme(context).titleMedium),

                // Debug button to add a top of mind thought
                Visibility(
                  visible: true,
                  child: ComindTextButton(
                      lineLocation: LineLocation.left,
                      text: "TOM",
                      onPressed: () {
                        Provider.of<ThoughtsProvider>(context, listen: false)
                            .addTopOfMind(Thought.fromString(
                                "I'm happy to have you here :smiley:",
                                "Co",
                                true,
                                title: "Welcome to comind"));
                      }),
                ),

                const SizedBox(height: 20),
                Text("Other stuff", style: getTextTheme(context).titleMedium),

                // Logout button
                Visibility(
                  visible: Provider.of<AuthProvider>(context).isLoggedIn,
                  child: ComindTextButton(
                      lineLocation: LineLocation.left,
                      text: "Log out",
                      onPressed: () => {
                            // Clear all thoughts
                            Provider.of<ThoughtsProvider>(context,
                                    listen: false)
                                .clear(),

                            // Remove related thoughts
                            relatedThoughts.clear(),

                            // Logout
                            Provider.of<AuthProvider>(context, listen: false)
                                .logout()
                          }),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget mainStream(BoxConstraints constraints, BuildContext context) {
    return MainLayout(
      leftColumn: leftColumn(context),
      middleColumn: CenterColumn(context),
      // rightColumn: rightColumn(context),
    );

    // return SingleChildScrollView(
    //   child: ConstrainedBox(
    //     constraints: BoxConstraints(
    //       minHeight: constraints.maxHeight,
    //     ),
    //     child: Row(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [

    //         // // Center column
    //         // CenterColumn(context),

    //         // // Right column
    //         // Visibility(
    //           visible: showSideColumns(context),
    //           child: SizedBox(
    //             width: rightColumnWidth(context),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               mainAxisAlignment: MainAxisAlignment.start,
    //               children: [
    //                 // Text("Notifications",
    //                 //     style: getTextTheme(context).titleMedium),
    //                 Text("", style: getTextTheme(context).titleMedium),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  // ignore: non_constant_identifier_names
  Column CenterColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
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
      ],
    );
  }

  Widget columnOfThings(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
            visible: !Provider.of<ThoughtsProvider>(context).hasTopOfMind,
            child: Column(
              children: [
                // Spacer
                SizedBox(
                    height: MediaQuery.of(context).size.height <= 400
                        ? 0
                        : MediaQuery.of(context).size.height <= 600
                            ? 64
                            : 128),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 8, 0, 32),
                  child: SectionHeader(text: " THINK SOMETHING ", waves: false),
                ),
              ],
            )),

        // Top of mind divider
        Visibility(
            visible: Provider.of<ThoughtsProvider>(context).hasTopOfMind,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
              child: SectionHeader(text: " Top of Mind ", waves: false),
            )),

        // Top of mind builder (use brainbuffer)
        // The rest of the thoughts
        ListView.builder(
          shrinkWrap: true,
          itemCount: Provider.of<ThoughtsProvider>(context).brainBuffer.length,
          // itemCount: relatedThoughts.length,
          itemBuilder: (context, index) {
            return MarkdownThought(
              // type: MarkdownDisplayType,
              thought:
                  Provider.of<ThoughtsProvider>(context).brainBuffer[index],
              type: MarkdownDisplayType.topOfMind,
              // TODO this should maybe link to all thoughts in the brain buffer
              parentThought:
                  getTopOfMind(context)?.id, // Link to most recent thought
            );
          },
        ),

        // // The top of mind thought
        // Visibility(
        //   visible: Provider.of<ThoughtsProvider>(context).hasTopOfMind,
        //   child: Stack(
        //       // Stack settings
        //       alignment: Alignment.topLeft,
        //       clipBehavior: Clip.none,

        //       // Stack children
        //       children: [
        //         MarkdownThought(
        //           // type: MarkdownDisplayType,
        //           thought: getTopOfMind(context) ??
        //               Thought.fromString(
        //                   "testing", "this is a testing thought", true),
        //           viewOnly: true,
        //           noTitle: true,
        //         ),
        //       ]),
        // ),

        // The main text box
        thinkBox(context),

        // Widget for the action bar.
        // padding is larger with no top of mind thought
        Padding(
          padding: getTopOfMind(context) == null
              ? const EdgeInsets.fromLTRB(0, 32, 0, 0)
              : const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: const ActionBar(),
        ),

        // Top of mind divider
        Visibility(
            visible: getTopOfMind(context) != null,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: SectionHeader(text: " STREAM ", waves: false),
            )),

        // The rest of the thoughts
        ListView.builder(
          shrinkWrap: true,
          // itemCount: Provider.of<ThoughtsProvider>(context).thoughts.length,
          itemCount: relatedThoughts.length,
          itemBuilder: (context, index) {
            return MarkdownThought(
              // type: MarkdownDisplayType,
              thought: relatedThoughts[index],
              linkable: true,
              parentThought: getTopOfMind(context)?.id,
              // thought: Provider.of<ThoughtsProvider>(context).thoughts[index],
            );
          },
        ),
      ],
    );
  }

  Visibility thinkBox(BuildContext context) {
    return Visibility(
      visible: Provider.of<AuthProvider>(context).isLoggedIn &&
          Provider.of<AuthProvider>(context).username != "",
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: MainTextField(
              primaryController: _primaryController,

              // Thought submission function
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
                  searchThoughts(context, thought.body,
                          associatedId: thought.id)
                      .then((value) {
                    // Add the related thoughts to the provider
                    Provider.of<ThoughtsProvider>(context, listen: false)
                        .addThoughts(value);

                    // Update the UI
                    setState(() {
                      relatedThoughts = value;
                    });
                  });

                  // Link the thought to the top of mind thought if it exists
                  if (getTopOfMind(context) != null) {
                    linkToTopOfMind(context, thought.id);
                  }

                  // Lastly, update the UI
                  setState(() {
                    Provider.of<ThoughtsProvider>(context, listen: false)
                        .addTopOfMind(thought);
                  });
                });
              }),
        ),
      ]),
    );
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
    const outsidePadding = 0.0;
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
                .titleLarge,
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
          // Color picker
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                await colorDialog(context);
                // Provider.of<ComindColorsNotifier>(context, listen: false)
                //     .modifyColors(color);
              },
              child: // Soul blob
                  Padding(
                padding: const EdgeInsets.all(8.0),
                child: SoulBlob(
                  comindColors:
                      Provider.of<ComindColorsNotifier>(context).currentColors,
                  // primaryColor:
                  //     Provider.of<ComindColorsNotifier>(context).primary,
                  // secondaryColor:
                  //     Provider.of<ComindColorsNotifier>(context).secondary,
                  // tertiaryColor:
                  //     Provider.of<ComindColorsNotifier>(context).tertiary,
                  // backgroundColor:
                  //     Provider.of<ComindColorsNotifier>(context).background,
                ),
              ),
            ),
          ),

          // Public / private button
          TextButtonSimple(
            text: Provider.of<ComindColorsNotifier>(context).publicMode
                ? "Public"
                : "Private",
            // icon: Provider.of<ComindColorsNotifier>(context).publicMode
            //     ? Icons.public
            //     : Icons.lock,
            onPressed: () {
              Provider.of<ComindColorsNotifier>(context, listen: false)
                  .togglePublicMode(
                      !Provider.of<ComindColorsNotifier>(context, listen: false)
                          .publicMode);
            },
          ),

          // Divider
          Expanded(
            child: Container(
                height: 1,
                color: Provider.of<ComindColorsNotifier>(context)
                    .onBackground
                    .withAlpha(100)),
          ),

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

          // // Color picker button
          // HoverIconButton(
          //   size: 18,
          //   icon: Icons.color_lens,
          //   onPressed: () async {
          //     colorDialog(context).then((value) {
          //       Provider.of<ComindColorsNotifier>(context, listen: false)
          //           .modifyColors(value);
          //     });
          //   },
          // ),
        ],
      ),
    );
  }
}
