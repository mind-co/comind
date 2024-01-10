// The "think" button is a text widget with the text think
// and a callback to the think() function.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'colors.dart';

class ThinkButton extends StatelessWidget {
  const ThinkButton({Key? key, this.onPressed}) : super(key: key);

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
      //   border: Border.all(
      //     color: Provider.of<ComindColorsNotifier>(context)
      //         .colorScheme
      //         .onPrimary
      //         .withAlpha(64),
      //     width: 1,
      //   ),
      // ),
      child: Material(
        color: Provider.of<ComindColorsNotifier>(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
        elevation: 0,
        child: InkWell(
          enableFeedback: true,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ComindColors.bubbleRadius,
            ),
          ),
          hoverColor:
              Provider.of<ComindColorsNotifier>(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            // child: Icon(
            //   Icons.send,
            //   color: Provider.of<ComindColorsNotifier>(context)
            //       .colorScheme
            //       .onPrimary,
            // )

            //
            child: Text("think",
                style: Provider.of<ComindColorsNotifier>(context)
                    .textTheme
                    .titleSmall),

            //
          ),
        ),
      ),
    );
  }
}
