// Imports
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
  String uiMode = "think";

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
        child: Stack(
          children: [
            // Text box
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
              child: Container(
                decoration: BoxDecoration(
                    // color: Theme.of(context).colorScheme.surfaceVariant.withAlpha(100),
                    ),
                child: TextField(
                  cursorWidth: 10,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 16),
                  autofocus: false,
                  controller: _primaryController,

                  // If it starts with /, it's a command
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        uiMode = "think";
                      });
                    } else if (value == "/search" || value == "/s") {
                      setState(() {
                        uiMode = "search";
                      });

                      // Clear the text field
                      _primaryController.clear();
                    } else {
                      setState(() {});
                    }
                  },
                  maxLines: null,

                  // TODO make this row toggle send button in bottom right
                  // onTap: () {
                  //   // Toggle the visibility
                  //   // setState(() {
                  //   //   editVisibilityList[0] = true;
                  //   // });
                  // },
                  cursorColor: Theme.of(context).colorScheme.primary,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
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

            // UI mode
            Positioned(
              top: -18,
              left: 8,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(2, 16, 0, 0),
                child: Row(
                  children: [
                    // Send button
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                        child: ComindTextButton(
                            text: uiMode == "think" ? "Think" : "Search",
                            fontSize: 12,
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
                            opacity: 0.5,
                            textStyle: const TextStyle(
                                fontFamily: "Bungee", fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Send button
            Positioned(
              bottom: -6,
              right: 8,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
                child: Row(
                  children: [
                    // Send button
                    if (_primaryController.text.isNotEmpty)
                      ComindTextButton(
                          text: "Send",
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
                          textStyle: const TextStyle(
                              fontFamily: "Bungee", fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
