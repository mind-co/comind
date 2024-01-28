import 'dart:math';

import 'package:logging/logging.dart';
import 'package:comind/api.dart';
import 'package:comind/bottom_sheet.dart';
import 'package:comind/colors.dart';
import 'package:comind/hover_icon_button.dart';
import 'package:comind/input_field.dart';
import 'package:comind/main.dart';
import 'package:comind/main_layout.dart';
import 'package:comind/markdown_display.dart';
import 'package:comind/misc/comind_logo.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/providers.dart';
import 'package:comind/section.dart';
import 'package:comind/soul_blob.dart';
import 'package:comind/text_button.dart';
import 'package:comind/text_button_simple.dart';
import 'package:comind/types/thought.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

enum Mode { stream, myThoughts }

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

  // Mode of the stream
  Mode mode = Mode.myThoughts;

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

  // Fetch user thoughts
  void fetchUserThoughts() async {
    while (mounted &&
        !Provider.of<AuthProvider>(context, listen: false).isLoggedIn) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Replace with your API call
    List<Thought> fetchedThoughts = await fetchThoughts(context);

    setState(() {
      // Add all thoughts to the provider
      // ignore: use_build_context_synchronously
      Provider.of<ThoughtsProvider>(context, listen: false)
          .addThoughts(fetchedThoughts);
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

    if (false) {
      // if (!Provider.of<AuthProvider>(context).isLoggedIn) {
      return Scaffold(
          appBar: null,
          // Bottom sheet
          bottomSheet: const ComindBottomSheet(),
          body: MainLayout(middleColumn: underConstructionWidget(context)));
    } else {
      return Scaffold(
        // App bar
        appBar: comindAppBar(context),

        // Bottom sheet
        bottomSheet: const ComindBottomSheet(),

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
  }

  bool _hover = true;
  Widget leftColumn(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hover = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hover = false;
        });
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 90),
        opacity: _hover ? 1 : .2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Wrap(direction: Axis.vertical, children: [
                // // Color picker
                // ColorPicker(onColorSelected: (Color color) {
                //   Provider.of<ComindColorsNotifier>(context, listen: false)
                //       .modifyColors(color);
                // }),

                Opacity(
                    opacity: .7,
                    child:
                        Text("Menu", style: getTextTheme(context).titleMedium)),

                // fills the left column so that button expansions don't do anything
                const SizedBox(height: 0, width: 200),

                // Public/private button
                TextButtonSimple(
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

                // My thoughts
                TextButtonSimple(
                    text: "My thoughts",
                    onPressed: () {
                      // Clear top of mind
                      Provider.of<ThoughtsProvider>(context, listen: false)
                          .clear();

                      // Remove related thoughts
                      relatedThoughts.clear();

                      // Fetch related thoughts
                      fetchUserThoughts();

                      // Set mode to mythoughts
                      mode = Mode.myThoughts;
                    }),

                // Clear top of mind
                TextButtonSimple(
                    text: "Clear",
                    onPressed: () {
                      Provider.of<ThoughtsProvider>(context, listen: false)
                          .clear();

                      // Remove related thoughts
                      relatedThoughts.clear();
                    }),

                // Color picker button
                TextButtonSimple(
                    text: "Color",
                    onPressed: () async {
                      Color color = await colorDialog(context);
                      Provider.of<ComindColorsNotifier>(context, listen: false)
                          .modifyColors(color);
                    }),

                // Dark mode
                TextButtonSimple(
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
                  child: TextButtonSimple(
                      text: "Log in",
                      // Navigate to login page.
                      onPressed: () {
                        Navigator.pushNamed(context, "/login");
                      }),
                ),

                // Sign up button
                Visibility(
                  visible: !Provider.of<AuthProvider>(context).isLoggedIn,
                  child: TextButtonSimple(
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
                Opacity(
                    opacity: .7,
                    child: Text("Dev buttons",
                        style: getTextTheme(context).titleMedium)),

                // Debug button to add a top of mind thought
                Visibility(
                  visible: true,
                  child: TextButtonSimple(
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
                Opacity(
                    opacity: .5,
                    child: Text("Other stuff",
                        style: getTextTheme(context).titleMedium)),

                // Logout button
                Visibility(
                  visible: Provider.of<AuthProvider>(context).isLoggedIn,
                  child: TextButtonSimple(
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
          ],
        ),
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
                // SizedBox(
                //     height: MediaQuery.of(context).size.height <= 400
                //         ? 0
                //         : MediaQuery.of(context).size.height <= 600
                //             ? 64
                //             : 128),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: SectionHeader(
                      text:
                          " HI ${Provider.of<AuthProvider>(context).username} ",
                      waves: false),
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
        const ActionBar(),

        // Top of mind divider
        Visibility(
            visible: getTopOfMind(context) != null,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: SectionHeader(text: " STREAM ", waves: false),
            )),

        // The rest of the thoughts
        Visibility(
          visible: getTopOfMind(context) != null || mode == Mode.myThoughts,
          child: Section(
            text: "Stream",
            waves: false,
            children: ListView.builder(
              shrinkWrap: true,
              // itemCount: Provider.of<ThoughtsProvider>(context).thoughts.length,
              itemCount: Provider.of<ThoughtsProvider>(context).thoughts.length,
              itemBuilder: (context, index) {
                return MarkdownThought(
                  thought:
                      Provider.of<ThoughtsProvider>(context).thoughts[index],
                  linkable: true,
                  parentThought: getTopOfMind(context)?.id,
                  // thought: Provider.of<ThoughtsProvider>(context).thoughts[index],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Stack thinkBox(BuildContext context) {
    return Stack(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: MainTextField(
            primaryController: _primaryController,

            // Thought submission function
            onThoughtSubmitted: (String body) {
              // If the body is empty, do nothing
              Logger.root.info("Body: $body");
              if (body.isEmpty) {
                // Log the error
                Logger.root.warning("Empty thought submitted");
                return;
              }

              // Create a new thought
              final thought = Thought.fromString(
                  body,
                  Provider.of<AuthProvider>(context, listen: false).username,
                  Provider.of<ComindColorsNotifier>(context, listen: false)
                      .publicMode);

              // Log the new ID
              Logger.root.info("{'new_id':${thought.id}}, 'body':'$body'");

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

                  // // Update the UI
                  // setState(() {
                  //   relatedThoughts = value;
                  // });
                });

                // Link the thought to the top of mind thought if it exists
                if (getTopOfMind(context) != null) {
                  linkToTopOfMind(context, thought.id);
                }

                // Lastly, update the UI
                Provider.of<ThoughtsProvider>(context, listen: false)
                    .addTopOfMind(thought);
              });
            }),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
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

Widget underConstructionWidget(BuildContext context) {
  // Get font size based on screen size
  double fontSize = MediaQuery.of(context).size.width <= 400
      ? 32
      : MediaQuery.of(context).size.width <= 600
          ? 48
          : 64;

  // Whether to use the short logo
  bool shortLogo = MediaQuery.of(context).size.width <= 550;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
        child:
            Text("Howdy, welcome to", style: getTextTheme(context).bodyLarge),
      ),

      // Short logo
      if (shortLogo)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ComindShortLogo(
              key: const Key("shortLogo"),
              colors: Provider.of<ComindColorsNotifier>(context)),
        ),

      // Long logo
      if (!shortLogo)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ComindLogo(
              key: const Key("longLogo"),
              colors: Provider.of<ComindColorsNotifier>(context)),
        ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("You might want in but currently this",
            style: getTextTheme(context).bodyLarge),
      ),
      Text("WHOLE",
          style: GoogleFonts.bungeeShadeTextTheme(getTextTheme(context))
              .displayLarge!
              .copyWith(fontSize: fontSize)),
      Text("THING",
          style: GoogleFonts.bungeeShadeTextTheme(getTextTheme(context))
              .displayLarge!
              .copyWith(fontSize: fontSize)),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("is a ", style: getTextTheme(context).bodyLarge),
      ),
      // Text("COMPLETE",
      //     style: getTextTheme(context)
      //         .displayLarge!
      //         .copyWith(fontFamily: "bunpop", fontSize: fontSize)),
      // Text("MESS",
      //     style: getTextTheme(context)
      //         .displayLarge!
      //         .copyWith(fontFamily: "bunpop", fontSize: fontSize)),
      Text("COMPLETE",
          style: GoogleFonts.bungeeShadeTextTheme(getTextTheme(context))
              .displayLarge!
              .copyWith(fontSize: fontSize)),
      Text("MESS",
          style: GoogleFonts.bungeeShadeTextTheme(getTextTheme(context))
              .displayLarge!
              .copyWith(fontSize: fontSize)),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("(it will work at some point I promise)",
            style: getTextTheme(context).bodyLarge),
      ),

      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("While you're waiting, check out our Patreon",
            style: getTextTheme(context).bodyLarge),
      ),

      // Patreon link
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 128),
        child: ComindTextButton(
            lineLocation: LineLocation.bottom,
            onPressed: () {
              launchUrlString("https://www.patreon.com/comind");
            },
            fontSize: fontSize * 3 / 5,
            text: "Patreon"),
      ),
    ],
  );
}
