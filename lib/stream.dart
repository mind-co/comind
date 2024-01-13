import 'package:comind/api.dart';
import 'package:comind/bottom_sheet.dart';
import 'package:comind/cine_wave.dart';
import 'package:comind/colors.dart';
import 'package:comind/input_field.dart';
import 'package:comind/markdown_display.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/providers.dart';
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
    Provider.of<ThoughtsProvider>(context, listen: false)
        .addThoughts(relatedThoughts);
  }

  @override
  Widget build(BuildContext context) {
    // Debug initialize the top of mind thought to coThought
    // topOfMind = Thought.fromString(
    //     "I'm happy to have you here :smiley:", "Co", true,
    //     title: "Welcome to comind");
    fetchRelatedThoughts();

    return Scaffold(
      // App bar
      appBar: comindAppBar(context),

      // Bottom sheet
      bottomSheet: ComindBottomSheet(),

      // Body
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: ComindColors.maxWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Column(
                              children: [
                                const SectionHeader(text: "Think something"),

                                // The main text box
                                MainTextField(
                                    primaryController: _primaryController,
                                    onThoughtSubmitted: (String body) {
                                      // If the body is empty, do nothing
                                      if (body.isEmpty) {
                                        return;
                                      }

                                      // Create a new thought
                                      final thought = Thought.fromString(
                                          body,
                                          Provider.of<AuthProvider>(context,
                                                  listen: false)
                                              .username,
                                          Provider.of<ComindColorsNotifier>(
                                                  context,
                                                  listen: false)
                                              .publicMode);

                                      // Send the thought
                                      saveThought(context, thought,
                                              newThought: true)
                                          .then((value) {
                                        // Add the thought to the providerthis
                                        Provider.of<ThoughtsProvider>(context,
                                                listen: false)
                                            .addThought(thought);

                                        // Search for related thoughts
                                        searchThoughts(context, thought.body)
                                            .then((value) {
                                          // Add the related thoughts to the provider
                                          Provider.of<ThoughtsProvider>(context,
                                                  listen: false)
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

                                // Top of mind divider
                                const SectionHeader(text: "Top of Mind"),

                                // The top of mind thought
                                Visibility(
                                  visible: getTopOfMind(context) != null,
                                  child: MarkdownThought(
                                    // type: MarkdownDisplayType,
                                    thought: getTopOfMind(context)!,
                                    viewOnly: true,
                                  ),
                                ),

                                // Top of mind divider
                                const SectionHeader(text: "The Stream"),

                                // The rest of the thoughts
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount:
                                      Provider.of<ThoughtsProvider>(context)
                                          .thoughts
                                          .length,
                                  itemBuilder: (context, index) {
                                    return MarkdownThought(
                                      // type: MarkdownDisplayType,
                                      thought:
                                          Provider.of<ThoughtsProvider>(context)
                                              .thoughts[index],
                                      viewOnly: true,
                                    );
                                  },
                                ),
                              ],
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
              ),
            ),
          );
        },
      ),
    );
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
    const cineEdgeInsetsLeft = const EdgeInsets.fromLTRB(30, 0, 8, 0);
    const cineEdgeInsetsRight = const EdgeInsets.fromLTRB(8, 0, 30, 0);
    const waveAmplitude = 0.02;
    const waveFrequency = 10.0;
    return Row(children: [
      Expanded(
          child: Padding(
        padding: cineEdgeInsetsLeft,
        child: CineWave(
          amplitude: waveAmplitude,
          frequency: waveFrequency,
        ),
      )),
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Text(
          text,
          style: style ??
              Provider.of<ComindColorsNotifier>(context)
                  .currentColors
                  .textTheme
                  .titleMedium,
        ),
      ),
      Expanded(
          child: Padding(
        padding: cineEdgeInsetsRight,
        child: CineWave(
          amplitude: waveAmplitude,
          frequency: waveFrequency,
        ),
      )),
    ]);
  }
}
