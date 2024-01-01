import 'package:comind/colors.dart';
import 'package:comind/providers.dart';
import 'package:flutter/material.dart';
import 'package:comind/markdown_display.dart';
import 'package:comind/text_button.dart';
import 'package:comind/types/thought.dart';
import 'package:comind/api.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Enums for type of text field
enum TextFieldType { main, edit, fullscreen }

//
// The primary text field for Comind, stateful version
//
// ignore: must_be_immutable
class MainTextField extends StatefulWidget {
  MainTextField({
    super.key,
    required TextEditingController primaryController,

    // Optional functions
    this.toggleEditor,
    this.onThoughtSubmitted,
    this.onThoughtEdited,

    // Optional parent/child/current
    this.parentThought,
    this.childThought,
    this.thought,

    // Color stuff
    this.colorIndex = 0,
    this.type = TextFieldType.main,
  }) : _primaryController = primaryController;

  final TextEditingController _primaryController;
  final Thought? parentThought;
  final Thought? childThought;
  final Thought? thought;
  var colorIndex = 0;
  final TextFieldType type;

  // Optional functions
  final Function()? toggleEditor;
  final Function(Thought)? onThoughtSubmitted;
  final Function(Thought)? onThoughtEdited;

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _MainTextFieldState createState() => _MainTextFieldState(
        primaryController: _primaryController,
      );
}

class _MainTextFieldState extends State<MainTextField> {
  _MainTextFieldState({
    required TextEditingController primaryController,
  }) : _primaryController = primaryController;

  final TextEditingController _primaryController;
  final ScrollController _scrollController = ScrollController();
  String uiMode = "think";
  // String uiMode = "think";
  List<Thought> searchResults = [
    // SearchResult(
    //     id: "a", body: "Howdy", username: "Cameron", cosineSimilarity: 0.8),
    // SearchResult(
    //     id: "b", body: "Hello", username: "John", cosineSimilarity: 0.7),
    // SearchResult(
    //     id: "c", body: "Hi there", username: "Alice", cosineSimilarity: 0.6),
    // SearchResult(
    //     id: "d", body: "Greetings", username: "Bob", cosineSimilarity: 0.5),
    // SearchResult(
    //     id: "e", body: "Hey", username: "Emily", cosineSimilarity: 0.4),
    // SearchResult(
    //     id: "f", body: "What's up", username: "David", cosineSimilarity: 0.3),
  ];

