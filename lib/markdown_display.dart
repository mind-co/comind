import 'dart:math';

import 'package:comind/api.dart';
// import 'package:comind/concept_syntax.dart';
import 'package:comind/input_field.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/providers.dart';
import 'package:comind/text_button.dart';
import 'package:comind/thought_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:google_fonts/google_fonts.dart';
import 'package:comind/types/thought.dart';
import 'package:comind/colors.dart';
import 'package:provider/provider.dart';
import 'package:comind/cine_wave.dart';
import 'package:url_launcher/url_launcher.dart';

enum MarkdownDisplayType {
  fullScreen,
  inline,
  searchResult,
  newThought,
}

//
// ignore: must_be_immutable
class MarkdownThought extends StatefulWidget {
  MarkdownThought(
      {super.key,
      required this.thought,
      //Opacity/hover opacity, default to 1/1
      this.type = MarkdownDisplayType.inline,
      this.opacity = 1.0,
      this.opacityOnHover = 1.0,
      this.infoMode = false,
      this.relatedMode = false,
      this.parentThought,
      this.linkable = false,
      this.viewOnly = false,
      this.selectable = true});

  final Thought thought;
  final double opacity;
  final double opacityOnHover;
  bool selectable;
  bool infoMode;
  bool relatedMode;
  bool viewOnly;
  MarkdownDisplayType type;
  String? parentThought;
  bool showTextBox = false;
  bool showBody = true;
  final bool linkable;

  // store whether hovered
  bool hovered = false;

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _MarkdownThoughtState(
        opacity: opacity,
        opacityOnHover: opacityOnHover,
      );
}

class _MarkdownThoughtState extends State<MarkdownThought> {
  _MarkdownThoughtState({
    //Opacity/hover opacity, default to 1/1
    this.opacity = 1.0,
    this.opacityOnHover = 1.0,
  });

  final double opacity;
  final double opacityOnHover;
  final _editController = TextEditingController();
  final _addController = TextEditingController();
  List<Thought> relatedResults = [];
  final ComindColors colors = ComindColors();
  final int outlineAlpha = 120;
  final int outlineAlphaHover = 200;

  // store whether hovered
  bool hovered = false;

  // whether the "more" button has been clicked
  bool moreClicked = false;

  // Whether the "new thought" editor is open
  bool newThoughtOpen = false;

  // Set initial state
  @override
  void initState() {
    super.initState();

    if (widget.type == MarkdownDisplayType.searchResult) {
      widget.showBody = false;
    } else if (widget.type == MarkdownDisplayType.inline) {
      widget.showBody = true;
      widget.showTextBox = false;
    } else if (widget.type == MarkdownDisplayType.fullScreen) {
      widget.showBody = true;
      widget.showTextBox = true;
    }
  }

