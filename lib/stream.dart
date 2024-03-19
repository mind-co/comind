import 'dart:math';

import 'package:comind/menu_bar.dart';
import 'package:comind/notification_display.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:line_icons/line_icons.dart';
import 'package:logging/logging.dart';
import 'package:comind/api.dart';
import 'package:comind/bottom_sheet.dart';
import 'package:comind/colors.dart';
import 'package:comind/hover_icon_button.dart';
import 'package:comind/input_field.dart';
import 'package:comind/main.dart';
import 'package:comind/main_layout.dart';
import 'package:comind/markdown_display_line.dart'; // new trial display
// import 'package:comind/markdown_display.dart'; // og display
import 'package:comind/misc/comind_logo.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/providers.dart';
import 'package:comind/soul_blob.dart';
import 'package:comind/text_button.dart';
import 'package:comind/text_button_simple.dart';
import 'package:comind/types/thought.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

enum Mode { stream, myThoughts, stack, pings, concepts, empty }

// Make a mode-to-title map
Map<Mode, String> modeToTitle = {
  Mode.stream: "Stream",
  Mode.myThoughts: "My thoughts",
  Mode.stack: "Stack",
  Mode.pings: "Pings",
  Mode.concepts: "Concepts",
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

  Thought startPageThought = Thought.fromString(
      "I'm happy to have you here :smiley:", "Co", true,
      title: "Welcome to comind");

  Mode mode = Mode.empty;

  get actionBarButtonFontScalar => 0.8;

  // Fetch user thoughts
  void fetchUserThoughts() async {
    while (mounted &&
        !Provider.of<AuthProvider>(context, listen: false).isLoggedIn) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    List<Thought> fetchedThoughts = await fetchThoughts(context);
    setState(() {
      // Add all thoughts to the provider
      // ignore: use_build_context_synchronously
      Provider.of<ThoughtsProvider>(context, listen: false)
          .addThoughts(fetchedThoughts);

      // Stick them in the related thoughts
      Provider.of<ThoughtsProvider>(context, listen: false)
          .setRelatedThoughts(fetchedThoughts);
    });
  }

  // Get the public stream
  void _fetchStream(BuildContext context) async {
    // Replace with your API call
    var thoughtProvider = Provider.of<ThoughtsProvider>(context, listen: false);
    List<Thought> fetchedThoughts = await getStream(context);

    // Add all thoughts to the provider
    // ignore: use_build_context_synchronously
    thoughtProvider.addThoughts(fetchedThoughts);

    // Clear the related thoughts and stick the new thoughts in there
    thoughtProvider.clearRelatedThoughts();

    // Add the thoughts to the related thoughts
    thoughtProvider.setRelatedThoughts(fetchedThoughts);

    setState(() {
      // Set mode to public
      mode = Mode.stream;
    });
  }

  @override
  void initState() {
    super.initState();

    // Load the start page thought
    // fetchStartPageThought(context).then((value) => {
    //       setState(() {
    //         startPageThought = value;
    //       })
    //     });

    // Pull in the concepts
    fetchConcepts(context).then((newConcepts) {
      Provider.of<ConceptsProvider>(context, listen: false)
          .addConcepts(newConcepts);
    });

    // Fetch notifications
    fetchNotifications(context).then((value) =>
        Provider.of<NotificationsProvider>(context, listen: false)
            .addNotifications(value));
  }

  @override
  Widget build(BuildContext context) {
    // Debug initialize the top of mind thought to coThought
    // topOfMind = Thought.fromString(
    //     "I'm happy to have you here :smiley:", "Co", true,
    //     title: "Welcome to comind");

    // Get the colors notifier
    var colors = Provider.of<ComindColorsNotifier>(context);

    // Retrieve the thought provider.
    var thoughts = Provider.of<ThoughtsProvider>(context);

    // Whether to center the text box
    bool centerTextBox = mode == Mode.empty;

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
        appBar: comindAppBar(context),

        // Drawer
        drawer: MenuDrawer(),

        // Body
        body: Stack(
          children: [
            // Make a box that is at least the size of the screen
            // to catch mouse events
            Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),

            // A screen-sized gradient background
            // Container(
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //       colors: [
            //         colors.currentColors.primary.withAlpha(128),
            //         colors.currentColors.secondary.withAlpha(128),
            //       ],
            //     ),
            //   ),
            // ),

            LayoutBuilder(
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

            // Debug mode on the bottom. Show UI mode
            // Positioned(
            //   bottom: 0,
            //   right: 0,
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.end,
            //       children: [
            //         Text("Mode: ${modeToTitle[mode] ?? "Unknown"}"),
            //         Text(
            //             "Num related thoughts: ${thoughts.relatedThoughts.length}"),
            //         Text(
            //             "Num brain buffer thoughts: ${thoughts.brainBuffer.length}"),
            //         Text("Num thoughts: ${thoughts.thoughts.length}"),
            //       ],
            //     ),
            //   ),
            // ),

            // Text bar at the bottom
            Positioned(
              bottom: 0,
              // centerTextBox ? MediaQuery.of(context).size.height / 2 : 0,
              left: 0,
              right: 0,
              child: Container(
                // color: colors
                //     .currentColors
                //     .primary
                //     .withAlpha(128),
// A screen-sized gradient background
                decoration: BoxDecoration(
                  color: !centerTextBox
                      ? colors.currentColors.colorScheme.background
                      : Colors.transparent,
                  // gradient: LinearGradient(
                  //   begin: Alignment.bottomCenter,
                  //   end: Alignment.topCenter,
                  //   stops: const [0.0, 0.5, 1.0],
                  //   colors: [
                  //     colors.currentColors.colorScheme.background,
                  //     colors.currentColors.colorScheme.background,
                  //     // colors.currentColors.colorScheme.background,
                  //     Colors.transparent,
                  //   ],
                  // ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Text("hey, welcome to"),
                    // ),
                    // ComindLogo(colors: colors),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Text("what are you thinking about?"),
                    // ),
                    thinkBox(context, colors),
                    actionBar(context),
                  ],
                ),
              ),
            ),
          ],
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
                    outlined: false,
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
                TextButtonSimple(
                    noBackground: true,
                    outlined: false,
                    text: "Clear",
                    onPressed: () {
                      Provider.of<ThoughtsProvider>(context, listen: false)
                          .clear();

                      // Clear the related thoughts
                      Provider.of<ThoughtsProvider>(context, listen: false)
                          .clearRelatedThoughts();

                      // Clear the brain buffer
                      Provider.of<ThoughtsProvider>(context, listen: false)
                          .clearBrainBuffer();

                      // Back to begin mode
                      setState(() {
                        mode = Mode.empty;
                      });
                    }),

                // Color picker button
                TextButtonSimple(
                    outlined: false,
                    noBackground: true,
                    text: "Color",
                    onPressed: () async {
                      Color color = await colorDialog(context);
                      Provider.of<ComindColorsNotifier>(context, listen: false)
                          .modifyColors(color);

                      // Notify the server that the colors have changed.
                      // Send the color and the color scheme
                      await sendColors(
                          context,
                          Provider.of<ComindColorsNotifier>(context,
                                  listen: false)
                              .currentColors);
                    }),

                // Dark mode
                TextButtonSimple(
                    outlined: false,
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
                      outlined: false,
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
                      outlined: false,
                      noBackground: true,
                      text: "Sign up",
                      // Navigate to sign up page.
                      onPressed: () {
                        Navigator.pushNamed(context, "/signup");
                      }),
                ),

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
                      outlined: false,
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
    // Get the color notifier
    var colorNotifier =
        Provider.of<ComindColorsNotifier>(context, listen: false);

    // The action bar container
    var container = Container(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
      width: ComindColors.maxWidth,
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 0,
        runAlignment: WrapAlignment.start,
        children: [
          // Notifications
          TextButtonSimple(
            text:
                "${Provider.of<NotificationsProvider>(context).notifications.length} pings",
            fontScalar: actionBarButtonFontScalar,
            onPressed: () {
              // Set the mode to notifications
              mode = Mode.pings;

              // Fetch notifications
              fetchNotifications(context).then((value) =>
                  Provider.of<NotificationsProvider>(context, listen: false)
                      .addNotifications(value));
            },
          ),

          // Concept button
          TextButtonSimple(
            text: "Concepts",
            fontScalar: actionBarButtonFontScalar,
            onPressed: () {
              Navigator.pushNamed(context, "/concepts");
            },
          ),

          // Most recent button
          TextButtonSimple(
              text: "Your thoughts",
              fontScalar: actionBarButtonFontScalar,
              onPressed: () {
                // Clear related thoughts
                Provider.of<ThoughtsProvider>(context, listen: false)
                    .clearRelatedThoughts();

                // Fetch related thoughts
                fetchUserThoughts();

                // Set mode to mythoughts
                setState(() {
                  mode = Mode.myThoughts;
                });
              }),

          // Public thoughts button
          TextButtonSimple(
            text: "The stream",
            fontScalar: actionBarButtonFontScalar,
            onPressed: () {
              // Fetch related thoughts
              _fetchStream(context);

              // Set mode to stream
              setState(() => mode = Mode.stream); // Set mode to stream
            },
          ),

          // Dark mode button
          TextButtonSimple(
            text: colorNotifier.darkMode ? "Light" : "Dark",
            fontScalar: actionBarButtonFontScalar,
            onPressed: () {
              colorNotifier.toggleTheme(!colorNotifier.darkMode);
            },
          ),

          // Public / private button
          TextButtonSimple(
            text: colorNotifier.publicMode ? "Public" : "Private",
            fontScalar: actionBarButtonFontScalar,
            onPressed: () {
              colorNotifier.togglePublicMode(
                  !Provider.of<ComindColorsNotifier>(context, listen: false)
                      .publicMode);
            },
          ),

          // Clear button
          TextButtonSimple(
            text: "Clear",
            fontScalar: actionBarButtonFontScalar,
            onPressed: () {
              Provider.of<ThoughtsProvider>(context, listen: false).clear();
              setState(() {
                mode = Mode.empty;
              });
            },
          ),

          // Brainstacks button
          TextButtonSimple(
            text: "Brainstacks",
            fontScalar: actionBarButtonFontScalar,
            onPressed: () {
              Navigator.pushNamed(context, "/brainstacks");
            },
          ),

          // Log out
          Visibility(
            visible: Provider.of<AuthProvider>(context).isLoggedIn,
            child: TextButtonSimple(
              text: "Log out",
              fontScalar: actionBarButtonFontScalar,
              onPressed: () {
                // Clear all thoughts
                Provider.of<ThoughtsProvider>(context, listen: false).clear();
                Provider.of<AuthProvider>(context, listen: false).logout();
              },
            ),
          ),

          // // Color picker button
          // HoverIconButton(
          //   size: actionIconSize,
          //   icon: Icons.color_lens,
          //   onPressed: () async {
          //     colorDialog(context).then((value) {
          //       colorNotifier
          //           .modifyColors(value);
          //     });
          //   },
          // ),
        ],
      ),
    );
    return container;
  }

  Widget mainStream(BoxConstraints constraints, BuildContext context) {
    return MainLayout(
      // leftColumn: leftColumn(context),
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
    var thoughtProvider = Provider.of<ThoughtsProvider>(context);
    var brainBufferLength = thoughtProvider.brainBuffer.length;
    var displaySize = ThoughtsProvider.maxBufferDisplaySize;

    var min2 = min(displaySize, brainBufferLength);
    var overflow =
        brainBufferLength > displaySize ? brainBufferLength - displaySize : 0;
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        // Top of mind builder (use brainbuffer)
        Visibility(
          visible:
              Provider.of<ThoughtsProvider>(context).brainBuffer.isNotEmpty,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount:
                Provider.of<ThoughtsProvider>(context).brainBuffer.length,
            // itemCount: relatedThoughts.length,
            itemBuilder: (context, index) {
              var buffer = Provider.of<ThoughtsProvider>(context).brainBuffer;
              var thought = buffer[index];
              bool isTopOfMind = index == buffer.length - 1;
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                  thought: thought,

                  type: MarkdownDisplayType.topOfMind,

                  // Uncomment to hide the body unless it's the
                  // top of mind.
                  // showBody: isTopOfMind,

                  parentThought:
                      getTopOfMind(context)?.id, // Link to most recent thought
                ),
              );
            },
          ),
        ),

        // Horizontal divider
        Visibility(
          visible:
              Provider.of<ThoughtsProvider>(context).brainBuffer.isNotEmpty,
          child: const Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Divider(
              color: Colors.white38,
              height: 0,
              thickness: 0,
            ),
          ),
        ),

        // The main text box
        // thinkBox(context),

        // Widget for the action bar.
        // actionBar(context),

        // Visibility(
        //   visible: Provider.of<ThoughtsProvider>(context).thoughts.isNotEmpty,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Row(
        //         mainAxisAlignment: MainAxisAlignment.start,
        //         crossAxisAlignment: CrossAxisAlignment.center,
        //         children: [
        //           Material(
        //             color: Colors.transparent,
        //             child: InkWell(
        //               onTap: () async {
        //                 mode = Mode.consciousness;
        //                 // Provider.of<ComindColorsNotifier>(context, listen: false)
        //                 //     .modifyColors(color);
        //               },
        //               child: // Soul blob
        //                   ComindTextButton(
        //                 lineLocation: LineLocation.bottom,
        //                 onPressed: () {
        //                   mode = Mode.consciousness;
        //                 },
        //                 text: '',
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),

        // The rest of the thoughts, mode is not notifications
        Visibility(
          visible: mode == Mode.stream || mode == Mode.myThoughts,
          child: ListView.builder(
            shrinkWrap: true,
            dragStartBehavior: DragStartBehavior.start,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: min(50, thoughtProvider.relatedThoughts.length),
            itemBuilder: (context, index) {
              var thought = thoughtProvider.relatedThoughts[index];
              return MarkdownThought(
                thought: thought,
                linkable: true,
                parentThought: getTopOfMind(context)?.id,
              );
            },
          ),
        ),

        // Notifications
        Visibility(
          visible: mode == Mode.pings,
          child: ListView.builder(
            shrinkWrap: true,
            dragStartBehavior: DragStartBehavior.start,
            physics: const NeverScrollableScrollPhysics(),
            // itemCount: Provider.of<ThoughtsProvider>(context).thoughts.length,
            itemCount: Provider.of<NotificationsProvider>(context)
                .notifications
                .length,
            itemBuilder: (context, index) {
              return NotificationDisplay(
                notification: Provider.of<NotificationsProvider>(context)
                    .notifications[index],
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

  Stack thinkBox(BuildContext context, ComindColorsNotifier colors) {
    return Stack(
      children: [
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              MainTextField(
                  colors: Provider.of<ComindColorsNotifier>(context),
                  primaryController: _primaryController,

                  // Thought submission function
                  onThoughtSubmitted: (String body) {
                    // Create a new thought
                    final thought = Thought.fromString(
                        body,
                        Provider.of<AuthProvider>(context, listen: false)
                            .username,
                        Provider.of<ComindColorsNotifier>(context,
                                listen: false)
                            .publicMode);

                    // Log the new ID
                    Logger.root
                        .info("{'new_id':${thought.id}}, 'body':'$body'");

                    // Set the mode to stream if it is in begin mode
                    if (mode == Mode.empty) {
                      mode = Mode.stream;
                    }

                    // Send the thought, add it to the top of mind
                    saveThought(context, thought, newThought: true)
                        .then((value) {
                      // Add the thought to the provider
                      Provider.of<ThoughtsProvider>(context, listen: false)
                          .addThought(thought);

                      // Search for related thoughts
                      Provider.of<ThoughtsProvider>(context, listen: false)
                          .fetchRelatedThoughts(context);

                      // Lastly, update the UI
                      setState(() {
                        Provider.of<ThoughtsProvider>(context, listen: false)
                            .addTopOfMind(context, thought);
                      });
                    });
                  }),
            ]),

        // SOUL BLOB BABY
        Positioned.fill(
          left: 0,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
              child: Material(
                borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await colorDialog(context);
                  },
                  borderRadius: BorderRadius.circular(100),
                  child: // Soul blob
                      Padding(
                    padding: const EdgeInsets.all(8),
                    child: SoulBlob(
                      comindColors: colors.currentColors,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
