import 'dart:math';

import 'package:comind/api.dart';
import 'package:comind/colors.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/think_button.dart';
import 'package:comind/thought_table.dart';
import 'package:flutter/material.dart';
import 'package:comind/types/thought.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:easy_debounce/easy_debounce.dart';

// Enums for type of text field
enum TextFieldType { main, edit, fullscreen, inline, newThought }

// Enums for the mode of the text field
enum TextFieldMode { think, search }

// Methods to check mode status
bool isSearchMode(TextFieldMode mode) {
  return mode == TextFieldMode.search;
}

bool isThinkMode(TextFieldMode mode) {
  return mode == TextFieldMode.think;
}

// Methods to convert text field modes into verbs
String modeToString(TextFieldMode mode) {
  if (mode == TextFieldMode.think) {
    return "Think";
  } else if (mode == TextFieldMode.search) {
    return "Search";
  } else {
    return "Unknown";
  }
}

//
// The primary text field for Comind, stateful version
//
// ignore: must_be_immutable
class MainTextField extends StatefulWidget {
  MainTextField({
    super.key,
    required TextEditingController primaryController,
    required this.colors,

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
  final ComindColorsNotifier colors;

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
  TextFieldMode textFieldMode = TextFieldMode.think;

  List<Thought> searchResults = [
    // Thought.fromString("Or, maybe not. We'll never know.", "cameron", true,
    //     title: "This could be what you're looking for")
  ];

  // Things to track textfield keys
  final FocusNode focusNode = FocusNode();

  // Bool for whether control is pressed
  bool controlPressed = false;

  // Perform semantic search and add the results to the search results
  void performSearch(String query) {
    //
    EasyDebounce.debounce(
        'my-debouncer', // <-- An ID for this particular debouncer
        Duration(milliseconds: 1000), // <-- The debounce duration
        () {
      searchThoughts(context, query).then((value) => setState(() {
            searchResults = value;
          }));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Set up a listener for the controller
    widget._primaryController.addListener(() {
      // If the value starts with '/', then we're in search mode
      // "." is think mode
      final value = widget._primaryController.text;
      if (value.length == 1) {
        if (value.startsWith("/") && !isSearchMode(textFieldMode)) {
          widget._primaryController.clear();
          setState(() {
            textFieldMode = TextFieldMode.search;
          });
        } else if (value.startsWith(".") && !isThinkMode(textFieldMode)) {
          widget._primaryController.clear();
          setState(() {
            textFieldMode = TextFieldMode.think;
          });
        }
      } else if (value.length > 1 && isSearchMode(textFieldMode)) {
        performSearch(value);
      }
    });

    //
    // DECORATION FOR THE MAIN TEXT FIELD
    //
    var mainInputDecoration = InputDecoration(
      hintText: isSearchMode(textFieldMode)
          ? "Search"
          : widget.colors.publicMode
              ? "Public mode"
              : "Private mode",
      hintStyle: getTextTheme(context)
          .titleMedium!
          .copyWith(color: widget.colors.colorScheme.onPrimary.withAlpha(80)),

      // Handle label for the text box label
      floatingLabelBehavior: FloatingLabelBehavior.always,
      floatingLabelStyle: TextStyle(
        color: widget.colors.colorScheme.onPrimary.withAlpha(180),
      ),
      labelStyle: TextStyle(
        color: widget.colors.colorScheme.onPrimary.withAlpha(180),
      ),
      contentPadding: const EdgeInsets.fromLTRB(8, 22, 38, 22),

      // Top and bottom border only.
      // This is handled by the decoration for the container
      // wrapping the text field.
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
        // borderSide: BorderSide(
        //   width: 0,
        //   color: widget.colors
        //       .colorScheme
        //       .onBackground
        //       .withAlpha(32),
        // ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
        // borderSide: BorderSide(
        //   width: 1,
        //   color: widget.colors
        //       .colorScheme
        //       .onBackground
        //       .withAlpha(64),
        // ),
      ),
    );

    //
    // DECORATION FOR THE EDIT TEXT FIELD
    //
    var editInputDecoration = mainInputDecoration;

    //
    // DECORATION FOR THE INLINE TEXT FIELD
    //
    var inlineInputDecoration = InputDecoration(
      label: Text(
        "Insert",
        style: widget.colors.textTheme.titleSmall,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      floatingLabelStyle: TextStyle(
        color: widget.colors.colorScheme.onPrimary.withAlpha(180),
      ),
      labelStyle: TextStyle(
        color: widget.colors.colorScheme.onPrimary.withAlpha(180),
      ),
      contentPadding: const EdgeInsets.fromLTRB(10, 16, 36, 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
        borderSide: BorderSide(
          width: 1,
          color: widget.colors.colorScheme.onPrimary.withAlpha(64),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
        borderSide: BorderSide(
          width: 1,
          color: widget.colors.colorScheme.onPrimary.withAlpha(128),
        ),
      ),
    );

    //
    // DECORATION FOR THE NEW TEXT FIELD
    //
    var newInputDecoration = mainInputDecoration;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: SizedBox(
        width: widget.type != TextFieldType.newThought
            ? min(ComindColors.maxWidth, MediaQuery.of(context).size.width)
            : min(
                ComindColors.maxWidth - 130,
                MediaQuery.of(context).size.width -
                    80), // this shit is hacky as fuck
        child: Column(
          children: [
            // Visibility(
            //   visible: widget.type == TextFieldType.main,
            //   child: Container(
            //     width: double.infinity,
            //     child: Row(
            //       children: [
            //         // Think mode
            //         Padding(
            //           padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            //           child: Container(
            //             decoration: isThinkMode(textFieldMode)
            //                 ? BoxDecoration(
            //                     border: Border(
            //                       bottom: BorderSide(
            //                         width: 6,
            //                         color: widget.colors.primary,
            //                       ),
            //                     ),
            //                   )
            //                 : BoxDecoration(),
            //             child: Text(
            //               modeToString(TextFieldMode.think),
            //               style: widget.colors.textTheme.titleMedium,
            //               textAlign: TextAlign.start,
            //             ),
            //           ),
            //         ),

            //         // Search mode
            //         Padding(
            //           padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            //           child: Container(
            //             decoration: isSearchMode(textFieldMode)
            //                 ? BoxDecoration(
            //                     border: Border(
            //                       bottom: BorderSide(
            //                         width: 6,
            //                         color: widget.colors.primary,
            //                       ),
            //                     ),
            //                   )
            //                 : BoxDecoration(),
            //             child: Text(
            //               modeToString(TextFieldMode.search),
            //               style: widget.colors.textTheme.titleMedium,
            //               textAlign: TextAlign.start,
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            Stack(
              clipBehavior: Clip.none,
              children: [
                // Text box
                Material(
                  elevation: 6,
                  borderRadius:
                      BorderRadius.circular(ComindColors.bubbleRadius),
                  child: Container(
                    // Bordered
                    decoration: BoxDecoration(
                      // borderRadius:
                      //     BorderRadius.circular(ComindColors.bubbleRadius),
                      // border: Border(
                      //   // left: BorderSide(
                      //   //   width: 1,
                      //   //   color: widget.colors.onPrimary.withAlpha(128),
                      //   // ),
                      //   // top: BorderSide(
                      //   //   width: 1,
                      //   //   color:
                      //   //       widget.colors.colorScheme.primary.withAlpha(128),
                      //   // ),
                      //   // bottom: BorderSide(
                      //   //   width: 1,
                      //   //   color: widget.colors.colorScheme.onPrimary
                      //   //       .withAlpha(128),
                      //   // ),
                      // ),

                      border: Border.all(
                        width: 2,
                        color:
                            widget.colors.colorScheme.onPrimary.withAlpha(128),
                      ),

                      // Fill color
                      // color: widget.colors
                      //     .colorScheme
                      //     .surface,
                      borderRadius:
                          BorderRadius.circular(ComindColors.bubbleRadius),

                      // Fill color
                      // color: widget.colors
                      //     .colorScheme
                      //     .surface,
                    ),

                    // decoration: BoxDecoration(
                    // borderRadius:
                    //     BorderRadius.circular(ComindColors.bubbleRadius),
                    // color: widget.colors
                    //     .colorScheme
                    //     .surface
                    //     .withAlpha(30)),
                    child: KeyboardListener(
                      focusNode: focusNode,
                      onKeyEvent: (KeyEvent event) {
                        if (focusNode.hasFocus) {
                          if (event.logicalKey ==
                                  LogicalKeyboardKey.controlLeft &&
                              event is KeyDownEvent) {
                            controlPressed = true;
                          } else if (event.logicalKey ==
                                  LogicalKeyboardKey.controlLeft &&
                              event is KeyUpEvent) {
                            controlPressed = false;
                          }

                          if (event.logicalKey == LogicalKeyboardKey.enter &&
                              controlPressed) {
                            _submit(context)();
                            widget._primaryController.clear();
                          }
                        }
                      },
                      child: TextField(
                        scrollController: _scrollController,
                        // keyboardType: TextInputType.multiline,
                        maxLines: 20,
                        minLines: 1,
                        // textInputAction: TextInputAction.send,
                        style: widget.colors.textTheme.bodyMedium,

                        // Autofocus if main text field or a new thought,
                        // since the user
                        autofocus: widget.type == TextFieldType.main ||
                            widget.type == TextFieldType.newThought,
                        controller: widget._primaryController,
                        textInputAction: TextInputAction.newline,

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
                        cursorColor: widget.colors.colorScheme.onBackground,
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

                // ThinkButton only, send button
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Visibility(
                    visible: !isSearchMode(textFieldMode) &&
                        (widget.type == TextFieldType.main ||
                            widget.type == TextFieldType.newThought ||
                            widget.type == TextFieldType.inline),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: ThinkButton(
                        icon: LineIcons.lightbulb,
                        // icon: widget.colors
                        //         .publicMode
                        //     ? LineIcons.windowRestore
                        //     : LineIcons.lightbulb,
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

                // Search button if in search mode
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Visibility(
                    visible: isSearchMode(textFieldMode),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: ThinkButton(
                        icon: LineIcons.search,
                        onPressed: () {
                          // Clear the text field because sometimes random newline chars
                          // get added
                          widget._primaryController.clear();
                        },
                      ),
                    ),
                  ),
                ),

                // Public or private mode overlay
                // Positioned(
                //   bottom: -10,
                //   right: 0,
                //   child: Visibility(
                //     visible: widget.type == TextFieldType.main,
                //     child: Padding(
                //       padding: const EdgeInsets.fromLTRB(50, 12, 20, 12),
                //       child: Opacity(
                //         opacity: 0.5,
                //         child: Text(
                //           widget.colors.publicMode
                //               ? "(public)"
                //               : "(private)",
                //           style: widget.colors
                //               .textTheme
                //               .labelSmall,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),

            // Add the search results if they are not empty
            if (isSearchMode(textFieldMode) && searchResults.isNotEmpty)
              ThoughtTable(thoughts: searchResults),
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
            // Check if the thought is just whitespace,
            // if so, don't submit it.
            final trimmed = widget._primaryController.text.trim();
            if (trimmed.isEmpty) {
              return;
            }
            widget.onThoughtSubmitted!(trimmed);
          }
        : widget.type == TextFieldType.edit
            ? () {
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
        ? widget.colors.colorScheme.onPrimary
        : widget.colorIndex == 1
            ? widget.colors.colorScheme.primary.withAlpha(128)
            : widget.colorIndex == 2
                ? widget.colors.colorScheme.secondary.withAlpha(128)
                : widget.colors.colorScheme.tertiary.withAlpha(128);
  }
}

class ColorButton extends StatelessWidget {
  // Things
  final bool isUnderlined;
  final Color color;
  final TextStyle textStyle;
  final String text;

  // Creator method
  ColorButton(
      {required this.text,
      this.isUnderlined = false,
      this.color = Colors.transparent,
      required this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: Container(
        decoration: isUnderlined
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 6,
                    color: color,
                  ),
                ),
              )
            : const BoxDecoration(),
        child: Text(
          text,
          style: textStyle,
          textAlign: TextAlign.start,
        ),
      ),
    );
  }
}
