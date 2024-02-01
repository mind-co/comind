import 'package:comind/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextButtonSimple extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ColorChoice? colorChoice;

  TextButtonSimple(
      {Key? key,
      required this.text,
      required this.onPressed,
      this.colorChoice = ColorChoice.primary,
      bool? isHighlighted})
      : super(key: key);

  // Tracks whether this is highlighted or not
  bool _isHighlighted = false;

  @override
  Widget build(BuildContext context) {
    // Get our color based on the color choice
    Color color = colorChoice == ColorChoice.primary
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;

    // Color choice
    return TextButton(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all<Size>(Size.zero),
          visualDensity: VisualDensity(horizontal: -4, vertical: 0),
          padding:
              MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
          animationDuration: const Duration(milliseconds: 10),
          // Title when hovered
          textStyle: MaterialStateProperty.resolveWith<TextStyle>(
            (Set<MaterialState> states) {
              //states.contains(MaterialState.hovered) || _isHighlighted) {
              return Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withAlpha(255),
                  );
            },
          ),
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return Theme.of(context).colorScheme.onPrimary.withAlpha(255);
              } else if (states.contains(MaterialState.pressed)) {
                return Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withAlpha(255);
              } else if (states.contains(MaterialState.disabled)) {
                return Theme.of(context).colorScheme.onBackground.withAlpha(64);
              } else {
                return Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withAlpha(200);
              }
            },
          ),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return color;
              } else if (states.contains(MaterialState.pressed)) {
                return Theme.of(context).colorScheme.onBackground.withAlpha(64);
              } else if (states.contains(MaterialState.disabled)) {
                return Theme.of(context).colorScheme.onBackground.withAlpha(0);
              }
              return Theme.of(context).colorScheme.surface;
            },
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              // borderRadius: BorderRadius.circular(0),
              borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  // The first letter in primary
                  text: text,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        // fontSize: 11,
                        decoration: TextDecoration.underline,
                        decorationColor: color,
                        decorationThickness: 3,
                      ),
                ),
                // The rest of the text
                // TextSpan(
                //   text: text.substring(1),
                //   style: Theme.of(context).textTheme.titleSmall,
                // ),
              ],
            ),
          ),
        ));
  }
}
