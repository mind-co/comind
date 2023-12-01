import 'package:comind/colors.dart';
import 'package:flutter/material.dart';
import 'package:comind/misc/comind_logo.dart';
import 'package:comind/types/thought.dart';
import 'package:comind/api.dart';

class ThoughtEditorScreen extends StatefulWidget {
  Thought thought;

  ThoughtEditorScreen({required this.thought, Key? key}) : super(key: key);

  @override
  _ThoughtEditorScreenState createState() => _ThoughtEditorScreenState();
}

class _ThoughtEditorScreenState extends State<ThoughtEditorScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  // Initialize the text controller with the thought's content
  @override
  void initState() {
    super.initState();
    _textEditingController.text = widget.thought.body;
  }

  // Save the note on back button press
  // Future<bool> _onWillPop() {
  //   widget.thought.body = _textEditingController.text;
  //   saveThought(widget.thought).then((_) {
  //     Navigator.of(context).pop();
  //   });
  //   return Future.value(true);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: ComindLogo(key: UniqueKey()),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Add dark mode toggle
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () {
              // Toggle the brightness
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              widget.thought.body = _textEditingController.text;
              await saveThought(widget.thought);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.thought.id,
              style: TextStyle(
                color: ComindColors.getTextColorBasedOnBackground(
                  Theme.of(context).colorScheme.background,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  width: 600, // Set your desired maximum width here
                  child: TextField(
                    style: TextStyle(
                      color: ComindColors.getTextColorBasedOnBackground(
                        Theme.of(context).colorScheme.background,
                      ),
                    ),
                    controller: _textEditingController,
                    maxLines:
                        null, // Allows the text field to expand to multiple lines
                    expands: true, // Expands the text field as needed
                    cursorColor: ComindColors.getTextColorBasedOnBackground(
                      Theme.of(context).colorScheme.background,
                    ),
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
    _textEditingController.dispose();
    super.dispose();
  }
}
