import 'package:comind/api.dart';
import 'package:comind/input_field.dart';
import 'package:comind/misc/util.dart';
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

enum MarkdownDisplayType {
  fullScreen,
  inline,
}

//
// ignore: must_be_immutable
class MarkdownThought extends StatefulWidget {
  MarkdownThought(
      {super.key,
      required this.thought,
      required this.context,
      //Opacity/hover opacity, default to 1/1
      this.type = MarkdownDisplayType.inline,
      this.opacity = 1.0,
      this.opacityOnHover = 1.0,
      this.infoMode = false,
      this.relatedMode = false,
      this.parentThought,
      this.viewOnly = false,
      this.selectable = true});

  final Thought thought;
  final BuildContext context;
  final double opacity;
  final double opacityOnHover;
  bool selectable;
  bool infoMode;
  bool relatedMode;
  bool viewOnly;
  MarkdownDisplayType type;
  String? parentThought;
  bool showTextBox = false;

  // store whether hovered
  bool hovered = false;

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _MarkdownThoughtState(
        thought: thought,
        context: context,
        opacity: opacity,
        opacityOnHover: opacityOnHover,
      );
}

class _MarkdownThoughtState extends State<MarkdownThought> {
  _MarkdownThoughtState({
    required this.thought,
    required this.context,
    //Opacity/hover opacity, default to 1/1
    this.opacity = 1.0,
    this.opacityOnHover = 1.0,
  });

  @override
  final BuildContext context;
  final Thought thought;
  final double opacity;
  final double opacityOnHover;
  final _editController = TextEditingController();
  List<Thought> relatedResults = [];
  final ComindColors colors = ComindColors();
  final int outlineAlpha = 120;
  final int outlineAlphaHover = 200;

  // store whether hovered
  bool hovered = false;

  // whether the "more" button has been clicked
  bool moreClicked = false;

