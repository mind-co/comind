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
    return IconButton(
        hoverColor:
            Provider.of<ComindColorsNotifier>(context).colorScheme.primary,
        enableFeedback: true,
        onPressed: onPressed,
        icon: Icon(Icons.send));
  }
}