  // Initialization
  @override
  Widget build(BuildContext context) {
    var onBackground =
        Provider.of<ComindColorsNotifier>(context).colorScheme.onBackground;

    // // Return just a textbox for debug
    // return Text(
    //   widget.thought.body,
    //   style: Provider.of<ComindColorsNotifier>(context).textTheme.bodyMedium,
    // );

    return Padding(
      padding: widget.type == MarkdownDisplayType.fullScreen
          ? const EdgeInsets.fromLTRB(0, 0, 0, 0)
          // : const EdgeInsets.fromLTRB(16, 16, 16, 24),
          // : const EdgeInsets.fromLTRB(16, 0, 16, 0),
          : widget.type == MarkdownDisplayType.searchResult
              ? const EdgeInsets.fromLTRB(0, 0, 0, 0)
              : const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(children: [
        // Main text box
        Card(
          // color: Colors.red,
          color: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Cinewave username
                  Row(
                    children: [
                      // Cinewave username line
                      Expanded(
                        child: Material(
                            child: InkWell(
                                borderRadius: BorderRadius.circular(
                                    ComindColors.bubbleRadius),
                                onTap: () => {
                                      // Toggle the body
                                      setState(() {
                                        widget.showBody = !widget.showBody;
                                      })
                                    },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(4, 8, 4, 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title
                                      MarkdownDisplayType.newThought !=
                                              widget.type
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      12, 0, 8, 0),
                                              // Version where body is truncated
                                              child: widget.thought.title == ""
                                                  ? Container()
                                                  : RichText(
                                                      overflow:
                                                          TextOverflow.fade,
                                                      softWrap: false,
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: widget
                                                                .thought.title,
                                                            style: Provider.of<
                                                                        ComindColorsNotifier>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .textTheme
                                                                .titleMedium,
                                                          ),
                                                        ],
                                                      ),
                                                    )

                                              // child: Text(thought.title, style: getTextTheme(context).labelMedium),
                                              // child: Text(thought.title, style: getTextTheme(context).titleSmall),
                                              )
                                          : Container(),

                                      // Expanded thing to fill the space between the title and the username
                                      // Expanded(
                                      //     child: SizedBox(
                                      //         height: 5,
                                      //         child: Opacity(
                                      //             opacity: 0.0,
                                      //             child: Divider(
                                      //               color: onBackground
                                      //                   .withAlpha(64),
                                      //             )))),

                                      // Username
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 0, 12, 0),
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: widget.thought.isPublic
                                                    ? "🌎 "
                                                    : "🔒 ",
                                                style: Provider.of<
                                                            ComindColorsNotifier>(
                                                        context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),

                                              // Timestamp
                                              TextSpan(
                                                text: formatTimestamp(
                                                    widget.thought.dateCreated),
                                                style: Provider.of<
                                                            ComindColorsNotifier>(
                                                        context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),

                                              // Timestamp
                                              TextSpan(
                                                text: " · ",
                                                style: Provider.of<
                                                            ComindColorsNotifier>(
                                                        context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),

                                              TextSpan(
                                                text: " ",
                                                style: Provider.of<
                                                            ComindColorsNotifier>(
                                                        context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                              TextSpan(
                                                text: widget.thought.username,
                                                style: Provider.of<
                                                            ComindColorsNotifier>(
                                                        context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ), // Username
                                    ],
                                  ),
                                ))),
                      ),

                      // // More button
                      // Visibility(
                      //   // visible:
                      //   //     widget.type == MarkdownDisplayType.,
                      //   child: Padding(
                      //     padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                      //     child: IconButton(
                      //       padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      //       visualDensity: const VisualDensity(
                      //           horizontal: -4, vertical: -4),
                      //       enableFeedback: true,
                      //       splashRadius: 16,
                      //       onPressed: () {
                      //         // Toggle the body
                      //         setState(() {
                      //           moreClicked = !moreClicked;
                      //         });
                      //       },
                      //       icon: Icon(
                      //         Icons.more_horiz,
                      //         size: 16,
                      //         color: Provider.of<ComindColorsNotifier>(context)
                      //             .colorScheme
                      //             .onBackground
                      //             .withAlpha(200),
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      // Link button for child thoughts
                      Visibility(
                        visible:
                            widget.type == MarkdownDisplayType.searchResult,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                          child: IconButton(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            visualDensity: const VisualDensity(
                                horizontal: -4, vertical: -4),
                            enableFeedback: true,
                            splashRadius: 16,

                            // On pressed here links the notes to the parent, if
                            // there is one
                            onPressed: () async {
                              // If there is a parent thought
                              if (widget.parentThought != null) {
                                // Link the thoughts
                                if (widget.thought.id != widget.parentThought &&
                                    widget.parentThought != null) {
                                  await linkThoughts(context, widget.thought.id,
                                      widget.parentThought!);
                                }
                              }
                            },
                            // icon: Text(
                            //   "{O}",
                            //   style: TextStyle(
                            //       fontFamily: "Bungee Pop",
                            //       fontSize: 12,
                            //       fontWeight: FontWeight.w400),
                            // )

                            icon: Icon(
                              Icons.add_link,
                              size: 16,
                              color: Provider.of<ComindColorsNotifier>(context)
                                  .colorScheme
                                  .onBackground
                                  .withAlpha(200),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Show cosine similarity
                  // Text(widget.thought.cosineSimilarity.toString(),
                  //     style: Provider.of<ComindColorsNotifier>(context)
                  //         .textTheme
                  //         .bodySmall),

                  // Add thought body
                  Visibility(
                      visible: widget.showBody && !widget.showTextBox,
                      child: thoughtBody(context)),

                  expandableEditBox(context),

                  // Alternative action row
                  Visibility(
                      visible:
                          widget.type != MarkdownDisplayType.searchResult &&
                              widget.showBody,
                      child: alternativeActionRow(context, onBackground)),

                  // Show new thought box
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                    child: Row(
                      children: [
                        Visibility(
                          visible: newThoughtOpen,
                          child: IconButton(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                            enableFeedback: true,
                            splashRadius: 16,
                            onPressed: () {
                              // Toggle the body
                              setState(() {
                                newThoughtOpen = !newThoughtOpen;
                              });
                            },
                            icon: Icon(
                              Icons.subdirectory_arrow_right,
                              size: 16,
                              color: Provider.of<ComindColorsNotifier>(context)
                                  .colorScheme
                                  .onBackground
                                  .withAlpha(200),
                            ),
                          ),
                        ),

                        // New thought box
                        newThoughtBox(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Add the action row on bottom
        // actionRow(
        //     context, edgeInsets2, edgeInsets, buttonFontSize, buttonOpacity),
      ]),
    );
  }

  // Handles the new thought box
  Visibility newThoughtBox(BuildContext context) {
    return Visibility(
      visible: newThoughtOpen,
      child: Padding(
        // Top padding to separate it from the body
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: MainTextField(
            thought: Thought.fromString(
                "",
                Provider.of<AuthProvider>(context, listen: false).username,
                true),
            onThoughtSubmitted: (String body) async {
              // Make a new thought
              var thought = Thought.fromString(
                  body,
                  Provider.of<AuthProvider>(context, listen: false).username,
                  Provider.of<ComindColorsNotifier>(context, listen: false)
                      .publicMode);

              // Save the thought
              await saveThought(context, thought);

              // Clear the text box
              _addController.clear();

              // Close the text box
              setState(() {
                newThoughtOpen = false;
              });
            },
            primaryController: _addController,
            toggleEditor: () {
              // Close the text box
              setState(() {
                newThoughtOpen = false;
              });
            },
            type: TextFieldType.newThought),
      ),
    );
  }

  // An edit box that expands when clicked
  Visibility expandableEditBox(BuildContext context) {
    return Visibility(
      visible: !widget.viewOnly && widget.showTextBox,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: MainTextField(
              thought: widget.thought,
              onThoughtEdited: (Thought thought) async {
                // Update the thought
                await saveThought(context, thought);
              },
              primaryController: _editController,
              toggleEditor: () {
                // Close the text box
                setState(() {
                  widget.showTextBox = false;
                });
              },
              type: TextFieldType.edit)),
    );
  }

  // The action row
  Row alternativeActionRow(BuildContext context, Color onBackground) {
    // The info button
    // var infoButton = newButton(
    //     onBackground, context, widget.infoMode ? "Close" : "Info", () {
    //   // Toggle info mode
    //   setState(() {
    //     widget.infoMode = !widget.infoMode;
    //   });
    // });

    // The expand button
    var expandButton = newButton(
        onBackground, context, widget.showBody ? "Close" : "View", () {
      // Show the full thought
      setState(() {
        widget.showBody = !widget.showBody;
      });
    });

    // The "show linked" button
    var showLinkedButton = newButton(
        onBackground, context, widget.relatedMode ? "Close" : "More", () async {
      if (relatedResults.isEmpty) {
        // Semantic search on the body of the text
        var res = await searchThoughts(context, widget.thought.body,
            associatedId: widget.thought.id);

        // Toggle info mode
        setState(() {
          widget.relatedMode = !widget.relatedMode;
          relatedResults =
              res.where((item) => widget.thought.id != item.id).toList();
        });
      } else {
        setState(() {
          widget.relatedMode = !widget.relatedMode;
        });
      }
    });

    // The "add thought" button
    var addThoughtButton = Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
      child: newButton(onBackground, context, newThoughtOpen ? "Close" : "Add",
          () {
        // Toggle the new thought box
        setState(() {
          newThoughtOpen = !newThoughtOpen;
        });
      }),
    );

    var lockButton = newIconButton(
      context,
      () {
        // Toggle public/private
        setState(() {
          widget.thought.togglePublic(context);
          // thought.isPublic = !thought.isPublic;
        });
      },
      Icon(
        widget.thought.isPublic ? Icons.lock_open : Icons.lock,
        size: 16,
        color: Provider.of<ComindColorsNotifier>(context)
            .colorScheme
            .onPrimary
            .withAlpha(128),
      ),
    );

    // Local variable storing the delete button underneath each thought
    // var deleteButton = Padding(
    //   padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
    //   child: IconButton(
    //     padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    //     visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
    //     enableFeedback: true,
    //     splashRadius: 16,
    //     ,
    //     icon: Icon(
    //       Icons.delete,
    //       size: 16,
    //       color: Provider.of<ComindColorsNotifier>(context)
    //           .colorScheme
    //           .onPrimary
    //           .withAlpha(128),
    //     ),
    //   ),
    // );

    var deleteButton = newIconButton(context, () async {
      // TODO delete the thought
      bool? shouldDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Provider.of<ComindColorsNotifier>(context)
                .colorScheme
                .background,
            surfaceTintColor: Provider.of<ComindColorsNotifier>(context)
                .colorScheme
                .secondary
                .withAlpha(64),
            title: const Text(
              'Delete thought?',
              style: TextStyle(
                  fontFamily: "Bungee",
                  fontSize: 36,
                  fontWeight: FontWeight.w400),
            ),
            content: const Text(
                'You sure you wanna delete this note? Cameron is really, really bad at making undo buttons. \n\nIf you delete this it will prolly be gone forever.'),
            actions: <Widget>[
              ComindTextButton(
                text: "Cancel",
                opacity: 1,
                fontSize: 18,
                colorIndex: 1,
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              ComindTextButton(
                text: "Delete",
                opacity: 1,
                fontSize: 18,
                colorIndex: 3,
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
            actionsAlignment: MainAxisAlignment.spaceBetween,
          );
        },
      );

      if (shouldDelete == true) {
        // ignore: use_build_context_synchronously
        deleteThought(context, widget.thought.id);

        // Remove the thought from the list
        Provider.of<ThoughtsProvider>(context, listen: false)
            .removeThought(widget.thought);
      }
    },
        Icon(
          Icons.delete,
          size: 16,
          color: Provider.of<ComindColorsNotifier>(context)
              .colorScheme
              .onPrimary
              .withAlpha(128),
        ));

    // Local variable for edit button
    var editThoughtButton = Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
      child: newButton(
          onBackground, context, widget.showTextBox ? "Close" : "Edit", () {
        // Update the edit box with the thought
        _editController.text = widget.thought.body;

        // Toggle the new thought box
        setState(() {
          widget.showTextBox = !widget.showTextBox;
        });
      }),
    );

    // Info button
    var infoButton = newIconButton(
      context,
      () {
        // Toggle info mode
        setState(() {
          widget.infoMode = !widget.infoMode;
        });
      },
      Icon(
        Icons.info_outline,
        size: 16,
        color: Provider.of<ComindColorsNotifier>(context)
            .colorScheme
            .onPrimary
            .withAlpha(128),
      ),
    );

    // the more button
    var moreButton = newIconButton(
      context,
      () {
        // Toggle info mode
        setState(() {
          moreClicked = !moreClicked;
        });
      },
      Icon(
        Icons.more_horiz,
        size: 16,
        color: Provider.of<ComindColorsNotifier>(context)
            .colorScheme
            .onPrimary
            .withAlpha(128),
      ),
    );

    //
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      // Lock icon
      lockButton,

      // Buttons
      Visibility(
          visible:
              !widget.showTextBox && !widget.relatedMode && !newThoughtOpen,
          child: deleteButton),

      // Edit button
      Visibility(
          visible: !widget.viewOnly &&
              !widget.relatedMode &&
              !newThoughtOpen &&
              widget.thought.username ==
                  Provider.of<AuthProvider>(context).username,
          child: editThoughtButton),

      // Info button
      Visibility(
          visible: !widget.relatedMode && !newThoughtOpen, child: infoButton),

      Visibility(
          visible: widget.type == MarkdownDisplayType.searchResult &&
              !newThoughtOpen,
          child: expandButton),

      // Show linked/more button
      // Visibility(visible: !newThoughtOpen, child: showLinkedButton),

      // Add thought button
      // addThoughtButton,

      // More options button
      Visibility(visible: !newThoughtOpen, child: moreButton),
    ]);
  }

  Padding newIconButton(
      BuildContext context, void Function()? onPressed, Icon icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
      child: IconButton(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        enableFeedback: true,
        splashRadius: 16,
        onPressed: onPressed,
        icon: icon,
      ),
    );
  }

