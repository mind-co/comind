import 'package:comind/colors.dart';
import 'package:flutter/material.dart';

class TextButtonSimple extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ColorChoice colorChoice;
  final bool isHighlighted;
  final bool noBackground;
  final double fontScalar;

  TextButtonSimple(
      {Key? key,
      required this.text,
      required this.onPressed,
      this.colorChoice = ColorChoice.primary,
      this.noBackground = false,
      this.fontScalar = 1.0,
      this.isHighlighted = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var titleSmall = textTheme.titleSmall;

    return TextButton(
      style: ButtonStyle(
        animationDuration: const Duration(milliseconds: 10),
        minimumSize: MaterialStateProperty.all<Size>(
          const Size(0, 0),
        ),
        padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry>(
          (Set<MaterialState> states) {
            // if (states.contains(MaterialState.hovered) || isHighlighted) {
            //   return const EdgeInsets.fromLTRB(8, 8, 8, 8);
            // }
            return const EdgeInsets.fromLTRB(8, 12, 8, 12);
          },
        ),
        // Title when hovered
        textStyle: MaterialStateProperty.resolveWith<TextStyle>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered) || isHighlighted) {
              return titleSmall!.copyWith(
                fontSize: titleSmall!.fontSize! * fontScalar,
                color: Theme.of(context).colorScheme.onPrimary.withAlpha(255),
              );
            }
            return titleSmall!.copyWith(
              fontSize: titleSmall!.fontSize! * fontScalar,
              color: Theme.of(context).colorScheme.onBackground.withAlpha(200),
            );
          },
        ),
        // letters become onprimary
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return Theme.of(context).colorScheme.onPrimary.withAlpha(255);
            } else if (states.contains(MaterialState.pressed)) {
              return Theme.of(context).colorScheme.onBackground.withAlpha(255);
            } else if (states.contains(MaterialState.disabled)) {
              return Theme.of(context).colorScheme.onBackground.withAlpha(64);
            } else {
              return Theme.of(context).colorScheme.onBackground.withAlpha(200);
            }
          },
        ),
        // background becomes primary
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return Theme.of(context).colorScheme.primary;
            }

            if (noBackground) {
              return Colors.transparent;
            } else if (states.contains(MaterialState.pressed)) {
              return Theme.of(context).colorScheme.onBackground.withAlpha(64);
            } else if (states.contains(MaterialState.disabled)) {
              return Theme.of(context).colorScheme.onBackground.withAlpha(0);
            }
            return Colors.transparent;
            // return Theme.of(context).colorScheme.surface;
            // return Theme.of(context).colorScheme.background;
          },
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            // side: BorderSide(
            //   color: Theme.of(context).colorScheme.primary,
            //   width: 1,
            // ),
            // borderRadius: BorderRadius.circular(0),
            borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
          ),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
      ),
    );
  }
}
