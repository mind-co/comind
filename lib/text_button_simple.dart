import 'package:comind/colors.dart';
import 'package:flutter/material.dart';

class TextButtonSimple extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const TextButtonSimple(
      {Key? key, required this.text, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all(
          Theme.of(context).textTheme.titleMedium,
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return Theme.of(context).colorScheme.onBackground.withAlpha(255);
            } else if (states.contains(MaterialState.pressed)) {
              return Theme.of(context).colorScheme.onBackground.withAlpha(255);
            } else if (states.contains(MaterialState.disabled)) {
              return Theme.of(context).colorScheme.onBackground.withAlpha(64);
            } else {
              return Theme.of(context).colorScheme.onBackground.withAlpha(164);
            }
            return Theme.of(context).colorScheme.onBackground;
          },
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return Theme.of(context).colorScheme.onBackground.withAlpha(16);
            } else if (states.contains(MaterialState.pressed)) {
              return Theme.of(context).colorScheme.onBackground.withAlpha(64);
            } else if (states.contains(MaterialState.disabled)) {
              return Theme.of(context).colorScheme.onBackground.withAlpha(0);
            }
            return Theme.of(context).colorScheme.background;
          },
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
          ),
        ),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
