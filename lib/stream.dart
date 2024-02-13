import 'dart:math';

import 'package:comind/menu_bar.dart';
import 'package:cyclop/cyclop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';
import 'package:line_icons/line_icons.dart';
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

enum Mode { stream, myThoughts, public, consciousness, begin }

// Make a mode-to-title map
Map<Mode, String> modeToTitle = {
  Mode.stream: "Stream",
  Mode.myThoughts: "My thoughts",
  Mode.public: "Public stream",
  Mode.consciousness: "Consciousness",
  Mode.begin: "?",
};

class Stream extends StatefulWidget {
  const Stream({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _StreamState createState() => _StreamState();
}

class _StreamState extends State<Stream> {
  // the text controller
  final _primaryController = TextEditingController();

  // Mode of the stream
  Mode mode = Mode.begin;

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

  // Get the public stream
  void _fetchStream(BuildContext context) async {
    // Replace with your API call
    List<Thought> fetchedThoughts = await getStream(context);

    // Add all thoughts to the provider
    // ignore: use_build_context_synchronously
    Provider.of<ThoughtsProvider>(context, listen: false)
        .addThoughts(fetchedThoughts);

    setState(() {
      // Set mode to public
      mode = Mode.public;
    });
  }

  @override
  void initState() {
    super.initState();

    // Pull in the concepts
    final newConcepts = fetchConcepts(context).then((value) =>
        Provider.of<ConceptsProvider>(context, listen: false)
            .addConcepts(value));
  }

  @override
  Widget build(BuildContext context) {
    // Debug initialize the top of mind thought to coThought
    // topOfMind = Thought.fromString(
    //     "I'm happy to have you here :smiley:", "Co", true,
    //     title: "Welcome to comind");

    // if (false) {
    if (!Provider.of<AuthProvider>(context).isLoggedIn) {
      return Scaffold(
          appBar: null,
          // Bottom sheet
          bottomSheet: const ComindBottomSheet(),
          body: MainLayout(middleColumn: underConstructionWidget(context)));
    } else {
      return Scaffold(
        // App bar
        appBar: comindAppBar(
            context,
            modeToTitle[mode] != null
                ? appBarTitle(modeToTitle[mode]!, context)
                : appBarTitle("Stream", context)),

        // Drawer
        drawer: MenuDrawer(),

        // Bottom sheet
        bottomSheet: mode == Mode.begin ? const ComindBottomSheet() : null,
        // bottomSheet: Container(
        //   color: Colors.red,
        //   height: 120,
        //   width: 800,
        //   child: Column(
        //     children: [
        //       // The main text box
        //       thinkBox(context),

        //       // Widget for the action bar.
        //       actionBar(context),

        //       // // Padding(
        //       // //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        //       // //   child: ComindBottomSheet(),
        //       // // ),
        //       // Padding(
        //       //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        //       //   child: ComindBottomSheet(),
        //       // ),
        //     ],
        //   ),
        // ),

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
        _hover = true;
      },
      onExit: (_) {
        _hover = false;
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
                    noBackground: true,
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

                // Load public thoughts
                TextButtonSimple(
                    noBackground: true,
                    text: "Load public",
                    onPressed: () {
                      // Clear top of mind
                      Provider.of<ThoughtsProvider>(context, listen: false)
                          .clear();

                      // Fetch related thoughts
                      _fetchStream(context);

                      // Set mode to stream
                      mode = Mode.public;
                    }),

                // My thoughts
                TextButtonSimple(
                    noBackground: true,
                    text: "My thoughts",
                    onPressed: () {
                      // Clear top of mind
                      Provider.of<ThoughtsProvider>(context, listen: false)
                          .clear();

                      // Fetch related thoughts
                      fetchUserThoughts();

                      // Set mode to mythoughts
                      mode = Mode.myThoughts;
                    }),

                // Clear top of mind
                TextButtonSimple(
                    noBackground: true,
                    text: "Clear",
                    onPressed: () {
                      Provider.of<ThoughtsProvider>(context, listen: false)
                          .clear();
                    }),

                // Color picker button
                TextButtonSimple(
                    noBackground: true,
                    text: "Color",
                    onPressed: () async {
                      Color color = await colorDialog(context);
                      Provider.of<ComindColorsNotifier>(context, listen: false)
                          .modifyColors(color);
                    }),

                // Dark mode
                TextButtonSimple(
                    noBackground: true,
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
                      noBackground: true,
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
                      noBackground: true,
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

                // const SizedBox(height: 20),
                // Opacity(
                //     opacity: .7,
                //     child: Text("Dev buttons",
                //         style: getTextTheme(context).titleMedium)),

                // // Debug button to add a top of mind thought
                // Visibility(
                //   visible: true,
                //   child: TextButtonSimple(
                //       text: "TOM",
                //       noBackground: true,
                //       onPressed: () {
                //         Provider.of<ThoughtsProvider>(context, listen: false)
                //             .addTopOfMind(
                //                 context,
                //                 Thought.fromString(
                //                     "I'm happy to have you here :smiley:",
                //                     "Co",
                //                     true,
                //                     title: "Welcome to comind"));
                //       }),
                // ),

                const SizedBox(height: 20),
                Opacity(
                    opacity: .7,
                    child: Text("Other stuff",
                        style: getTextTheme(context).titleMedium)),

                // Logout button
                Visibility(
                  visible: Provider.of<AuthProvider>(context).isLoggedIn,
                  child: TextButtonSimple(
                      text: "Log out",
                      noBackground: true,
                      onPressed: () => {
                            // Clear all thoughts
                            Provider.of<ThoughtsProvider>(context,
                                    listen: false)
                                .clear(),

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

  Widget actionBar(BuildContext context) {
    // Cosmetic settings
    const double actionIconSize = 28;

    // The action bar container
    var container = Container(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          // verticalDirection: VerticalDirection.down,
          children: [
            // Settings button
            HoverIconButton(
              size: actionIconSize,
              icon: LineIcons.cog,
              onPressed: () {
                // TODO: #18 Implement settings and user preferences
              },
            ),

            // Concept button
            HoverIconButton(
              size: actionIconSize,
              icon: LineIcons.hashtag,
              onPressed: () {
                Navigator.pushNamed(context, "/concepts");
              },
            ),

            // Most recent button
            HoverIconButton(
                size: actionIconSize,
                icon: LineIcons.clock,
                onPressed: () {
                  // Clear top of mind
                  Provider.of<ThoughtsProvider>(context, listen: false).clear();

                  // Fetch related thoughts
                  fetchUserThoughts();

                  // Set mode to mythoughts
                  mode = Mode.myThoughts;
                }),

            Material(
              borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  await colorDialog(context);
                },
                borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
                child: // Soul blob
                    Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SoulBlob(
                    comindColors: Provider.of<ComindColorsNotifier>(context)
                        .currentColors,
                  ),
                ),
              ),
            ),

            // Dark mode button
            HoverIconButton(
              size: actionIconSize,
              icon: Provider.of<ComindColorsNotifier>(context).darkMode
                  ? LineIcons.moon
                  : LineIcons.sun,
              onPressed: () {
                Provider.of<ComindColorsNotifier>(context, listen: false)
                    .toggleTheme(!Provider.of<ComindColorsNotifier>(context,
                            listen: false)
                        .darkMode);
              },
            ),

            // Public / private button
            HoverIconButton(
              // hoverText: Provider.of<ComindColorsNotifier>(context).publicMode
              //     ? "Public mode"
              //     : "Private mode",
              size: actionIconSize,
              icon: Provider.of<ComindColorsNotifier>(context).publicMode
                  ? LineIcons.globe
                  : LineIcons.lock,
              onPressed: () {
                Provider.of<ComindColorsNotifier>(context, listen: false)
                    .togglePublicMode(!Provider.of<ComindColorsNotifier>(
                            context,
                            listen: false)
                        .publicMode);
              },
            ),

            // Clear button
            HoverIconButton(
              size: actionIconSize,
              icon: LineIcons.broom,
              onPressed: () {
                Provider.of<ThoughtsProvider>(context, listen: false).clear();
              },
            ),

            // // Color picker button
            // HoverIconButton(
            //   size: actionIconSize,
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
      ),
    );
    return container;
  }

  Widget mainStream(BoxConstraints constraints, BuildContext context) {
    return MainLayout(
      leftColumn: leftColumn(context),
      middleColumn: CenterColumn(context),
      // rightColumn: rightColumn(context),
    );
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
    var brainBufferLength =
        Provider.of<ThoughtsProvider>(context).brainBuffer.length;
    var displaySize = ThoughtsProvider.maxBufferDisplaySize;

    var min2 = min(displaySize, brainBufferLength);
    var overflow =
        brainBufferLength > displaySize ? brainBufferLength - displaySize : 0;
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Top of mind builder (use brainbuffer)
        Visibility(
          visible:
              Provider.of<ThoughtsProvider>(context).brainBuffer.isNotEmpty,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            // itemCount: Provider.of<ThoughtsProvider>(context).brainBuffer.length,
            itemCount: min2,
            // itemCount: relatedThoughts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: MarkdownThought(
                  // If the top of mind has more than the max buffer display size,
                  // then display only the most recent max buffer display size thoughts.
                  //
                  // The most recent thought is the last in the buffer.
                  // Example:
                  //
                  // Buffer cap is 3, have 5 thoughts. We want to display the last 3,
                  // thoughts 3, 4, and 5.
                  //
                  // Indices are 0-based, so the last thought is at index 4.
                  //
                  // The first thought (at the top) to display is at index 5 - 3 = 2.
                  // The last thought (at the bottom) to display is at index 5 - 1 = 4.
                  //
                  thought: Provider.of<ThoughtsProvider>(context)
                      .brainBuffer[overflow + index],

                  type: MarkdownDisplayType.topOfMind,

                  parentThought:
                      getTopOfMind(context)?.id, // Link to most recent thought
                ),
              );
            },
          ),
        ),

        // The main text box
        thinkBox(context),

        // Widget for the action bar.
        actionBar(context),

        Visibility(
          visible: Provider.of<ThoughtsProvider>(context).thoughts.isNotEmpty,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        mode = Mode.consciousness;
                        // Provider.of<ComindColorsNotifier>(context, listen: false)
                        //     .modifyColors(color);
                      },
                      child: // Soul blob
                          ComindTextButton(
                        lineLocation: LineLocation.bottom,
                        onPressed: () {
                          mode = Mode.consciousness;
                        },
                        text: '',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // The rest of the thoughts, stream
        Visibility(
          visible: getTopOfMind(context) != null ||
              (mode == Mode.public &&
                  Provider.of<ThoughtsProvider>(context).thoughts.isNotEmpty) ||
              (mode == Mode.myThoughts &&
                  Provider.of<ThoughtsProvider>(context).thoughts.isNotEmpty),
          child: ListView.builder(
            shrinkWrap: true,
            dragStartBehavior: DragStartBehavior.start,
            physics: const NeverScrollableScrollPhysics(),
            // itemCount: Provider.of<ThoughtsProvider>(context).thoughts.length,
            itemCount: Provider.of<ThoughtsProvider>(context).thoughts.length,
            itemBuilder: (context, index) {
              return MarkdownThought(
                thought: Provider.of<ThoughtsProvider>(context).thoughts[index],
                linkable: true,
                parentThought: getTopOfMind(context)?.id,
                // thought: Provider.of<ThoughtsProvider>(context).thoughts[index],
              );
            },
          ),
        ),
      ],
    );
  }

  Row soulBlobRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Seconday bar. flex 2 to take up 1/3
        Expanded(
          flex: 2,
          child: ColorBar(
              colorChoice: ColorChoice.secondary,
              comindColors:
                  Provider.of<ComindColorsNotifier>(context).currentColors),
        ),

        // Primary bar
        Expanded(
          child: ColorBar(
              colorChoice: ColorChoice.primary,
              comindColors:
                  Provider.of<ComindColorsNotifier>(context).currentColors),
        ),

        // Color picker
        Material(
          borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              await colorDialog(context);
            },
            borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
            child: // Soul blob
                Padding(
              padding: const EdgeInsets.all(8.0),
              child: SoulBlob(
                comindColors:
                    Provider.of<ComindColorsNotifier>(context).currentColors,
              ),
            ),
          ),
        ),

        // Primary bar, part 2
        Expanded(
          child: ColorBar(
              comindColors:
                  Provider.of<ComindColorsNotifier>(context).currentColors,
              colorChoice: ColorChoice.primary),
        ),

        // Tertiary bar
        Expanded(
          flex: 2,
          child: ColorBar(
              comindColors:
                  Provider.of<ComindColorsNotifier>(context).currentColors,
              colorChoice: ColorChoice.tertiary),
        ),
      ],
    );
  }

  Stack thinkBox(BuildContext context) {
    return Stack(children: [
      Padding(
        padding: Provider.of<ThoughtsProvider>(context).hasTopOfMind
            ? const EdgeInsets.fromLTRB(0, 0, 0, 0)
            : const EdgeInsets.fromLTRB(0, 32, 0, 0),
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

                // Lastly, update the UI
                setState(() {
                  Provider.of<ThoughtsProvider>(context, listen: false)
                      .addTopOfMind(context, thought);
                });
              });
            }),
      ),
    ]);
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
