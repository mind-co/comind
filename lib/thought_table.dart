// ThoughtTable shows a list of searched thoughts
import 'dart:math';

import 'package:comind/colors.dart';
import 'package:comind/markdown_display_line.dart';
import 'package:comind/types/thought.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ThoughtTable extends StatelessWidget {
  const ThoughtTable({
    Key? key,
    required this.thoughts,
    this.parentThought,
  }) : super(key: key);

  final List<Thought> thoughts;
  final Thought? parentThought;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 32, 0, 30),
      child: Stack(clipBehavior: Clip.none, children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: ComindColors.maxWidth,
            maxHeight: 800,
          ),
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),

          //   // Left border only
          //   border: Border.all(
          //     style: BorderStyle.solid,
          //     color: Provider.of<ComindColorsNotifier>(context)
          //         .colorScheme
          //         .onBackground
          //         .withAlpha(128),
          //     width: 2.0,

          //     // color: Provider.of<ComindColorsNotifier>(context)
          //     //     .colorScheme
          //     //     .onBackground
          //     //     .withAlpha(64),
          //   ),
          // ),

          // If there are no thoughts, show a message
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),

              // Left border only
              border: Border.all(
                style: BorderStyle.solid,
                color: Provider.of<ComindColorsNotifier>(context)
                    .colorScheme
                    .onBackground
                    .withAlpha(128),
                width: 2.0,

                // color: Provider.of<ComindColorsNotifier>(context)
                //     .colorScheme
                //     .onBackground
                //     .withAlpha(64),
              ),
            ),
            child: thoughts.isEmpty
                ? Center(
                    // "No thoughts found! \n\nY'all should try making one. \n\nI know you're a smart cookie.",
                    // child: Text(
                    //   "No thoughts found! \n\nY'all should try making one. \n\nI know you're a smart cookie.",
                    //   style: Provider.of<ComindColorsNotifier>(context)
                    //       .textTheme
                    //       .bodyMedium,
                    // ),

                    // Using text span
                    child: RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: "No thoughts found! \n\n",
                        style: Provider.of<ComindColorsNotifier>(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Provider.of<ComindColorsNotifier>(context)
                                  .colorScheme
                                  .onPrimary
                                  .withAlpha(180),
                            ),
                        children: <TextSpan>[
                          TextSpan(
                            text: "Y'all should make some. \n\n",
                            style: Provider.of<ComindColorsNotifier>(context)
                                .textTheme
                                .bodyLarge,
                          ),
                          TextSpan(
                            text:
                                "I would. But I am just a lame, boring computer.\n\n",
                            style: Provider.of<ComindColorsNotifier>(context)
                                .textTheme
                                .bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  )
                // Otherwise, show everything
                : Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                    child: ListView.builder(
                        itemCount: thoughts.length,
                        itemBuilder: (context, index) {
                          return MarkdownThought(
                              thought: thoughts[index],
                              parentThought: parentThought?.id);
                        }),
                  ),
          ),
        ),

        // Display ("Search results") at top left corner
        Positioned(
          top: -12,
          left: 10,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
            child: Row(
              children: [
                // Send button
                Container(
                  decoration: BoxDecoration(
                    color: Provider.of<ComindColorsNotifier>(context)
                        .colorScheme
                        .background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Text(
                      "Related",
                      style: Provider.of<ComindColorsNotifier>(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            color: Provider.of<ComindColorsNotifier>(context)
                                .colorScheme
                                .onPrimary
                                .withAlpha(180),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
