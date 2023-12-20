// Imports
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:comind/main.dart';
import 'package:comind/markdown_display.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/text_button.dart';
import 'package:comind/types/thought.dart';
import 'package:comind/api.dart';

//
// The primary text field for Comind, stateful version
//
class MainTextField extends StatefulWidget {
  MainTextField({
    super.key,
    required TextEditingController primaryController,

    // Optional parent/child
    this.parentThought,
    this.childThought,
  }) : _primaryController = primaryController;

  final TextEditingController _primaryController;
  final Thought? parentThought;
  final Thought? childThought;

  @override
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
  String uiMode = "search";
  // String uiMode = "think";
  List<SearchResult> searchResults = [
    SearchResult(
        id: "a", body: "Howdy", username: "Cameron", cosineSimilarity: 0.8),
    SearchResult(
        id: "b", body: "Hello", username: "John", cosineSimilarity: 0.7),
    SearchResult(
        id: "c", body: "Hi there", username: "Alice", cosineSimilarity: 0.6),
    SearchResult(
        id: "d", body: "Greetings", username: "Bob", cosineSimilarity: 0.5),
    SearchResult(
        id: "e", body: "Hey", username: "Emily", cosineSimilarity: 0.4),
    SearchResult(
        id: "f", body: "What's up", username: "David", cosineSimilarity: 0.3),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: min(600, MediaQuery.of(context).size.width),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Column(
          children: [
            Stack(
              children: [
                // Text box
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                  child: Container(
                    decoration: const BoxDecoration(
                        // color: Theme.of(context).colorScheme.surfaceVariant.withAlpha(100),
                        ),
                    child: TextField(
                      scrollController: _scrollController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 10,
                      minLines: 1,
                      textInputAction: TextInputAction.newline,
                      cursorWidth: 10,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 16),
                      autofocus: false,
                      controller: _primaryController,

                      // If it starts with /, it's a command
                      onChanged: (value) async {
                        // Check for mode changes first
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
                      },
                      //   // setState(() {
                      //   //   editVisibilityList[0] = true;
                      //   // });
                      // },
                      cursorColor: Theme.of(context).colorScheme.primary,
                      decoration: InputDecoration(
                        label: Text(uiMode),
                        contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 20),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withAlpha(32),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withAlpha(128),
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
                //             color: Theme.of(context).colorScheme.background,
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
                  bottom: -1,
                  right: 8,
                  child: Container(
                    color: Theme.of(context).colorScheme.background,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: Row(
                        children: [
                          // Send button
                          if (true) //_primaryController.text.isNotEmpty)
                            ComindTextButton(
                              text: "Send",
                              lineLocation: LineLocation.top,
                              onPressed: () {
                                // Save the parent thought if the text has length > 0
                                if (_primaryController.text.isNotEmpty) {
                                  // Send the thought with the parent/child if they exist
                                  saveQuickThought(
                                      _primaryController.text,
                                      false,
                                      widget.parentThought?.id,
                                      widget.childThought?.id);

                                  // Clear the text field
                                  _primaryController.clear();

                                  // Refresh the thoughts
                                  // _fetchThoughts();
                                }
                              },
                              colorIndex: 2,
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
              ComindSearchResultTable(searchResults: searchResults),
          ],
        ),
      ),
    );
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
                color: Theme.of(context).colorScheme.onBackground,
              ),
              children: <TextSpan>[
                // Show cosine similarity
                TextSpan(
                  text:
                      "${(result.cosineSimilarity * 100).toStringAsFixed(0)}% ",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                ),

                // Thought body
                TextSpan(
                  text: result.body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
  }) : super(key: key);

  final List<SearchResult> searchResults;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      height: 200,
      child: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          return Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Text(
                    searchResults[index].username,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
              Expanded(
                flex: 1, // Increase flex to make this column take more space
                child: Container(
                  child: Text(
                    "${(searchResults[index].cosineSimilarity * 100).toStringAsFixed(0)}% ",
                  ), // This is your body column
                ),
              ),
              Expanded(
                flex: 6, // Increase flex to make this column take more space
                child: Container(
                  child: Text(
                      searchResults[index].body), // This is your body column
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
