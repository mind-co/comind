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
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 3, 3, 3),
          child: IconButton(
            style: ButtonStyle(
              // backgroundColor: MaterialStateProperty.all<Color>(
              //     Provider.of<ComindColorsNotifier>(context)
              //         .colorScheme
              //         .primary),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              fixedSize: MaterialStateProperty.all<Size>(Size(45, 45)),
            ),
            hoverColor:
                Provider.of<ComindColorsNotifier>(context).colorScheme.primary,
            enableFeedback: true,
            onPressed: onPressed,
            icon: Icon(Icons.send),
            iconSize: 24,
          ),
        ),
      ],
    );
  }
}
