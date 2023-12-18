import 'package:comind/api.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:google_fonts/google_fonts.dart';
import 'package:comind/types/thought.dart';
import 'package:comind/colors.dart';
import 'package:comind/misc/util.dart';

//
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

  // store whether hovered
  bool hovered = false;

  @override
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

  final Thought thought;
  final BuildContext context;
  final double opacity;
  final double opacityOnHover;

  // store whether hovered
  bool hovered = false;

  // Concrete state class

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          hovered = true;
        });
      },
      onEnter: (event) {
        hovered = true;
      },
      onExit: (event) {
        setState(() {
          hovered = false;
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Stack(fit: StackFit.passthrough, children: [
          // Main text box
          InkWell(
            // focusColor: Colors.blue,
            splashColor: Colors.transparent,
            highlightColor: Colors.red,
            hoverColor: Colors.transparent,
            onTap: () {},
            child: Card(
              color: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: hovered ? opacityOnHover : opacity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 24, 0, 24),
                  child: SizedBox(
                    width: 600,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Add thought body
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                          child: Container(
                            // Add border
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onBackground
                                    .withAlpha(132),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                // Markdown body
                                Visibility(
                                  visible: !widget.infoMode,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 16, 8, 16),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: MarkdownBody(
                                        // Use the thought content
                                        data: thought.body,
                                        selectable: true,

                                        // Set the markdown styling
                                        styleSheet: MarkdownStyleSheet(
                                          // Smush the text together
                                          blockquoteDecoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceVariant,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          codeblockDecoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceVariant,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          code: GoogleFonts.ibmPlexMono(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .surfaceVariant,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                          ),
                                          blockquote: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            fontFamily: "Bungee",
                                            fontSize: 14,
                                          ),
                                        ),
                                        extensionSet: md.ExtensionSet(
                                          md.ExtensionSet.gitHubFlavored
                                              .blockSyntaxes,
                                          <md.InlineSyntax>[
                                            md.EmojiSyntax(),
                                            ...md.ExtensionSet.gitHubFlavored
                                                .inlineSyntaxes
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Info mode display
                                Visibility(
                                  visible: widget.infoMode,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Here's some information for ya, pal
                                        // Created at.
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 16, 8, 4),
                                          child: Text(
                                              "Here's some information on this thought, pal. Hit \"Close\" to go back to the thought.",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium),
                                        ),

                                        // Created at.
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 4, 8, 4),
                                          child: Text(
                                              "Created by ${thought.username} on ${exactTimestamp(thought.dateCreated)}.",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium),
                                        ),

                                        // Last revised at
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 4, 8, 4),
                                          child: Text(
                                              "Last revised on ${exactTimestamp(thought.dateUpdated)}.",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium),
                                        ),

                                        // Is synthetic
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 4, 8, 4),
                                          child: Text(
                                              "This thought is generated by a ${thought.isSynthetic ? "inorganic" : "organic"} thinker.",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium),
                                        ),

                                        // Show ID
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 4, 8, 16),
                                          child: Text("ID: ${thought.id}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Middle bar (left right arrows)
          // Positioned(
          //   top: 30,
          //   child: Container(
          //     width: 600,
          //     child: Flex(
          //       direction: Axis.horizontal,
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Text(
          //           "←",
          //           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          //                 fontFamily: "Bungee",
          //                 fontSize: 24,
          //               ),
          //         ),

          //         // Right arrow
          //         Text(
          //           "→",
          //           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          //                 fontFamily: "Bungee",
          //                 fontSize: 24,
          //               ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          // Add the action bar on top
          // Add info row
          Positioned(
            top: 4,
            child: Container(
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Username
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: Row(
                              children: [
                                // Padding(
                                //   padding:
                                //       const EdgeInsets.fromLTRB(2, 0, 0, 0),
                                //   child: Text(":  ",
                                //       style: TextStyle(
                                //           fontFamily: "Bungee", fontSize: 18)),
                                // ),
                                ComindTextButton(
                                  text: "{${thought.username}}",
                                  colorIndex: 1,
                                  opacity: 0.9,
                                  onPressed: () {
                                    // Navigate to the user's profile
                                    Navigator.pushNamed(context,
                                        '/thinkers/${thought.username}');
                                  },
                                  fontSize: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Right icon box
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                    child: Row(
                      children: [
                        // Link action butt
                        // TODO enter link mode, show relevant thoughts
                        //      that could be linked to this one
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                              child: ComindTextButton(
                                colorIndex: 2,
                                text: "Related",
                                lineOnly: hovered,
                                onPressed: () {
                                  // Toggle info mode
                                  setState(() {
                                    widget.relatedMode = !widget.relatedMode;
                                  });
                                },
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),

                        // Info action button
                        // TODO show info about this thought
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                              child: ComindTextButton(
                                text: widget.infoMode ? "Close" : "Info",
                                lineOnly: hovered,
                                colorIndex: 3,
                                onPressed: () {
                                  // Toggle info mode
                                  setState(() {
                                    widget.infoMode = !widget.infoMode;
                                  });
                                },
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Add the action row on bottom
          Positioned(
            bottom: 9,
            child: SizedBox(
              width: 600,
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Right icon box
                  Row(
                    children: [
                      // Link action butt
                      // TODO enter link mode, show relevant thoughts
                      //      that could be linked to this one
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: ComindTextButton(
                              colorIndex: 2,
                              text: "Link",
                              lineOnly: hovered,
                              onPressed: () {},
                              fontSize: 12,
                              lineLocation: LineLocation.top,
                            ),
                          ),
                        ),
                      ),

                      // Info action button
                      // TODO delete thought should remove the thought
                      //      from the train and mask it from the user.
                      //      If the user is the owner of the thought,
                      //      it should be deleted from the database.
                      //
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: ComindTextButton(
                              lineOnly: hovered,
                              text: "Delete",
                              colorIndex: 3,
                              onPressed: () async {
                                // TODO delete the thought
                                bool? shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Theme.of(context)
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
                                          colorIndex: 1,
                                          textStyle: const TextStyle(
                                              fontFamily: "Bungee",
                                              fontSize: 14),
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                        ),
                                        ComindTextButton(
                                          text: "Delete",
                                          colorIndex: 2,
                                          textStyle: const TextStyle(
                                              fontFamily: "Bungee",
                                              fontSize: 14),
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
                              lineLocation: LineLocation.top,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Date
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 24, 22),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Opacity(
                        opacity: 0.5,
                        child: Text(
                          formatTimestamp(thought.dateUpdated),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                  ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}