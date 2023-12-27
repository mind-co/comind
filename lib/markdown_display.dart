import 'package:comind/api.dart';
import 'package:comind/concept_syntax.dart';
import 'package:comind/input_field.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:google_fonts/google_fonts.dart';
import 'package:comind/types/thought.dart';
import 'package:comind/colors.dart';
import 'package:provider/provider.dart';

//
// ignore: must_be_immutable
class MarkdownThought extends StatefulWidget {
  MarkdownThought({
    super.key,
    required this.thought,
    required this.context,
    //Opacity/hover opacity, default to 1/1
    this.opacity = 1.0,
    this.opacityOnHover = 1.0,
    this.infoMode = false,
    this.relatedMode = false,
  });

  final Thought thought;
  final BuildContext context;
  final double opacity;
  final double opacityOnHover;
  bool infoMode;
  bool relatedMode;
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
    const edgeInsets = EdgeInsets.fromLTRB(8, 0, 8, 0); // between buttons
    const edgeInsets2 = EdgeInsets.fromLTRB(1, 0, 1, 0); // inside buttons
    double buttonFontSize = 10;
    double buttonOpacity = hovered
        ? 1
        : widget.showTextBox
            ? 1
            : 0.6;

    return MouseRegion(
      onHover: (event) {
        setState(() {
          hovered = true;
        });
      },
      onEnter: (event) {
        hovered = true;
        // var newColors =
        // ComindColors.generateSplitComplementaryColors(Colors.purple);

        // Set the colors to the new one
        // colors.setColors(newColors[0], newColors[1], newColors[2]);

        // To rotate colors
        // colors.setColors(
        //     colors.secondaryColor, colors.tertiaryColor, colors.primaryColor);
      },
      onExit: (event) {
        setState(() {
          hovered = false;
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 32),
        child: Column(children: [
          // Main text box
          Visibility(
            // visible: true,
            visible: !widget.showTextBox,
            child: Card(
              color: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: SizedBox(
                  width: double.infinity,
                  // Maximum 600 width
                  // preferredSize: const Size(600, double.infinity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Add thought body
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Main body
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 8),
                                  child: Container(
                                    // Add border
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Provider.of<ComindColorsNotifier>(
                                              context)
                                          .background,
                                      // color: colors.primaryColor,
                                      // Top border only
                                      // border: Border(
                                      //     top: BorderSide(
                                      //   color: Provider.of<ComindColorsNotifier>(context)
                                      //       .colorScheme
                                      //       .onBackground
                                      //       .withAlpha(80),
                                      // )),

                                      // All border
                                      border: Border.all(
                                        width: 2,
                                        color:
                                            Provider.of<ComindColorsNotifier>(
                                                    context)
                                                .onBackground
                                                .withAlpha(hovered
                                                    ? outlineAlphaHover
                                                    : outlineAlpha),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Material(
                                      borderRadius: BorderRadius.circular(10),
                                      child: InkWell(
                                        onTap: () => {},
                                        borderRadius: BorderRadius.circular(10),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            children: [
                                              // Markdown body
                                              TheMarkdownBox(
                                                  widget: widget,
                                                  thought: thought),

                                              // Info mode display
                                              InfoCard(
                                                  widget: widget,
                                                  thought: thought),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Username on border
                                borderUsername(context),

                                // Add the action row on bottom
                                Positioned(
                                  bottom: -4,
                                  right: 0,
                                  child: actionRow(
                                      context,
                                      edgeInsets2,
                                      edgeInsets,
                                      buttonFontSize,
                                      buttonOpacity),
                                ),

                                // Add the date chunk on bottom
                                Positioned(
                                  bottom: 0,
                                  left: 12,
                                  child: dateChunk(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
            visible: widget.showTextBox,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: MainTextField(
                    thought: thought,
                    onThoughtEdited: (Thought thought) async {
                      // Update the thought
                      await saveThought(thought);
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
      ),
    );
  }

  Positioned borderUsername(BuildContext context) {
    double lockSize = 14;
    return Positioned(
      top: -8,
      left: 8,
      child: Container(
        decoration: BoxDecoration(
          color:
              Provider.of<ComindColorsNotifier>(context).colorScheme.background,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Row(
            children: [
              ComindTextButton(
                text: thought.username,
                colorIndex: 0,
                lineLocation: LineLocation.top,
                opacity: hovered
                    ? outlineAlphaHover / 255
                    : widget.showTextBox
                        ? 1
                        : outlineAlpha / 255,
                onPressed: () {
                  // Navigate to the user's profile
                  Navigator.pushNamed(context, '/thinkers/${thought.username}');
                },
                fontSize: 12,
              ),
              Opacity(
                opacity: hovered
                    ? 1
                    : widget.showTextBox
                        ? 1
                        : 0.4,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                  child: thought.isPublic
                      ? Icon(Icons.lock_open,
                          size: lockSize, color: Colors.grey)
                      : Icon(Icons.lock, size: lockSize, color: Colors.grey),
                ),
              ),
            ],
          ),
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
            actionStuff(edgeInsets, context, edgeInsets2, buttonFontSize,
                buttonOpacity),
          ],
        ),
      ],
    );
  }

  Row actionStuff(EdgeInsets edgeInsets, BuildContext context,
      EdgeInsets edgeInsets2, double buttonFontSize, double buttonOpacity) {
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

              // Link action button
              // TODO enter link mode, show relevant thoughts
              //      that could be linked to this one
              // linkActionButton(edgeInsets, context, edgeInsets2, buttonOpacity,
              //     buttonFontSize),

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
            colorIndex: 3,
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
            colorIndex: 1,
            text: "Think",
            // lineOnly: hovered,
            onPressed: () async {
              if (relatedResults.isEmpty) {
                // Semantic search on the body of the text
                var res = await searchThoughts(thought.body,
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
            colorIndex: 3,
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
            onPressed: () {},
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
            colorIndex: 2,
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
            colorIndex: 3,
            onPressed: () async {
              // TODO delete the thought
              bool? shouldDelete = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Provider.of<ComindColorsNotifier>(context)
                        .colorScheme
                        .background,
                    surfaceTintColor: Colors.black,
                    title: const Text(
                      'Delete thought',
                      style: TextStyle(
                          fontFamily: "Bungee",
                          fontSize: 18,
                          fontWeight: FontWeight.w400),
                    ),
                    content: const Text(
                        'You sure you wanna delete this note? Cameron is really, really bad at making undo buttons. \n\nIf you delete this it will prolly be gone forever.'),
                    actions: <Widget>[
                      ComindTextButton(
                        text: "Cancel",
                        fontSize: buttonFontSize,
                        colorIndex: 1,
                        textStyle:
                            const TextStyle(fontFamily: "Bungee", fontSize: 14),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      ComindTextButton(
                        text: "Delete",
                        fontSize: buttonFontSize,
                        colorIndex: 2,
                        textStyle:
                            const TextStyle(fontFamily: "Bungee", fontSize: 14),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  );
                },
              );

              if (shouldDelete == true) {
                deleteThought(thought.id);
              }
            },
            // lineLocation: LineLocation.top,
          ),
        ),
      ),
    );
  }

  Container dateChunk(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      decoration: BoxDecoration(
        color:
            Provider.of<ComindColorsNotifier>(context).colorScheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Opacity(
        opacity: hovered
            ? 0.9
            : widget.showTextBox
                ? 0.9
                : 0.6,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: thought.isPublic ? "public" : "private",
                style: Provider.of<ComindColorsNotifier>(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: thought.isPublic
                          ? Provider.of<ComindColorsNotifier>(context)
                              .colorScheme
                              .onBackground
                          : Provider.of<ComindColorsNotifier>(context)
                              .colorScheme
                              .onBackground,
                      decoration: TextDecoration.underline,
                      decorationThickness: 4,
                      decorationColor: thought.isPublic
                          ? Provider.of<ComindColorsNotifier>(context).primary
                          : Provider.of<ComindColorsNotifier>(context)
                              .secondary,
                    ),
              ),
              TextSpan(
                text: ", ${formatTimestamp(thought.dateUpdated)}",
                style: Provider.of<ComindColorsNotifier>(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: thought.isPublic
                          ? Provider.of<ComindColorsNotifier>(context)
                              .colorScheme
                              .onBackground
                          : Provider.of<ComindColorsNotifier>(context)
                              .colorScheme
                              .onBackground,
                    ),
              ),
            ],
          ),
        ),
        // : Text(
        //     (thought.isPublic ? "public, " : "private, ") +
        //         formatTimestamp(thought.dateUpdated),
        //     style: Provider.of<ComindColorsNotifier>(context)
        //         .textTheme
        //         .bodyMedium
        //         ?.copyWith(
        //           decoration: TextDecoration.underline,
        //           decorationThickness: 8,
        //           decorationColor:
        //               Provider.of<ComindColorsNotifier>(context).primary,
        //           fontSize: 12,
        //         ),
        //   ),
      ),
    );
  }
}

class TheMarkdownBox extends StatelessWidget {
  const TheMarkdownBox({
    super.key,
    required this.widget,
    required this.thought,
  });

  final MarkdownThought widget;
  final Thought thought;

  @override
  Widget build(BuildContext context) {
    // Custom inline syntax to match {text}
    var customSyntax = ConceptSyntax();

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
        selectable: true,

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
            Divider(),

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
