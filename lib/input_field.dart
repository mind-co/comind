// Imports
import 'dart:math';

import 'package:comind/colors.dart';
import 'package:flutter/material.dart';
import 'package:comind/main.dart';
import 'package:comind/markdown_display.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/text_button.dart';
import 'package:comind/types/thought.dart';
import 'package:comind/api.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Enums for type of text field
enum TextFieldType {
  main,
  edit,
}

//
// The primary text field for Comind, stateful version
//
// ignore: must_be_immutable
class MainTextField extends StatefulWidget {
  MainTextField({
    super.key,
    required TextEditingController primaryController,

    // Editor type

    // Optional parent/child
    this.parentThought,
    this.childThought,

    // Color stuff
    this.colorIndex = 0,
    this.type = TextFieldType.main,
  }) : _primaryController = primaryController;

  final TextEditingController _primaryController;
  final Thought? parentThought;
  final Thought? childThought;
  var colorIndex = 0;
  final TextFieldType type;

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
  List<SearchResult> searchResults = [
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
      width: min(600, MediaQuery.of(context).size.width),
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
                      onKey: (RawKeyEvent event) {
                        if (event is RawKeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.enter &&
                            event.isControlPressed) {
                          // Ctrl + Enter was pressed, send the contents of the text field
                          _sendThought();
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
                              _primaryController.clear();
                            } else if (value == ":" ||
                                value == "/users" ||
                                value == "/u") {
                              setState(() {
                                uiMode = "users";
                              });

                              // Clear the text field
                              _primaryController.clear();
                            } else if (value == "/t" || value == ";") {
                              setState(() {
                                uiMode = "think";
                              });
                              _primaryController.clear();
                            }

                            // Next, handle the commands
                            if (uiMode == "search") {
                              // Search
                              var res = await searchThoughts(value);
                              setState(() {
                                searchResults = res;
                              });
                              print("All done");
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
                              color: Provider.of<ComindColorsNotifier>(context)
                                  .colorScheme
                                  .onPrimary
                                  .withAlpha(64),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Provider.of<ComindColorsNotifier>(context)
                                  .colorScheme
                                  .onPrimary
                                  .withAlpha(64),
                              // color: widget.colorIndex == 0 ||
                              //         uiMode != "think" ||
                              //         widget.type == TextFieldType.edit
                              //     ? Provider.of<ComindColorsNotifier>(context)
                              //         .colorScheme
                              //         .onPrimary
                              //         .withAlpha(128)
                              //     : widget.colorIndex == 1
                              //         ? Provider.of<ComindColorsNotifier>(
                              //                 context)
                              //             .colorScheme
                              //             .primary
                              //             .withAlpha(128)
                              //         : widget.colorIndex == 2
                              //             ? Provider.of<ComindColorsNotifier>(
                              //                     context)
                              //                 .colorScheme
                              //                 .secondary
                              //                 .withAlpha(128)
                              //             : Provider.of<ComindColorsNotifier>(
                              //                     context)
                              //                 .colorScheme
                              //                 .tertiary
                              //                 .withAlpha(128),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // UI mode display
                // Positioned(
                //   top: -4,
                //   left: 8,
                //   child: Padding(
                //     padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                //     child: Row(
                //       children: [
                //         // Send button
                //         Container(
                //           decoration: BoxDecoration(
                //             color: Provider.of<ComindColorsNotifier>(context).colorScheme.background,
                //             borderRadius: BorderRadius.circular(10),
                //           ),
                //           child: Padding(
                //             padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                //             child: ComindTextButton(
                //                 text: uiMode,
                //                 fontSize: 12,
                //                 onPressed: () {
                //                   // Toggle between each mode
                //                   if (uiMode == "think") {
                //                     setState(() {
                //                       uiMode = "search";
                //                     });
                //                   } else if (uiMode == "search") {
                //                     setState(() {
                //                       uiMode = "users";
                //                     });
                //                   } else if (uiMode == "users") {
                //                     setState(() {
                //                       uiMode = "think";
                //                     });
                //                   }
                //                 },
                //                 colorIndex: uiMode == "think"
                //                     ? 2
                //                     : uiMode == "search"
                //                         ? 1
                //                         : uiMode == "users"
                //                             ? 3
                //                             : 1,
                //                 opacity: 0.9,
                //                 textStyle: const TextStyle(
                //                     fontFamily: "Bungee", fontSize: 12)),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),

                // Send button
                Positioned(
                  bottom: -4,
                  right: 8,
                  child: Container(
                    color: Provider.of<ComindColorsNotifier>(context)
                        .colorScheme
                        .background,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: Row(
                        children: [
                          // Send button
                          if (true) //_primaryController.text.isNotEmpty)
                            ComindTextButton(
                              text: widget.type == TextFieldType.main
                                  ? "Send"
                                  : "Save",
                              lineLocation: LineLocation.top,
                              onPressed: widget.type == TextFieldType.main
                                  ? _sendThought
                                  : () {},
                              colorIndex:
                                  widget.type == TextFieldType.main ? 1 : 2,
                              opacity: 1.0,
                              fontSize: 12,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Search result display.
                // If we have any elements in search results, show them to the user.
              ],
            ),

            // Add the search results if they are not empty
            if (uiMode == "search" && searchResults.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: ComindSearchResultTable(searchResults: searchResults)),
          ],
        ),
      ),
    );
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
      saveQuickThought(_primaryController.text, false, widget.parentThought?.id,
          widget.childThought?.id);

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
                  child: Container(
                    child: Text(
                      searchResults[index].username,
                      style: Provider.of<ComindColorsNotifier>(context)
                          .textTheme
                          .titleSmall,
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
                  child: Container(
                    child: Text(
                      searchResults[index].title,
                      style: Provider.of<ComindColorsNotifier>(context)
                          .textTheme
                          .bodyMedium,
                    ), // This is your body column
                  ),
                ),

                // If there's a linkedTo or linkedFrom, show it
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Text(
                      searchResults[index].linkedTo == true
                          ? "linked to"
                          : searchResults[index].linkedFrom == true
                              ? "linked from"
                              : "b",
                      style: Provider.of<ComindColorsNotifier>(context)
                          .textTheme
                          .bodyMedium,
                    ), // This is your body column
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
