import 'dart:math';

import 'package:comind/color_button.dart';
import 'package:comind/colors.dart';
import 'package:comind/providers.dart';
import 'package:comind/think_button.dart';
import 'package:comind/thought_table.dart';
import 'package:flutter/material.dart';
import 'package:comind/text_button.dart';
import 'package:comind/types/thought.dart';
import 'package:comind/api.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Enums for type of text field
enum TextFieldType { main, edit, fullscreen, inline, newThought }

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
  final Function(String)? onThoughtSubmitted;
  final Function(Thought)? onThoughtEdited;

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _MainTextFieldState createState() => _MainTextFieldState();
}

class _MainTextFieldState extends State<MainTextField> {
  _MainTextFieldState();

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
    //
    // DECORATION FOR THE MAIN TEXT FIELD
    //
    var mainInputDecoration = InputDecoration(
      // The label that appears at the top of the text box.
      // label: Text(
      //   widget.type == TextFieldType.main ? uiMode : "Edit",
      //   style: Provider.of<ComindColorsNotifier>(context).textTheme.titleLarge,
      // ),

      // Handle label for the text box label
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
      contentPadding: const EdgeInsets.fromLTRB(18, 12, 38, 12),
      enabledBorder: OutlineInputBorder(
        // borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(ComindColors.bubbleRadius),
          topRight: Radius.circular(ComindColors.bubbleRadius),
        ),
        borderSide: BorderSide(
          width: 1,
          color: Provider.of<ComindColorsNotifier>(context)
              .colorScheme
              .onPrimary
              .withAlpha(64),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        // borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
        borderSide: BorderSide(
          width: 1,
          color: Provider.of<ComindColorsNotifier>(context)
              .colorScheme
              .onBackground
              .withAlpha(126),
        ),
      ),
    );

