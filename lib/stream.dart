import 'package:comind/api.dart';
import 'package:comind/bottom_sheet.dart';
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

  // The Top of Mind thought
  Thought? topOfMind;

  // List of related thoughts
  List<Thought> relatedThoughts = [];

  @override
  Widget build(BuildContext context) {
    // Debug initialize the top of mind thought to coThought
    topOfMind = Thought.fromString(
        "I'm happy to have you here :smiley:", "Co", true,
        title: "Welcome to comind");

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
              child: Center(
                child: SizedBox(
                  width: ComindColors.maxWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Column(
                            children: [
                              // The top of mind thought
                              if (topOfMind != null)
                                MarkdownThought(
                                  // type: MarkdownDisplayType,
                                  thought: topOfMind!,
                                  viewOnly: true,
                                ),

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
                                        setState(() {
                                          relatedThoughts = value;
                                        });
                                      });

                                      // Lastly, update the UI
                                      setState(() {
                                        topOfMind = thought;
                                      });
                                    });
                                  }),

                              // MarkdownThought(
                              //   type: MarkdownDisplayType.newThought,
                              //   thought: Thought.fromString(
                              //       "",
                              //       Provider.of<AuthProvider>(context).username,
                              //       true,
                              //       title: "Good morning"),
                              // ),
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
              ),
            ),
          );
        },
      ),
    );
  }
}