  // Things to track textfield keys
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      // width: min(600, MediaQuery.of(context).size.width),
      child: Padding(
        padding: widget.type == TextFieldType.main
            ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
            : const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          children: [
            Stack(
              children: [
                // Text box
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                  child: Container(
                    decoration: const BoxDecoration(
                        // color: Provider.of<ComindColorsNotifier>(context).colorScheme.surfaceVariant.withAlpha(100),
                        ),
                    child: RawKeyboardListener(
                      focusNode: focusNode,

                      // Check for Ctrl + Enter to
                      onKey: (RawKeyEvent event) async {
                        if (event is RawKeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.enter &&
                            event.isControlPressed &&
                            widget.type == TextFieldType.main) {
                          _submit(context)();
                        }
                      },
                      child: TextField(
                        scrollController: _scrollController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 10,
                        minLines: 1,
                        textInputAction: TextInputAction.newline,
                        style: Provider.of<ComindColorsNotifier>(context)
                            .textTheme
                            .bodyMedium,
                        autofocus: true,
                        controller: _primaryController,

                        // If it starts with /, it's a command
                        onChanged: (value) async {
                          // Check for mode changes first, but only
                          // if the type is main
                          if (widget.type == TextFieldType.main) {
                            if (value == "/search" || value == "/s") {
                              setState(() {
                                uiMode = "search";
                              });

                              // Clear the text field
                              // _primaryController.clear();
                            } else if (value == "/users" || value == "/u") {
                              setState(() {
                                uiMode = "users";
                              });

                              // Clear the text field
                              // _primaryController.clear();
                            } else if (value == "/t" || value == ";") {
                              setState(() {
                                uiMode = "think";
                              });
                              // _primaryController.clear();
                            }

                            // Next, handle the commands
                            if (uiMode == "search") {
                              // Search
                              var res = await searchThoughts(context, value);
                              setState(() {
                                searchResults = res;
                              });
                            }
                          }
                        },

                        // Cursor stuff
                        cursorWidth: 8,
                        cursorColor: widget.type == TextFieldType.main
                            ? uiMode == "think"
                                ? colorMap(context).withAlpha(255)
                                : colorMap(context).withAlpha(255)
                            : Provider.of<ComindColorsNotifier>(context)
                                .colorScheme
                                .onBackground,
                        decoration: InputDecoration(
                          label: Text(
                            widget.type == TextFieldType.main ? uiMode : "Edit",
                            style: Provider.of<ComindColorsNotifier>(context)
                                .textTheme
                                .titleSmall,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          floatingLabelStyle: TextStyle(
                            color: Provider.of<ComindColorsNotifier>(context)
                                .colorScheme
                                .onPrimary
                                .withAlpha(180),
                          ),
                          labelStyle: TextStyle(
                            color: Provider.of<ComindColorsNotifier>(context)
                                .colorScheme
                                .onPrimary
                                .withAlpha(180),
                          ),
                          contentPadding:
                              const EdgeInsets.fromLTRB(16, 20, 16, 20),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              width: 1,
                              color: Provider.of<ComindColorsNotifier>(context)
                                  .colorScheme
                                  .onPrimary
                                  .withAlpha(64),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              width: 1,
                              color: Provider.of<ComindColorsNotifier>(context)
                                  .colorScheme
                                  .onPrimary
                                  .withAlpha(128),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Send button
                Positioned(
                  bottom: 4,
                  right: 16,
                  child: Container(
                    color: Provider.of<ComindColorsNotifier>(context)
                        .colorScheme
                        .background,
                    child: Row(
                      children: [
                        // Cancel button
                        Visibility(
                          visible: widget.type == TextFieldType.edit,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                            child: Visibility(
                              visible: widget.type == TextFieldType.edit,
                              child: ComindTextButton(
                                text: "Cancel",
                                lineLocation: LineLocation.top,
                                onPressed: () {
                                  if (widget.toggleEditor != null) {
                                    widget.toggleEditor!();
                                  }
                                },
                                colorIndex: 3,
                                opacity: 1.0,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),

                        // Send button
                        ComindTextButton(
                          text: widget.type == TextFieldType.main
                              ? "Think"
                              : "Save",
                          lineLocation: LineLocation.top,
                          onPressed: _submit(context),
                          colorIndex: widget.type == TextFieldType.main ? 1 : 2,
                          opacity: 1.0,
                          fontSize: 10,
                        ),
                      ],
                    ),
                  ),
                ),

                // Add the current time on the bottom left,
                // formatted as 1:23pm
                Positioned(
                  bottom: 8,
                  left: 12,
                  child: Container(
                    color: Provider.of<ComindColorsNotifier>(context)
                        .colorScheme
                        .background,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                      child: Text(
                        DateFormat('h:mm a').format(DateTime.now()),
                        style: Provider.of<ComindColorsNotifier>(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: Provider.of<ComindColorsNotifier>(context)
                                  .colorScheme
                                  .onPrimary
                                  .withAlpha(180),
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Add the search results if they are not empty
            if (uiMode == "search" && searchResults.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: ThoughtTable(thoughts: searchResults)),
            // child: ComindSearchResultTable(searchResults: searchResults)),
          ],
        ),
      ),
    );
  }

  Function _submit(BuildContext context) {
    return widget.type == TextFieldType.main
        ? () {
            widget.onThoughtSubmitted!(Thought.fromString(
                _primaryController.text,
                Provider.of<AuthProvider>(context, listen: false).username,
                Provider.of<AuthProvider>(context, listen: false).publicMode));
          }
        : widget.type == TextFieldType.edit
            ? () {
                // TODO
                // This is the editor save button, which
                // should save the thought and close the
                // editor.

                // First, let's update the thought if it
                // exists
                if (widget.thought != null) {
                  widget.thought?.body = _primaryController.text;

                  // Clear the text field
                  _primaryController.clear();

                  // Close the editor
                  if (widget.toggleEditor != null) {
                    widget.toggleEditor!();
                  }

                  // Return the new thought
                  if (widget.onThoughtEdited != null &&
                      widget.thought != null) {
                    widget.onThoughtEdited!(widget.thought!);
                  }
                } else {
                  // TODO no thought was passed but we are in edit mode
                  throw Exception(
                      "No thought was passed but we are in edit mode");
                }
              }
            : () {
                // TODO
                // This should probably handle the case
                // where the editor is fullscreen.
              };
  }

  Color colorMap(BuildContext context) {
    return widget.colorIndex == 0
        ? Provider.of<ComindColorsNotifier>(context).colorScheme.onPrimary
        : widget.colorIndex == 1
            ? Provider.of<ComindColorsNotifier>(context)
                .colorScheme
                .primary
                .withAlpha(128)
            : widget.colorIndex == 2
                ? Provider.of<ComindColorsNotifier>(context)
                    .colorScheme
                    .secondary
                    .withAlpha(128)
                : Provider.of<ComindColorsNotifier>(context)
                    .colorScheme
                    .tertiary
                    .withAlpha(128);
  }

  // Thought sending method
  void _sendThought() {
    // Save the parent thought if the text has length > 0
    if (_primaryController.text.isNotEmpty) {
      // Send the thought with the parent/child if they exist
      saveQuickThought(context, _primaryController.text, false,
          widget.parentThought?.id, widget.childThought?.id);

      // Clear the text field
      _primaryController.clear();
    }
  }
}

class ComindSearchResult extends StatelessWidget {
  const ComindSearchResult({
    super.key,
    required this.searchResults,
  });

  final List<SearchResult> searchResults;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      height: 100,
      child: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final result = searchResults[index];
          // return Text("{${result.username}} " + result.body);
          return RichText(
            text: TextSpan(
              text: "${result.username} ",
              style: TextStyle(
                fontSize: 10,
                fontFamily: "Bungee",
                color: Provider.of<ComindColorsNotifier>(context)
                    .colorScheme
                    .onBackground,
              ),
              children: <TextSpan>[
                // Show cosine similarity
                TextSpan(
                  text:
                      "${(result.cosineSimilarity * 100).toStringAsFixed(0)}% ",
                  style: Provider.of<ComindColorsNotifier>(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        fontSize: 12,
                      ),
                ),

                // Thought body
                TextSpan(
                  text: result.body,
                  style: Provider.of<ComindColorsNotifier>(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ComindSearchResultTable
class ComindSearchResultTable extends StatelessWidget {
  const ComindSearchResultTable({
    Key? key,
    required this.searchResults,
    this.parentThought,
  }) : super(key: key);

  final List<SearchResult> searchResults;
  final Thought? parentThought;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      height: 200,
      child: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          return MaterialButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              // Save the thought
              // saveQuickThought(searchResults[index].body, false,
              //     searchResults[index].id, null);

              // Clear the text field
              // _primaryController.clear();

              // Refresh the thoughts
              // _fetchThoughts();
            },
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Text(
                    searchResults[index].username,
                    style: Provider.of<ComindColorsNotifier>(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(
                          color: Provider.of<ComindColorsNotifier>(context)
                              .colorScheme
                              .onPrimary
                              .withAlpha(180),
                        ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    // If numLinks is null, show 0
                    searchResults[index].numLinks == null ||
                            searchResults[index].numLinks == 0
                        // ? "🤙"
                        ? "∅"
                        : searchResults[index].numLinks == 1
                            ? "1"
                            : "${searchResults[index].numLinks} links",

                    // searchResults[index].numLinks.toString(),
                    // searchResults[index].numLinks.toString() + " links",
                    style: Provider.of<ComindColorsNotifier>(context)
                        .textTheme
                        .bodyMedium,
                  ),
                ),

                // Cosine similarity
                Expanded(
                  flex: 1,
                  child: Text(
                    "${(searchResults[index].cosineSimilarity * 100).toStringAsFixed(0)}%",
                    style: Provider.of<ComindColorsNotifier>(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                            // color: searchResults[index].cosineSimilarity > 0.5
                            //     ? Provider.of<ComindColorsNotifier>(context).colorScheme.onPrimary
                            //     : Provider.of<ComindColorsNotifier>(context).colorScheme.onSecondary,
                            ),
                  ), // This is your body column
                ),
                // Remove the extra closing parenthesis
                // ),
                Expanded(
                  flex: 5, // Increase flex to make this column take more space
                  child: Text(
                    searchResults[index].title,
                    style: Provider.of<ComindColorsNotifier>(context)
                        .textTheme
                        .bodyMedium,
                  ),
                ),

                // If there's a linkedTo or linkedFrom, show it
                Expanded(
                  flex: 1,
                  child: Text(
                    searchResults[index].linkedTo == true
                        ? "linked to"
                        : searchResults[index].linkedFrom == true
                            ? "linked from"
                            : "b",
                    style: Provider.of<ComindColorsNotifier>(context)
                        .textTheme
                        .bodyMedium,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ThoughtTable shows a list of searched thoughts
class ThoughtTable extends StatelessWidget {
  const ThoughtTable({
    Key? key,
    required this.thoughts,
    this.parentThought,
  }) : super(key: key);

  final List<Thought> thoughts;
  final Thought? parentThought;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          width: 600,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // Border color
            border: Border.all(
              color: Provider.of<ComindColorsNotifier>(context)
                  .colorScheme
                  .primary
                  .withAlpha(255),
            ),
          ),

          // If there are no thoughts, show a message
          child: thoughts.isEmpty
              ? Center(
                  // "No thoughts found! \n\nY'all should try making one. \n\nI know you're a smart cookie.",
                  // child: Text(
                  //   "No thoughts found! \n\nY'all should try making one. \n\nI know you're a smart cookie.",
                  //   style: Provider.of<ComindColorsNotifier>(context)
                  //       .textTheme
                  //       .bodyMedium,
                  // ),

                  // Using text span
                  child: RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      text: "No thoughts found! \n\n",
                      style: Provider.of<ComindColorsNotifier>(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            color: Provider.of<ComindColorsNotifier>(context)
                                .colorScheme
                                .onPrimary
                                .withAlpha(180),
                          ),
                      children: <TextSpan>[
                        TextSpan(
                          text: "Y'all should make some. \n\n",
                          style: Provider.of<ComindColorsNotifier>(context)
                              .textTheme
                              .bodyLarge,
                        ),
                        TextSpan(
                          text:
                              "I would. But I am just a lame, boring computer.\n\n",
                          style: Provider.of<ComindColorsNotifier>(context)
                              .textTheme
                              .bodyLarge,
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                      itemCount: thoughts.length + 1,
                      itemBuilder: (context, index) {
                        // return Text("ABC");
                        if (index < thoughts.length) {
                          return MarkdownThought(
                              thought: thoughts[index], context: context);
                        } else {
                          return Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Do you want to see ",
                                  style:
                                      Provider.of<ComindColorsNotifier>(context)
                                          .textTheme
                                          .bodyMedium,
                                ),
                                // TODO #5 add more thoughts button
                                ComindTextButton(
                                  text: "More",
                                  onPressed: () {},
                                  opacity: 1.0,
                                  fontSize: 12,
                                ),
                                Text(
                                  " thoughts?",
                                  style:
                                      Provider.of<ComindColorsNotifier>(context)
                                          .textTheme
                                          .bodyMedium,
                                ),
                              ],
                            ),
                          );
                        }
                      }),
                ),
        ),

        // Display ("Search results") at top left corner
        Positioned(
          top: -8,
          left: 10,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
            child: Row(
              children: [
                // Send button
                Container(
                  decoration: BoxDecoration(
                    color: Provider.of<ComindColorsNotifier>(context)
                        .colorScheme
                        .background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Text(
                      "Results",
                      style: Provider.of<ComindColorsNotifier>(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                            color: Provider.of<ComindColorsNotifier>(context)
                                .colorScheme
                                .onPrimary
                                .withAlpha(180),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
