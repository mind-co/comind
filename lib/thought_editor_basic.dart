import 'package:comind/colors.dart';
import 'package:comind/misc/util.dart';
import 'package:flutter/material.dart';
import 'package:comind/misc/comind_logo.dart';
import 'package:comind/types/thought.dart';
import 'package:comind/api.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// FIXME remove this ignore
// ignore: must_be_immutable
class ThoughtEditorScreen extends StatefulWidget {
  Thought thought;

  ThoughtEditorScreen({required this.thought, Key? key}) : super(key: key);

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
    _textEditingController.text = widget.thought.body;

    // // Autosave every n_sec seconds
    // const nSec = 5;

    // _timer = Timer.periodic(const Duration(seconds: nSec), (timer) async {
    //   if (_textEditingController.text != _originalContent) {
    //     // Save the thought
    //     widget.thought.body = _textEditingController.text;
    //     await saveThought(widget.thought);

    //     // Handle the time since last save
    //     // timeSinceLastSave += nSec;

    //     // ignore: use_build_context_synchronously
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: const Row(
    //           children: [
    //             Text("{",
    //                 style: TextStyle(
    //                     fontFamily: "Bungee Pop",
    //                     fontSize: 46,
    //                     color: Provider.of<ComindColorsNotifier>(context).primaryColor)),
    //             Text("O",
    //                 style: TextStyle(
    //                     fontFamily: "Bungee Pop",
    //                     fontSize: 46,
    //                     color: Provider.of<ComindColorsNotifier>(context).secondaryColor)),
    //             Text("}",
    //                 style: TextStyle(
    //                     fontFamily: "Bungee Pop",
    //                     fontSize: 46,
    //                     color: Provider.of<ComindColorsNotifier>(context).tertiaryColor)),
    //           ],
    //         ),
    //         backgroundColor: Provider.of<ComindColorsNotifier>(context).colorScheme.background,
    //       ),
    //     );
    //     _originalContent = _textEditingController.text;
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    // Extract the current colors
    var colors = Provider.of<ComindColorsNotifier>(context);

    // App bar widget
    return Scaffold(
      key: _scaffoldKey,
      appBar: comindAppBar(context),

      // Using the basic text field
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text(
            //   widget.thought.id,
            //   style: TextStyle(
            //     color: Provider.of<ComindColorsNotifier>(context).getTextColorBasedOnBackground(
            //       Provider.of<ComindColorsNotifier>(context).colorScheme.background,
            //     ),
            //   ),
            // ),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 600, // Set your desired maximum width here
                  child: TextField(
                    // style: Provider.of<ComindColorsNotifier>(context).textTheme.bodyMedium,
                    // style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w300),
                    controller: _textEditingController,
                    maxLines:
                        null, // Allows the text field to expand to multiple lines
                    expands: true, // Expands the text field as needed
                    // cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      hintText: 'Get thinky...',
                    ),
                    // Initialize to thought body
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
