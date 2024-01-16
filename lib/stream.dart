import 'package:comind/api.dart';
import 'package:comind/bottom_sheet.dart';
import 'package:comind/cine_wave.dart';
import 'package:comind/color_picker.dart';
import 'package:comind/colors.dart';
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
          return mainStream(constraints, context);
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
          crossAxisAlignment: getTopOfMind(context) != null
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
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
                      Text("", style: getTextTheme(context).titleLarge),
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
                        style: getTextTheme(context).titleMedium),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Column columnOfThings(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(text: "Think something"),

        // The main text box
        thinkBox(context),

        // Username
        Visibility(
          visible: Provider.of<AuthProvider>(context).isLoggedIn &&
              Provider.of<AuthProvider>(context).username != "",
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: RichText(
                text: TextSpan(children: [
              TextSpan(
                text: "Hi ",
                style: getTextTheme(context).bodyLarge,
              ),
              TextSpan(
                text: Provider.of<AuthProvider>(context).username,
                style: getTextTheme(context).titleLarge,
              ),
              TextSpan(
                text: ", welcome back. It's ",
                style: getTextTheme(context).bodyLarge,
              ),

              // Time as hh:MM
              TextSpan(
                text: (DateTime.now().hour % 12).toString().padLeft(2, '0') +
                    ":" +
                    DateTime.now().minute.toString().padLeft(2, '0'),
                style: getTextTheme(context).bodyLarge,
              ),

              // Period
              TextSpan(
                text: DateTime.now().hour < 12 ? "am." : "pm.",
                style: getTextTheme(context).bodyLarge,
              ),
            ])),
          ),
        ),

        // Action row under the text box
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Wrap(children: [
            // // Color picker
            // ColorPicker(onColorSelected: (Color color) {
            //   Provider.of<ComindColorsNotifier>(context, listen: false)
            //       .modifyColors(color);
            // }),
            // Color picker button
            TextButtonSimple(
                text: "Color",
                onPressed: () async {
                  Color color = await colorDialog(context);
                  Provider.of<ComindColorsNotifier>(context, listen: false)
                      .modifyColors(color);
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

            // Logout button
            Visibility(
              visible: Provider.of<AuthProvider>(context).isLoggedIn,
              child: TextButtonSimple(
                  text: "Log out",
                  onPressed: () => {
                        // Logout
                        Provider.of<AuthProvider>(context, listen: false)
                            .logout()
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
            //   child: TextButtonSimple(
            //       text: "Settings",
            //       onPressed: () {
            //         Navigator.pushNamed(
            //             context, "/settings");
            //       }),
            // ),
          ]),
        ),

        // Top of mind divider
        // Visibility(
        //     visible: Provider.of<ThoughtsProvider>(context).thoughts.length > 0,
        //     child: const SectionHeader(text: "Top of Mind")),

        // The top of mind thought
        // if (getTopOfMind(context) != null)
        Visibility(
          visible: Provider.of<ThoughtsProvider>(context).topOfMind != null,
          child: Text("Top of mind thought"),
          // child: MarkdownThought(
          //   // type: MarkdownDisplayType,
          //   thought: getTopOfMind(context) ??
          //       Thought.fromString(
          //           "testing", "this is a testing thought", true),
          //   viewOnly: true,
          // ),
        ),

        // Top of mind divider
        Visibility(
            visible: getTopOfMind(context) != null,
            child: const SectionHeader(text: "The Stream")),

        // The rest of the thoughts
        ListView.builder(
          shrinkWrap: true,
          itemCount: Provider.of<ThoughtsProvider>(context).thoughts.length,
          itemBuilder: (context, index) {
            return MarkdownThought(
              // type: MarkdownDisplayType,
              thought: Provider.of<ThoughtsProvider>(context).thoughts[index],
              viewOnly: true,
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
              searchThoughts(context, thought.body).then((value) {
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
                // topOfMind = thought;
              });
            });
          }),
    );
  }

  bool showSideColumns(BuildContext context) =>
      MediaQuery.of(context).size.width > 800 && getTopOfMind(context) != null;

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
  });

  final String text;
  final TextStyle? style;

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 32, 0, 16),
      child: Row(children: [
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
        Expanded(
            child: Padding(
          padding: cineEdgeInsetsRight,
          child: CineWave(
            amplitude: waveAmplitude,
            frequency: waveFrequency,
            goLeft: true,
          ),
        )),
      ]),
    );
  }
}
