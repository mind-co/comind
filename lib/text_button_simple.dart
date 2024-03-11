import 'package:comind/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextButtonSimple extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ColorChoice colorChoice;
  final bool isHighlighted;
  final bool noBackground;
  final double fontScalar;
  final bool outlined;
  final EdgeInsets padding;
  final double opacity;
  final double opacityOnHover;

  TextButtonSimple(
      {Key? key,
      required this.text,
      required this.onPressed,
      this.colorChoice = ColorChoice.primary,
      this.noBackground = false,
      this.outlined = true,
      this.fontScalar = 1.0,
      this.opacity = 0.4,
      this.opacityOnHover = 1.0,
      this.padding = const EdgeInsets.fromLTRB(4, 4, 4, 4),
      this.isHighlighted = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var titleSmall = textTheme.titleSmall;
    var colors = Provider.of<ComindColorsNotifier>(context).colorScheme;

    return Padding(
      padding: padding,
      child: TextButton(
        style: ButtonStyle(
          animationDuration: const Duration(milliseconds: 10),
          minimumSize: MaterialStateProperty.all<Size>(
            const Size(0, 0),
          ),
          side: MaterialStateProperty.resolveWith<BorderSide>(
            (Set<MaterialState> states) {
              // If outlined, return a border
              if (outlined) {
                return BorderSide(
                  color: colors.onBackground.withOpacity(
                      states.contains(MaterialState.hovered) || isHighlighted
                          ? opacityOnHover
                          : opacity),
                  width: 1,
                );
              }

              // Otherwise return none
              return BorderSide.none;
            },
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
                    color: colors.onPrimary.withOpacity(opacityOnHover));
              }
              return titleSmall!.copyWith(
                fontSize: titleSmall!.fontSize! * fontScalar,
                color: colors.onBackground.withOpacity(opacity),
              );
            },
          ),
          // letters become onprimary
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return colors.onPrimary.withOpacity(opacityOnHover);
              } else if (states.contains(MaterialState.pressed)) {
                return colors.onBackground;
              } else if (states.contains(MaterialState.disabled)) {
                return colors.onBackground.withAlpha(64);
              } else {
                return colors.onBackground.withOpacity(opacity);
              }
            },
          ),
          // background becomes primary
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return colors.primary;
              }

              if (noBackground) {
                return Colors.transparent;
              } else if (states.contains(MaterialState.pressed)) {
                return colors.onBackground.withAlpha(64);
              } else if (states.contains(MaterialState.disabled)) {
                return colors.onBackground.withAlpha(0);
              }
              return Colors.transparent;
              // return colors.surface;
              // return colors.background;
            },
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              // side: BorderSide(
              //   color: colors.primary,
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
      ),
    );
  }
}
