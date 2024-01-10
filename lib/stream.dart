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
  final _primaryController = TextEditingController(text: "ABC");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: comindAppBar(context),
      bottomSheet: ComindBottomSheet(),
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
                      // coThought(context, "Hey there", "A greeting"),
                      Column(
                        children: [
                          Column(
                            children: [
                              MainTextField(
                                  primaryController: _primaryController,
                                  onThoughtSubmitted: (String body) {
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

                                      // Lastly, update the UI
                                      setState(() {});
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
