import 'package:comind/misc/util.dart';
import 'package:flutter/material.dart';
import 'package:comind/misc/comind_logo.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:comind/types/thought.dart';

class ThoughtEditorScreen extends StatefulWidget {
  final Thought thought;

  const ThoughtEditorScreen({required this.thought, Key? key})
      : super(key: key);

  @override
  _ThoughtEditorScreenState createState() {
    return _ThoughtEditorScreenState();
  }
}

class _ThoughtEditorScreenState extends State<ThoughtEditorScreen> {
  final QuillController _controller = QuillController.basic();

  @override
  void initState() {
    super.initState();
    // Initialize the content controller with the note's content
    // _controller.text = widget.note.content;
    // Make the screen full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: comindAppBar(context),
        body: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: QuillProvider(
                configurations: QuillConfigurations(
                  controller: _controller,
                  // sharedConfigurations: const QuillSharedConfigurations(
                  //   locale: Locale('us', 'US'),
                  // ),
                ),
                child: Column(
                  children: [
                    const QuillToolbar(
                      configurations: QuillToolbarConfigurations(
                          showBoldButton: false,
                          showItalicButton: false,
                          showUnderLineButton: false,
                          showStrikeThrough: false,
                          showColorButton: false,
                          showBackgroundColorButton: false,
                          showClearFormat: false,
                          showHeaderStyle: true,
                          showListNumbers: true,
                          showListBullets: true,
                          showListCheck: true,
                          showCodeBlock: true,
                          showQuote: true,
                          showIndent: true,
                          showLink: true,
                          showLeftAlignment: false,
                          showSearchButton: false,
                          showSuperscript: false,
                          showFontFamily: false,
                          showFontSize: false,
                          showUndo: false,
                          showRedo: false,
                          showSubscript: false,
                          showRightAlignment: false),
                    ),
                    Expanded(
                      child: QuillEditor.basic(
                        configurations: const QuillEditorConfigurations(
                          readOnly: false,
                          autoFocus: true,
                          minHeight: 100,
                          showCursor: true,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ))
        // body: Column(
        //   children: [
        //     Text('Title: ${widget.note.title}'),
        //     Expanded(
        //       child: Padding(
        //         padding: const EdgeInsets.all(16.0),
        //         child: TextField(
        //           controller: _contentController,
        //           maxLines: null, // Allows multiple lines for note content
        //           decoration: const InputDecoration(
        //             labelText: 'Note Content',
        //             border: OutlineInputBorder(),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        );
  }

  @override
  void dispose() {
    // Dispose of the content controller when the screen is no longer in use
    _controller.dispose();
    // Restore the system UI mode when the screen is disposed
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }
}
