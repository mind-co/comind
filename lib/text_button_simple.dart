import 'package:comind/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextButtonSimple extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  TextButtonSimple(
      {Key? key,
      required this.text,
      required this.onPressed,
      bool? isHighlighted})
      : super(key: key);

  // Tracks whether this is highlighted or not
  bool _isHighlighted = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        animationDuration: const Duration(milliseconds: 10),
        // Title when hovered
        textStyle: MaterialStateProperty.resolveWith<TextStyle>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered) || _isHighlighted) {
              return Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withAlpha(255),
                  );
            }
            return Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color:
                      Theme.of(context).colorScheme.onBackground.withAlpha(200),
                );
          },
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
              return Theme.of(context).colorScheme.onBackground.withAlpha(200);
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
            // borderRadius: BorderRadius.circular(0),
            borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
          ),
        ),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