    //
    // DECORATION FOR THE EDIT TEXT FIELD
    //
    var editInputDecoration = InputDecoration(
      label: Text(
        "Edit",
        style: Provider.of<ComindColorsNotifier>(context).textTheme.titleSmall,
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
      contentPadding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
        borderSide: BorderSide(
          width: 1,
          color: Provider.of<ComindColorsNotifier>(context)
              .colorScheme
              .onPrimary
              .withAlpha(64),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
        borderSide: BorderSide(
          width: 1,
          color: Provider.of<ComindColorsNotifier>(context)
              .colorScheme
              .onPrimary
              .withAlpha(128),
        ),
      ),
    );

    //
    // DECORATION FOR THE INLINE TEXT FIELD
    //
    var inlineInputDecoration = InputDecoration(
      label: Text(
        "Insert",
        style: Provider.of<ComindColorsNotifier>(context).textTheme.titleSmall,
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
      contentPadding: const EdgeInsets.fromLTRB(10, 16, 36, 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
        borderSide: BorderSide(
          width: 1,
          color: Provider.of<ComindColorsNotifier>(context)
              .colorScheme
              .onPrimary
              .withAlpha(64),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
        borderSide: BorderSide(
          width: 1,
          color: Provider.of<ComindColorsNotifier>(context)
              .colorScheme
              .onPrimary
              .withAlpha(128),
        ),
      ),
    );

    //
    // DECORATION FOR THE NEW TEXT FIELD
    //
    var newInputDecoration = InputDecoration(
      // The label that appears at the top of the text box.
      // label: Text(
      //   widget.type == TextFieldType.main ? uiMode : "Edit",
      //   style: Provider.of<ComindColorsNotifier>(context).textTheme.titleLarge,
      // ),

      // Handle label for the text box label
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
      contentPadding: const EdgeInsets.fromLTRB(18, 12, 38, 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
        borderSide: BorderSide(
          width: 1,
          color: Provider.of<ComindColorsNotifier>(context)
              .colorScheme
              .onPrimary
              .withAlpha(0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
        borderSide: BorderSide(
          width: 1,
          color: Provider.of<ComindColorsNotifier>(context)
              .colorScheme
              .onBackground
              .withAlpha(255),
        ),
      ),
    );

    return SizedBox(
      width: widget.type != TextFieldType.newThought
          ? min(ComindColors.maxWidth, MediaQuery.of(context).size.width)
          : min(
              ComindColors.maxWidth - 130,
              MediaQuery.of(context).size.width -
                  80), // TODO this shit is hacky as fuck
      child: Padding(
        padding: widget.type == TextFieldType.main
            ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
            : const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Text box
                Padding(
                  padding: widget.type == TextFieldType.main
                      ? const EdgeInsets.fromLTRB(12, 16, 12, 16)
                      : const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Material(
                    // elevation: 2,
                    borderRadius:
                        BorderRadius.circular(ComindColors.bubbleRadius),
                    color: Provider.of<ComindColorsNotifier>(context)
                        .colorScheme
                        .background,
                    child: Container(
                      // Bordered
                      decoration: const BoxDecoration(
                          // borderRadius:
                          //     BorderRadius.circular(ComindColors.bubbleRadius),
                          // border: Border.all(
                          //   width: 1,
                          //   color: Provider.of<ComindColorsNotifier>(context)
                          //       .colorScheme
                          //       .onPrimary
                          //       .withAlpha(64),
                          // ),
                          ),

                      // decoration: BoxDecoration(
                      // borderRadius:
                      //     BorderRadius.circular(ComindColors.bubbleRadius),
                      // color: Provider.of<ComindColorsNotifier>(context)
                      //     .colorScheme
                      //     .surface
                      //     .withAlpha(30)),
                      child: RawKeyboardListener(
                        focusNode: focusNode,
                        child: TextField(
                          scrollController: _scrollController,
                          // keyboardType: TextInputType.multiline,
                          maxLines: 10,
                          minLines: 1,
                          // textInputAction: TextInputAction.send,
                          style: Provider.of<ComindColorsNotifier>(context)
                              .textTheme
                              .bodyMedium,
                          autofocus: widget.type == TextFieldType.main ||
                              widget.type == TextFieldType.newThought,
                          controller: widget._primaryController,

                          onSubmitted: (value) => {
                            _submit(context)(),
                            // Clear the text field because sometimes random newline chars
                            // get added
                            widget._primaryController.clear(),
                          },

                          // TODO #12 add the command processing stuff back in.
                          // Can't turn it on because enabling the onChange function
                          // breaks backspacing on android/linux.
                          // see https://stackoverflow.com/questions/71783012/backspace-text-field-flutter-on-android-devices-not-working
                          // onChanged: ... // do all the command processing stuff

                          // Cursor stuff
                          cursorWidth: 8,
                          cursorColor:
                              Provider.of<ComindColorsNotifier>(context)
                                  .colorScheme
                                  .onBackground,
                          decoration: widget.type == TextFieldType.main
                              ? mainInputDecoration
                              : widget.type == TextFieldType.edit
                                  ? editInputDecoration
                                  : widget.type == TextFieldType.inline
                                      ? inlineInputDecoration
                                      : newInputDecoration,
                        ),
                      ),
                    ),
                  ),
                ),

                // ThinkButton only, send button
                Positioned(
                  bottom: widget.type == TextFieldType.newThought ? 5 : 21,
                  right: widget.type == TextFieldType.newThought ? 5 : 16,
                  child: Visibility(
                    visible: widget.type == TextFieldType.main ||
                        widget.type == TextFieldType.newThought,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      child: ThinkButton(
                        onPressed: () {
                          _submit(context)();

                          // Clear the text field because sometimes random newline chars
                          // get added
                          widget._primaryController.clear();
                        },
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
    return widget.type == TextFieldType.main ||
            widget.type == TextFieldType.inline
        ? () {
            widget.onThoughtSubmitted!(widget._primaryController.text);
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
                  widget.thought?.body = widget._primaryController.text;

                  // Close the editor
                  if (widget.toggleEditor != null) {
                    widget.toggleEditor!();
                  }

                  // Return the new thought
                  if (widget.onThoughtEdited != null &&
                      widget.thought != null) {
                    widget.onThoughtEdited!(widget.thought!);

                    // Clear the text field
                    widget._primaryController.clear();
                  }
                } else {
                  // TODO no thought was passed but we are in edit mode
                  throw Exception(
                      "No thought was passed but we are in edit mode");
                }
              }
            : widget.type == TextFieldType.newThought &&
                    widget.onThoughtSubmitted != null
                ? () {
                    widget.onThoughtSubmitted!(widget._primaryController.text);
                  }
                : () {
                    // The else clause, who knows what the fuck is supposed to be here.
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
}