  // Initialization
  @override
  Widget build(BuildContext context) {
    var onBackground =
        Provider.of<ComindColorsNotifier>(context).colorScheme.onBackground;

    return Padding(
      padding: widget.type == MarkdownDisplayType.fullScreen
          ? const EdgeInsets.fromLTRB(0, 0, 0, 0)
          : const EdgeInsets.fromLTRB(16, 16, 16, 24),
      // : const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(children: [
        // Main text box
        Visibility(
          // visible: true,
          visible: !widget.showTextBox,
          child: Card(
            // color: Colors.red,
            color: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Cinewave username
                    cineUsername(context),

                    // Add thought body
                    thoughtBody(context),

                    // Alternative action row
                    alternativeActionRow(context, onBackground)
                  ],
                ),
              ),
            ),
          ),
        ),

        // Show a vertical divider
        // Visibility(
        //   visible: widget.showTextBox,
        //   child: Column(
        //     children: [
        //       Padding(
        //           padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        //           child: Container(
        //             width: 2,
        //             height: 32,
        //             color: Provider.of<ComindColorsNotifier>(context)
        //                 .colorScheme
        //                 .onBackground
        //                 .withAlpha(
        //                     hovered ? outlineAlphaHover : outlineAlpha),
        //           )),
        //     ],
        //   ),
        // ),

        // Show the edit box
        Visibility(
          visible: !widget.viewOnly && widget.showTextBox,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: MainTextField(
                  thought: thought,
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
        ),

        // Add the action row on bottom
        // actionRow(
        //     context, edgeInsets2, edgeInsets, buttonFontSize, buttonOpacity),

        // Display the related results
        if (widget.relatedMode && relatedResults.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text("Some other notes for ya",
              //     style: Provider.of<ComindColorsNotifier>(context).textTheme.titleSmall),
              ThoughtTable(
                thoughts: relatedResults,
                parentThought: thought,
              ),
            ],
          )
      ]),
    );
  }

  Row alternativeActionRow(BuildContext context, Color onBackground) {
    return Row(children: [
      Opacity(
        opacity: 0.5,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
          child: Text(
            formatTimestamp(thought.dateCreated),
            style:
                Provider.of<ComindColorsNotifier>(context).textTheme.bodySmall,
          ),
        ),
      ),

      // Cinewave
      // Expanded(child: SizedBox(height: 10, child: CineWave())),
      Expanded(
          child: SizedBox(
              height: 20,
              child: Divider(
                color: onBackground.withAlpha(64),
              ))),

      TextButton(
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
          onPressed: () {
            // Toggle info mode
            setState(() {
              widget.infoMode = !widget.infoMode;
            });
          },
          child: Text(widget.infoMode ? "Close" : "Info",
              style: getTextTheme(context).titleSmall)),

      // Think button
      TextButton(
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
          onPressed: () {
            // Toggle info mode
            setState(() {
              widget.showTextBox = !widget.showTextBox;
            });
          },
          child: Text(widget.infoMode ? "Close" : "Think",
              style: getTextTheme(context).titleSmall)),
    ]);
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
                    color:
                        Provider.of<ComindColorsNotifier>(context).background,

                    // Left border
                    // border: Border(
                    //   left: BorderSide(
                    //     color:
                    //         Provider.of<ComindColorsNotifier>(
                    //                 context)
                    //             .colorScheme
                    //             .onBackground
                    //             .withAlpha(32),
                    //     width: 2,
                    //   ),
                    // ),
                  ),
                  child: Material(
                    borderRadius: BorderRadius.circular(0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      hoverColor: widget.selectable
                          ? Provider.of<ComindColorsNotifier>(context)
                              .colorScheme
                              .onBackground
                              .withAlpha(16)
                          : Colors.transparent,
                      onTap: () => {
                        // Expand the thought view, onyl if selectable
                        if (widget.selectable)
                          {
                            Navigator.pushNamed(
                                context, '/thoughts/${thought.id}')
                          }
                        else if (widget.viewOnly)
                          {
                            // Otherwise, open edit mode
                            // Snack bar edit
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'You can\'t edit this thought. View only: ${widget.viewOnly}'),
                              duration: const Duration(seconds: 1),
                            )),
                          }
                        else
                          {
                            setState(() {
                              widget.showTextBox = true;
                              _editController.text = thought.body;
                            })
                          }
                      },
                      borderRadius: BorderRadius.circular(0),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                        child: Column(
                          children: [
                            // Markdown body
                            TheMarkdownBox(thought: thought),

                            // Info mode display
                            InfoCard(widget: widget, thought: thought),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Add the action row on bottom
              // Visibility(
              //   visible: !widget.viewOnly,
              //   child: Positioned(
              //     bottom: -15,
              //     right: 0,
              //     child: actionRow(
              //         context,
              //         edgeInsets2,
              //         edgeInsets,
              //         buttonFontSize,
              //         buttonOpacity),
              //   ),
              // ),

              // Add the date chunk on bottom
              // Positioned(
              //   bottom: -6,
              //   left: 12,
              //   child: dateChunk(context, buttonFontSize),
              // ),
            ],
          ),

          // Add the action row on bottom
          // Visibility(
          //   visible: !widget.viewOnly,
          //   child: Container(
          //     decoration: BoxDecoration(
          //       border: Border(
          //         top: BorderSide(
          //           color: Provider.of<ComindColorsNotifier>(
          //                   context)
          //               .colorScheme
          //               .onBackground
          //               .withAlpha(32),
          //           width: 2,
          //         ),
          //       ),
          //       // color:
          //       //     Provider.of<ComindColorsNotifier>(context)
          //       //         .colorScheme
          //       //         .onBackground,
          //     ),
          //     child: Padding(
          //       padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
          //       child: actionRow(context, edgeInsets2,
          //           edgeInsets, buttonFontSize, buttonOpacity),
          //     ),
          //   ),
          // ),

          // Colorful bottom divider
          // SizedBox(height: 1, width: ComindColors.maxWidth, child: ComindDiv()),
        ],
      ),
    );
  }

  Row cineUsername(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
          child: Text(thought.username,
              style: Provider.of<ComindColorsNotifier>(context)
                  .textTheme
                  .titleSmall),
        ),
        const Expanded(
            child: SizedBox(
                height: 5, child: Opacity(opacity: 1, child: CineWave()))),
      ],
    );
  }

  Container borderUsername(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // color:
        //     Provider.of<ComindColorsNotifier>(context).colorScheme.background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 0, 2, 2),
        child: Row(
          children: [
            ComindTextButton(
              text: thought.username,
              colorIndex: 0,
              opacity: 0.5,
              opacityOnHover: 1,
              onPressed: () {
                // Navigate to the user's profile
                Navigator.pushNamed(context, '/thinkers/${thought.username}');
              },
              fontSize: Provider.of<ComindColorsNotifier>(context)
                  .textTheme
                  .bodySmall!
                  .fontSize!,
            ),
            // Opacity(
            //   opacity: hovered
            //       ? 1
            //       : widget.showTextBox
            //           ? 1
            //           : 0.4,
            //   child: Padding(
            //       padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
            //       // child: thought.isPublic
            //       //     ? Icon(Icons.lock_open,
            //       //         size: lockSize, color: Colors.grey)
            //       //     : Icon(Icons.lock, size: lockSize, color: Colors.grey),
            //       child: thought.isPublic ? Text("×") : Text("∘")),
            // ),
          ],
        ),
      ),
    );
  }

  Widget actionRow(BuildContext context, EdgeInsets edgeInsets2,
      EdgeInsets edgeInsets, double buttonFontSize, double buttonOpacity) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // TODO #1 add code to make this left-hand right-hand toggleable
            // added some stuff but it's not working. May be an issue with state refresh
            // Right icon box
            actionStuff(edgeInsets, context, edgeInsets2, buttonOpacity),
          ],
        ),
      ],
    );
  }

  Row actionStuff(EdgeInsets edgeInsets, BuildContext context,
      EdgeInsets edgeInsets2, double buttonOpacity) {
    double buttonFontSize = Provider.of<ComindColorsNotifier>(context)
        .textTheme
        .labelSmall!
        .fontSize!;

    return Row(
      children: [
        // Right icon box
        Padding(
          padding: edgeInsets,
          child: Row(
            children: [
              // Info action button
              // TODO #2 delete thought should remove the thought
              //      from the train and mask it from the user.
              //      If the user is the owner of the thought,
              //      it should be deleted from the database.
              //
              // if (moreClicked)
              Visibility(
                visible: moreClicked,
                child: deleteActionButton(edgeInsets, context, edgeInsets2,
                    buttonOpacity, buttonFontSize),
              ),

              // Info action button
              // if (moreClicked)
              Visibility(
                visible: moreClicked,
                child: infoActionButton(edgeInsets, context, edgeInsets2,
                    buttonOpacity, buttonFontSize),
              ),

              // More action button
              moreActionButton(edgeInsets, context, edgeInsets2, buttonFontSize,
                  buttonOpacity),

              // Edit action button
              // TODO enter edit mode, allow the user to edit
              //      the thought
              editActionButton(edgeInsets, context, edgeInsets2, buttonOpacity,
                  buttonFontSize),

              // Link action button
              // TODO enter link mode, show relevant thoughts
              //      that could be linked to this one
              relatedActionButton(edgeInsets, context, edgeInsets2,
                  buttonFontSize, buttonOpacity),

              // Link action button
              // TODO enter link mode, show relevant thoughts
              //      that could be linked to this one
              Visibility(
                visible: widget.parentThought != null,
                child: linkActionButton(edgeInsets, context, edgeInsets2,
                    buttonOpacity, buttonFontSize),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Padding moreActionButton(EdgeInsets edgeInsets, BuildContext context,
      EdgeInsets edgeInsets2, double buttonFontSize, double buttonOpacity) {
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
            lineLocation: LineLocation.top,
            fontSize: buttonFontSize,
            opacity: buttonOpacity,
            colorIndex: 0,
            text: moreClicked ? "Less" : "More",
            // lineOnly: hovered,
            onPressed: () async {
              // Toggle info mode
              setState(() {
                moreClicked = !moreClicked;
              });
            },
          ),
        ),
      ),
    );
  }

  Padding relatedActionButton(EdgeInsets edgeInsets, BuildContext context,
      EdgeInsets edgeInsets2, double buttonFontSize, double buttonOpacity) {
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
            lineLocation: LineLocation.top,
            fontSize: buttonFontSize,
            opacity: buttonOpacity,
            colorIndex: 0,
            text: widget.relatedMode ? "Close" : "Related",
            // lineOnly: hovered,
            onPressed: () async {
              if (relatedResults.isEmpty) {
                // Semantic search on the body of the text
                var res = await searchThoughts(context, thought.body,
                    associatedId: thought.id);

                // Toggle info mode
                setState(() {
                  widget.relatedMode = !widget.relatedMode;
                  relatedResults =
                      res.where((item) => thought.id != item.id).toList();
                });
              } else {
                setState(() {
                  widget.relatedMode = !widget.relatedMode;
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Padding infoActionButton(EdgeInsets edgeInsets, BuildContext context,
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
            lineLocation: LineLocation.top,
            fontSize: buttonFontSize,
            opacity: buttonOpacity,
            text: widget.infoMode ? "Close" : "Info",
            // lineOnly: hovered,
            colorIndex: hovered ? 1 : 0,
            onPressed: () {
              // Toggle info mode
              setState(() {
                widget.infoMode = !widget.infoMode;
              });
            },
          ),
        ),
      ),
    );
  }

  Padding linkActionButton(EdgeInsets edgeInsets, BuildContext context,
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
            colorIndex: 1,
            text: "Link",
            // lineOnly: hovered,
            onPressed: () {
              // Link the thought to the parent
              linkThoughts(context, widget.parentThought!, thought.id);
            },
            // lineLocation: LineLocation.top,
          ),
        ),
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
              _editController.text = thought.body;

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

  Padding deleteActionButton(EdgeInsets edgeInsets, BuildContext context,
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
            opacity: buttonOpacity,
            fontSize: buttonFontSize,
            lineLocation: LineLocation.top,
            // lineOnly: hovered,
            text: "Delete",
            colorIndex: 0,
            onPressed: () async {
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
                deleteThought(context, thought.id);
              }
            },
            // lineLocation: LineLocation.top,
          ),
        ),
      ),
    );
  }

  Row dateChunk(BuildContext context, double buttonSize) {
    return Row(
      children: [
        // Public/private
        Container(
          decoration: BoxDecoration(
            color: Provider.of<ComindColorsNotifier>(context)
                .colorScheme
                .background,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Visibility(
            visible: !widget.viewOnly,
            child: ComindTextButton(
              text: thought.isPublic ? "Public" : "Private",
              colorIndex: thought.isPublic ? 1 : 3,
              lineLocation: LineLocation.top,
              opacity: opacity,
              opacityOnHover: outlineAlphaHover / 255,
              onPressed: () {
                // Navigate to the user's profile
                Navigator.pushNamed(context, '/thinkers/${thought.username}');
              },
              fontSize: buttonSize,
            ),
          ),
        ),
      ],
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
      child: MarkdownBody(
        // Use the thought content
        data: thought.body,
        selectable: false,

        // Set the markdown styling
        styleSheet: MarkdownStyleSheet(
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

MarkdownThought coThought(BuildContext context, String text) {
  return MarkdownThought(
    thought: Thought.fromString(text, "Co", true),
    context: context,
    opacity: 1,
    opacityOnHover: 1,
    selectable: false,
    viewOnly: true,
  );
}
