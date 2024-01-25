import 'dart:math';

import 'package:comind/api.dart';
import 'package:comind/hover_icon_button.dart';
// import 'package:comind/concept_syntax.dart';
import 'package:comind/input_field.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/providers.dart';
import 'package:comind/text_button.dart';
import 'package:comind/thought_table.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
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
  topOfMind,
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
      this.noTitle = false,
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
  final bool noTitle;

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

    return Column(children: [
      // Main text box
      Card(
        color: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Cinewave username
                Row(
                  children: [
                    // Link button for child thoughts
                    Visibility(
                      visible: widget.type == MarkdownDisplayType.searchResult,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                        child: HoverIconButton(
                          icon: Icons.add_link,
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
                        ),
                      ),
                    ),
                  ],
                ),

                // // Show cosine similarity
                // Text(widget.thought.cosineSimilarity.toString(),
                //     style: Provider.of<ComindColorsNotifier>(context)
                //         .textTheme
                //         .bodySmall),

                titleBar(context),

                // Add thought body
                Visibility(
                    visible: widget.showBody && !widget.showTextBox,
                    child: thoughtBody(context)),

                expandableEditBox(context),

                // Alternative action row
                Visibility(
                    visible: widget.type != MarkdownDisplayType.topOfMind &&
                        widget.showBody,
                    child: alternativeActionRow(context, onBackground)),

                // Show new thought box
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                //   child: Row(
                //     children: [
                //       Visibility(
                //         visible: newThoughtOpen,
                //         child: IconButton(
                //           padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                //           enableFeedback: true,
                //           splashRadius: 16,
                //           onPressed: () {
                //             // Toggle the body
                //             setState(() {
                //               newThoughtOpen = !newThoughtOpen;
                //             });
                //           },
                //           icon: Icon(
                //             Icons.subdirectory_arrow_right,
                //             size: 16,
                //             color: Provider.of<ComindColorsNotifier>(context)
                //                 .colorScheme
                //                 .onBackground
                //                 .withAlpha(200),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                // New thought box
                newThoughtBox(context),
              ],
            ),
          ),
        ),
      ),

      // Add the action row on bottom
      // actionRow(
      //     context, edgeInsets2, edgeInsets, buttonFontSize, buttonOpacity),
    ]);
  }

  Padding titleBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with grey line from end of title to far right
          Row(
            children: [
              // Title
              Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: RichText(
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.thought.title,
                          style: Provider.of<ComindColorsNotifier>(context,
                                  listen: false)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  color: Provider.of<ComindColorsNotifier>(
                                          context,
                                          listen: false)
                                      .colorScheme
                                      .onBackground),
                        ),
                      ],
                    ),
                  )

                  // child: Text(thought.title, style: getTextTheme(context).labelMedium),
                  // child: Text(thought.title, style: getTextTheme(context).titleSmall),
                  ),

              // Grey line
              Expanded(
                child: Container(
                  height: 1,
                  color: Provider.of<ComindColorsNotifier>(context)
                      .colorScheme
                      .onBackground
                      .withAlpha(64),
                ),
              ),

              // Expand/contract button
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                child: newIconButton(
                  context,
                  () {
                    // Toggle the body
                    setState(() {
                      widget.showBody = !widget.showBody;
                    });
                  },
                  Icon(
                    // Expand or contract icon
                    widget.showBody ? Icons.close : Icons.circle_outlined,
                    size: 24,
                    color: Provider.of<ComindColorsNotifier>(context)
                        .colorScheme
                        .onPrimary
                        .withAlpha(32),
                  ),
                ),
              )
            ],
          ),

          // Username
          Opacity(
            opacity: 0.7,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 12, 0),
              child: SelectableText.rich(
                TextSpan(
                  children: [
                    // Timestamp
                    TextSpan(
                      text: formatTimestamp(widget.thought.dateCreated),
                      style: Provider.of<ComindColorsNotifier>(context)
                          .textTheme
                          .bodySmall,
                    ),

                    // Timestamp
                    TextSpan(
                      text: " · ",
                      style: Provider.of<ComindColorsNotifier>(context)
                          .textTheme
                          .bodySmall,
                    ),

                    TextSpan(
                      text: widget.thought.username,
                      style: Provider.of<ComindColorsNotifier>(context)
                          .textTheme
                          .bodySmall,
                    ),

                    TextSpan(
                      text:
                          widget.thought.isPublic ? " · public" : " · private",
                      style: Provider.of<ComindColorsNotifier>(context)
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ), // Username
        ],
      ),
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
          type: TextFieldType.edit),
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

    // // The "add thought" button
    // var addThoughtButton = Padding(
    //   padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
    //   child: newButton(
    //       onBackground, context, newThoughtOpen ? "Close" : "Think", () {
    //     // Toggle the new thought box
    //     setState(() {
    //       newThoughtOpen = !newThoughtOpen;
    //     });
    //   }),
    // );

    var thinkButton = ComindTextButton(
      text: newThoughtOpen ? "Close" : "Think",
      opacity: 0.4,
      fontSize: 12,
      colorIndex: 1,
      onPressed: () {
        // Link to parent
        if (widget.parentThought != null) {
          // Link the thoughts
          if (widget.thought.id != widget.parentThought &&
              widget.parentThought != null) {
            linkThoughts(context, widget.thought.id, widget.parentThought!);
          }
        }

        // Next, add it to the topOfMind array
        Provider.of<ThoughtsProvider>(context, listen: false)
            .addTopOfMind(widget.thought);
      },
    );

    var linkButton = Visibility(
      visible:
          widget.linkable && widget.parentThought != null && !widget.viewOnly,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
        child: ComindTextButton(
          text: "Link",
          opacity: 0.4,
          fontSize: 12,
          colorIndex: 2,
          onPressed: () {
            // Link to parent if there is one
            if (widget.parentThought != null) {
              // Link the thoughts
              if (widget.thought.id != widget.parentThought &&
                  widget.parentThought != null) {
                linkThoughts(context, widget.thought.id, widget.parentThought!);
              }
            }
          },
        ),
      ),
    );

    var moreButton = Visibility(
      visible: !widget.viewOnly,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
        child: ComindTextButton(
          text: "More",
          opacity: 0.4,
          fontSize: 12,
          colorIndex: 3,
          onPressed: () {
            // Toggle info mode
            setState(() {
              moreClicked = !moreClicked;
            });
          },
        ),
      ),
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

    // // Local variable for edit button
    // var editThoughtButton = Padding(
    //   padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
    //   child: newButton(
    //       onBackground, context, widget.showTextBox ? "Close" : "Edit", () {
    //     // Update the edit box with the thought
    //     _editController.text = widget.thought.body;

    //     // Toggle the new thought box
    //     setState(() {
    //       widget.showTextBox = !widget.showTextBox;
    //     });
    //   }),
    // );

    // // The link button
    // var linkButton = newIconButton(
    //   context,
    //   () async {
    //     // If there is a parent thought
    //     if (widget.parentThought != null) {
    //       // Link the thoughts
    //       if (widget.thought.id != widget.parentThought &&
    //           widget.parentThought != null) {
    //         await linkThoughts(
    //             context, widget.thought.id, widget.parentThought!);
    //       }
    //     }
    //   },
    //   Icon(
    //     Icons.add_link,
    //     size: 16,
    //     color: Provider.of<ComindColorsNotifier>(context)
    //         .colorScheme
    //         .onPrimary
    //         .withAlpha(128),
    //   ),
    // );

    // Edit button
    var editThoughtButton = newIconButton(
      context,
      () {
        // Update the edit box with the thought
        _editController.text = widget.thought.body;

        // Toggle the new thought box
        setState(() {
          widget.showTextBox = !widget.showTextBox;
        });
      },
      Icon(
        Icons.edit,
        size: 16,
        color: Provider.of<ComindColorsNotifier>(context)
            .colorScheme
            .onPrimary
            .withAlpha(128),
      ),
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
        widget.infoMode ? Icons.close : Icons.info_outline,
        size: 16,
        color: Provider.of<ComindColorsNotifier>(context)
            .colorScheme
            .onPrimary
            .withAlpha(128),
      ),
    );

    // // the more button
    // var moreButton = newIconButton(
    //   context,
    //   () {
    //     // Toggle info mode
    //     setState(() {
    //       moreClicked = !moreClicked;
    //     });
    //   },
    //   Icon(
    //     Icons.more_horiz,
    //     size: 16,
    //     color: Provider.of<ComindColorsNotifier>(context)
    //         .colorScheme
    //         .onPrimary
    //         .withAlpha(128),
    //   ),
    // );

    // the action row
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      // Gray line
      Expanded(
        child: Container(
          height: 1,
          color: Provider.of<ComindColorsNotifier>(context)
              .colorScheme
              .onPrimary
              .withAlpha(64),
        ),
      ),

      // Lock icon
      Visibility(
          visible: !widget.viewOnly && !widget.relatedMode && !newThoughtOpen,
          child: lockButton),

      // Buttons
      Visibility(
          visible: !widget.showTextBox &&
              !widget.relatedMode &&
              !newThoughtOpen &&
              !widget.viewOnly,
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

      // More options button
      Visibility(visible: !newThoughtOpen, child: moreButton),

      // Link button
      linkButton,

      // Add thought button
      Visibility(visible: !widget.viewOnly, child: thinkButton),
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
              Container(
                // Add border
                width: double.infinity,
                decoration: BoxDecoration(
                  // Border for only top and bottom
                  border: Border(
                    // top: BorderSide(
                    //   color: Provider.of<ComindColorsNotifier>(context)
                    //       .colorScheme
                    //       .onBackground
                    //       .withAlpha(64),
                    //   width: 1,
                    // ),
                    bottom: widget.type == MarkdownDisplayType.newThought
                        ? BorderSide(
                            color: Provider.of<ComindColorsNotifier>(context)
                                .colorScheme
                                .onBackground
                                .withAlpha(64),
                            width: 1,
                          )
                        : BorderSide.none,
                  ),
                ),
                child: Column(
                  children: [
                    // Cinewave username
                    Row(
                      children: [
                        // Link button for child thoughts
                        Visibility(
                          visible: widget.thought.linkedTo,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                            child: HoverIconButton(
                              icon: Icons.add_link,
                              onPressed: () async {
                                // If there is a parent thought
                                if (widget.parentThought != null) {
                                  // Link the thoughts
                                  if (widget.thought.id !=
                                          widget.parentThought &&
                                      widget.parentThought != null) {
                                    await linkThoughts(
                                        context,
                                        widget.thought.id,
                                        widget.parentThought!);
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Markdown body
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: TheMarkdownBox(text: widget.thought.body),
                    ),

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
  const TheMarkdownBox({super.key, required this.text});

  final String text;

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
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: MarkdownBody(
          // Use the thought content
          data: text,
          selectable: true,

          // Allow hyperlinks
          onTapLink: (text, url, title) {
            launchUrl(Uri.parse(url!)); /*For url_launcher 6.1.0 and higher*/
            // launch(url);  /*For url_launcher 6.0.20 and lower*/
          },

          // Set the markdown styling
          styleSheet: MarkdownStyleSheet(
            h1: Provider.of<ComindColorsNotifier>(context)
                .textTheme
                .titleMedium,
            h2: Provider.of<ComindColorsNotifier>(context).textTheme.titleSmall,
            h3: Provider.of<ComindColorsNotifier>(context)
                .textTheme
                .labelMedium,

            // Spacing between paragraphs
            pPadding: const EdgeInsets.fromLTRB(0, 0, 0, 8),

            // Set link underline
            a: TextStyle(
              color: Provider.of<ComindColorsNotifier>(context)
                  .colorScheme
                  .onPrimary,
              decoration: TextDecoration.underline,
              decorationColor: Provider.of<ComindColorsNotifier>(context)
                  .colorScheme
                  .primary,
              decorationThickness: 2,
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
                  "Here's some information on this thought, pal.",
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

            // Show from thought
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: SelectableText("From: ${thought.linkedFrom}",
                  style: Provider.of<ComindColorsNotifier>(context)
                      .textTheme
                      .bodyMedium),
            ),

            // Show to thought
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: SelectableText("To: ${thought.linkedTo}",
                  style: Provider.of<ComindColorsNotifier>(context)
                      .textTheme
                      .bodyMedium),
            ),

            // Show cosine similarity
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: SelectableText(
                  "Cosine similarity: ${thought.cosineSimilarity?.toStringAsFixed(2)}",
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
