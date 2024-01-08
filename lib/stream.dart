import 'package:comind/bottom_sheet.dart';
import 'package:comind/colors.dart';
import 'package:comind/input_field.dart';
import 'package:comind/markdown_display.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Provider.of<ComindColorsNotifier>(context).background,
        title: Opacity(opacity: 0.5, child: const Text('Stream')),
        centerTitle: true,
      ),
      bottomSheet: ComindBottomSheet(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          var primaryController = TextEditingController();

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
                              // MainTextField(
                              //     primaryController: primaryController),

                              MarkdownThought(
                                type: MarkdownDisplayType.newThought,
                                thought: Thought.fromString(
                                    "",
                                    Provider.of<AuthProvider>(context).username,
                                    true,
                                    title: "Good morning"),
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
              ),
            ),
          );
        },
      ),
    );
  }
}