  TextButton newButton(Color onBackground, BuildContext context, String text,
      void Function()? onPressed) {
    return TextButton(
        style: ButtonStyle(
          // Set background color transparent always
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              return Colors.transparent;
            },
          ),

          // Overlay color on hover
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              return onBackground.withAlpha(16);
            },
          ),

          // Make text onBackground color
          // Opacity 0.5 when not hovered
          // Opacity 1 when hovered
          foregroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                hovered = true;
                return Provider.of<ComindColorsNotifier>(context)
                    .colorScheme
                    .onBackground
                    .withAlpha(255);
              } else {
                hovered = false;
                return Provider.of<ComindColorsNotifier>(context)
                    .colorScheme
                    .onBackground
                    .withAlpha(128);
              }
            },
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: getTextTheme(context).titleSmall));
  }

  SingleChildScrollView thoughtBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Main body
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                // const EdgeInsets.fromLTRB(0, 16, 0, 16),
                child: Container(
                  // Add border
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Provider.of<ComindColorsNotifier>(context)
                        .primary
                        .withAlpha(8),
                    // borderRadius:
                    //     BorderRadius.circular(ComindColors.bubbleRadius),
                    border: Border.all(
                      color: Provider.of<ComindColorsNotifier>(context)
                          .colorScheme
                          .onBackground
                          .withAlpha(64),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 4, 30, 4),
                    child: Column(
                      children: [
                        // Markdown body
                        TheMarkdownBox(thought: widget.thought),

                        // Info mode display
                        InfoCard(widget: widget, thought: widget.thought),

                        // // Divider
                        // Visibility(
                        //   visible: newThoughtOpen || moreClicked,
                        //   child: Divider(
                        //     color: Provider.of<ComindColorsNotifier>(context)
                        //         .colorScheme
                        //         .onPrimary
                        //         .withAlpha(32),
                        //   ),
                        // ),

                        // Display the related results
                        if (widget.relatedMode && relatedResults.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text("Some other notes for ya",
                              //     style: Provider.of<ComindColorsNotifier>(context).textTheme.titleSmall),
                              ThoughtTable(
                                thoughts: relatedResults,
                                parentThought: widget.thought,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Add thought button
              Visibility(
                // visible: !widget.viewOnly &&
                //     !widget.relatedMode &&
                //     !newThoughtOpen &&
                //     widget.type != MarkdownDisplayType.searchResult,
                child: Positioned(
                  bottom: 4,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                    child: IconButton(
                      color: Colors.blue,
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      enableFeedback: true,
                      splashRadius: 16,
                      // hoverColor: Provider.of<ComindColorsNotifier>(context)
                      //     .colorScheme
                      //     .primary,
                      onPressed: () {
                        // Toggle the new thought box
                        setState(() {
                          newThoughtOpen = !newThoughtOpen;
                        });
                      },
                      icon: Icon(Icons.add,
                          size: 32,
                          color: Provider.of<ComindColorsNotifier>(context)
                              .colorScheme
                              .onPrimary),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ////////////////////////////
  /// the action buttons /////
  Padding editActionButton(EdgeInsets edgeInsets, BuildContext context,
      EdgeInsets edgeInsets2, double buttonOpacity, double buttonFontSize) {
    return Padding(
      padding: edgeInsets,
      child: Container(
        decoration: BoxDecoration(
          color:
              Provider.of<ComindColorsNotifier>(context).colorScheme.background,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: edgeInsets2,
          child: ComindTextButton(
            fontSize: buttonFontSize,
            opacity: buttonOpacity,
            lineLocation: LineLocation.top,
            colorIndex: 0,
            text: widget.showTextBox ? "Close" : "Edit",
            // lineOnly: hovered,
            onPressed: () {
              // Update the edit box with the thought
              _editController.text = widget.thought.body;

              // Open a text field
              setState(() {
                widget.showTextBox = !widget.showTextBox;
              });
            },
            // lineLocation: LineLocation.top,
          ),
        ),
      ),
    );
  }
}

class TheMarkdownBox extends StatelessWidget {
  const TheMarkdownBox({
    super.key,
    required this.thought,
  });

  final Thought thought;

  @override
  Widget build(BuildContext context) {
    // Custom inline syntax to match {text}

    // Generate html
    // var html = md.markdownToHtml(
    //   thought.body + " :+1: {bang}",
    //   extensionSet: md.ExtensionSet(
    //     md.ExtensionSet.gitHubFlavored.blockSyntaxes,
    //     <md.InlineSyntax>[
    //       md.EmojiSyntax(),
    //       ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
    //       customSyntax,
    //     ],
    //   ),
    // );

    // return Html(
    //   data: html,
    // );

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MarkdownBody(
          // Use the thought content
          data: thought.body,
          selectable: true,

          // Allow hyperlinks
          onTapLink: (text, url, title) {
            launchUrl(Uri.parse(url!)); /*For url_launcher 6.1.0 and higher*/
            // launch(url);  /*For url_launcher 6.0.20 and lower*/
          },

          // Set the markdown styling
          styleSheet: MarkdownStyleSheet(
            // Set link underline
            a: TextStyle(
              color: Provider.of<ComindColorsNotifier>(context)
                  .colorScheme
                  .onPrimary,
              decoration: TextDecoration.underline,
              decorationColor: Provider.of<ComindColorsNotifier>(context)
                  .colorScheme
                  .secondary,
              decorationThickness: 4,
            ),

            // Smush the text together
            blockquoteDecoration: BoxDecoration(
              color: Provider.of<ComindColorsNotifier>(context)
                  .colorScheme
                  .surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
            codeblockDecoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Provider.of<ComindColorsNotifier>(context)
                  .colorScheme
                  .surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
            code: GoogleFonts.ibmPlexMono(
              backgroundColor: Provider.of<ComindColorsNotifier>(context)
                  .colorScheme
                  .surfaceVariant,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            blockquote: TextStyle(
              color: Provider.of<ComindColorsNotifier>(context)
                  .colorScheme
                  .onPrimary,
              fontFamily: "Bungee",
              fontSize: 14,
            ),
          ),

          // Add extensions
          extensionSet: md.ExtensionSet(
            md.ExtensionSet.gitHubFlavored.blockSyntaxes,
            <md.InlineSyntax>[
              // customSyntax,
              md.EmojiSyntax(),
              ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
            ],
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.widget,
    required this.thought,
  });

  final MarkdownThought widget;
  final Thought thought;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.infoMode,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),

            // Here's some information for ya, pal
            // Created at.
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
              child: SelectableText(
                  "Here's some information on this thought, pal. Hit \"Close\" to go back to the thought.",
                  style: Provider.of<ComindColorsNotifier>(context)
                      .textTheme
                      .bodyMedium),
            ),

            // Created at.
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: SelectableText(
                  "Created by ${thought.username} on ${exactTimestamp(thought.dateCreated)}.",
                  style: Provider.of<ComindColorsNotifier>(context)
                      .textTheme
                      .bodyMedium),
            ),

            // Last revised at
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: SelectableText(
                  "Last revised on ${exactTimestamp(thought.dateUpdated)}.",
                  style: Provider.of<ComindColorsNotifier>(context)
                      .textTheme
                      .bodyMedium),
            ),

            // Is synthetic
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: SelectableText(
                  "This thought is generated by a ${thought.isSynthetic ? "inorganic" : "organic"} thinker.",
                  style: Provider.of<ComindColorsNotifier>(context)
                      .textTheme
                      .bodyMedium),
            ),

            // Show ID
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: SelectableText("ID: ${thought.id}",
                  style: Provider.of<ComindColorsNotifier>(context)
                      .textTheme
                      .bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

MarkdownThought coThought(BuildContext context, String text, String title) {
  return MarkdownThought(
    thought: Thought.fromString(text, "Co", true, title: title),
    opacity: 1,
    opacityOnHover: 1,
    selectable: false,
    viewOnly: true,
  );
}
