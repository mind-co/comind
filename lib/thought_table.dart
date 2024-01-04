// ThoughtTable shows a list of searched thoughts
import 'package:comind/colors.dart';
import 'package:comind/markdown_display.dart';
import 'package:comind/text_button.dart';
import 'package:comind/types/thought.dart';
import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          width: ComindColors.maxWidth,
          height: 300,
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(10),
            // Border color

            // Left border only
            border: Border(
              left: BorderSide(
                color: Provider.of<ComindColorsNotifier>(context)
                    .colorScheme
                    .onBackground
                    .withAlpha(64),
                width: 2.0,
              ),

              // color: Provider.of<ComindColorsNotifier>(context)
              //     .colorScheme
              //     .onBackground
              //     .withAlpha(64),
            ),
          ),

          // If there are no thoughts, show a message
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
              : Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: ListView.builder(
                      itemCount: thoughts.length + 1,
                      itemBuilder: (context, index) {
                        if (index < thoughts.length) {
                          return MarkdownThought(
                              type: MarkdownDisplayType.searchResult,
                              thought: thoughts[index],
                              context: context,
                              parentThought: parentThought?.id);
                        } else {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 32, 0, 32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Do you want to see ",
                                    style: Provider.of<ComindColorsNotifier>(
                                            context)
                                        .textTheme
                                        .bodyMedium,
                                  ),
                                  // TODO #5 add more thoughts button
                                  ComindTextButton(
                                    text: "More",
                                    onPressed: () {},
                                    opacity: 1.0,
                                    fontSize: 16,
                                  ),
                                  Text(
                                    " thoughts?",
                                    style: Provider.of<ComindColorsNotifier>(
                                            context)
                                        .textTheme
                                        .bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }),
                ),
        ),

        // Display ("Search results") at top left corner
        Positioned(
          top: -8,
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
                          .titleSmall
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
