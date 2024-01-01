import 'package:comind/colors.dart';
import 'package:comind/comind_div.dart';
import 'package:comind/input_field.dart';
import 'package:comind/markdown_display.dart';
import 'package:comind/misc/loading.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/providers.dart';
import 'package:flutter/material.dart';
import 'package:comind/markdown_display.dart';
import 'package:comind/types/thought.dart';
import 'package:comind/api.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Convenience function gets a thought from an ID

// FIXME remove this ignore
// ignore: must_be_immutable
class ThoughtEditorScreen extends StatefulWidget {
  Thought? thought;
  String? id;

  ThoughtEditorScreen({this.thought, this.id, Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ThoughtEditorScreenState createState() => _ThoughtEditorScreenState();
}

class _ThoughtEditorScreenState extends State<ThoughtEditorScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  // Display a snackbar with the given message
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Timer for autosaving
  Timer? _timer;

  //
  // only save if it's been 5 seconds
  // since the user stopped typing,
  // and the content has changed
  //
  // var timeSinceLastSave = 0;

  // Initialize the text controller with the thought's content
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we if a thought. If so, use it's content directly.
    // Otherwise, use the id to fetch the thought from the API, using async
    // and await to wait for the response.
    if (widget.thought != null) {
      // _textEditingController.text = widget.thought!.body;
    } else if (widget.id != null) {
      fetchThought(context, widget.id!).then((thought) {
        setState(() {
          _textEditingController.text = thought.body;
          widget.thought = thought;
        });
      });
    } else {
      // Provide a blank note
      _textEditingController.text = '';
      widget.thought = Thought.fromString(
          '', // body
          Provider.of<AuthProvider>(context, listen: false).username,
          false);
    }

    // App bar widget
    double height = 2;
    return Scaffold(
      key: _scaffoldKey, appBar: comindAppBar(context),

      // Using the basic text field if the note has been loaded,
      // or display a loading indicator if it hasn't
      body: widget.thought != null
          ? SingleChildScrollView(
              child: Center(
                child: Container(
                  width: 600,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // SizedBox(height: 20),
                      MarkdownThought(
                          type: MarkdownDisplayType.fullScreen,
                          context: context,
                          thought: widget.thought!,
                          selectable: false),

                      // Header for "Linked"
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 64, 0, 0),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Divider(
                                height: height,
                                color:
                                    Provider.of<ComindColorsNotifier>(context)
                                        .colorScheme
                                        .onBackground
                                        .withAlpha(64),
                              ),
                            ),
                            Positioned(
                              left: 14,
                              top: 0,
                              child: Container(
                                color:
                                    Provider.of<ComindColorsNotifier>(context)
                                        .colorScheme
                                        .background,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(4, 0, 4, 0),
                                  child: Text(
                                    "Linked",
                                    style: Provider.of<ComindColorsNotifier>(
                                            context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(8, 32, 8, 0),
                      //   child: Row(
                      //     children: [
                      //       Text(
                      //         "Linked",
                      //         style: Provider.of<ComindColorsNotifier>(context)
                      //             .textTheme
                      //             .titleSmall,
                      //       ),
                      //       // const Spacer(),
                      //       // IconButton(
                      //       //   icon: const Icon(Icons.add),
                      //       //   onPressed: () {
                      //       //     // TODO
                      //       //   },
                      //       // ),
                      //     ],
                      //   ),
                      // ),

                      // // Divider
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: Container(
                      //         height: height,
                      //         color: Provider.of<ComindColorsNotifier>(context)
                      //             .currentColors
                      //             .primaryColor,
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: Container(
                      //         height: height,
                      //         color: Provider.of<ComindColorsNotifier>(context)
                      //             .currentColors
                      //             .secondaryColor,
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: Container(
                      //         height: height,
                      //         color: Provider.of<ComindColorsNotifier>(context)
                      //             .currentColors
                      //             .tertiaryColor,
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      // // List of linked thoughts
                      // Expanded(
                      //   child: ListView(
                      //     children: [
                      //       // TODO
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            )
          : const Center(
              child: Loading(
              text: "Thought",
            )),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textEditingController.dispose();
    _scaffoldKey.currentState?.dispose();
    super.dispose();
  }
}
