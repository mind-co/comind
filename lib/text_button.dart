import 'package:comind/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum LineLocation { top, bottom, left, right, none }

// ignore: must_be_immutable
class ComindTextButton extends StatefulWidget {
  final String text;
  final double opacityOnHover;
  final TextStyle textStyle;
  final Function onPressed;
  final double opacity;
  final int colorIndex;
  final LineLocation lineLocation;
  final String side = "top";
  final double fontSize;
  bool lineOnly = true;

  ComindTextButton({
    super.key,
    required this.text,
    this.opacityOnHover = 1.0,
    this.textStyle = const TextStyle(
      fontFamily: "Bungee",
      fontSize: 16,
    ),
    required this.onPressed,
    this.opacity = 0.5,
    this.colorIndex = 1, // 1 = primary, 2 = secondary, 3 = tertiary
    this.lineLocation = LineLocation.top,
    this.fontSize = 14,
    this.lineOnly = true,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ComindTextButtonState createState() => _ComindTextButtonState();
}

class _ComindTextButtonState extends State<ComindTextButton> {
  bool _isHovered = false;
  int colorIndex = 0;
  // bool lineOnly = true;

  @override
  void didUpdateWidget(ComindTextButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.colorIndex != oldWidget.colorIndex) {
      setState(() {
        colorIndex = widget.colorIndex;
      });
    }
  }

  // Initialization
  @override
  void initState() {
    super.initState();
    colorIndex = widget.colorIndex;
  }

  @override
  Widget build(BuildContext context) {
    // shiftColor();
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _isHovered = true;
          // lineOnly = false;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          // lineOnly = true;
        });
      },
      child: GestureDetector(
        onTap: () {
          widget.onPressed();
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 50),
          opacity: _isHovered ? widget.opacityOnHover : widget.opacity,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                // Top
                top: widget.lineLocation == LineLocation.top
                    ? BorderSide(
                        color: Colors.transparent,
                        // color: Colors.red,
                        // color: colorIndex == 0
                        //     ? Colors.transparent
                        //     : colorIndex == 1
                        //         ? Provider.of<ComindColorsNotifier>(
                        //                 context)
                        //             .currentColors
                        //             .tertiaryColor
                        //         : colorIndex == 2
                        //             ? Provider.of<ComindColorsNotifier>(
                        //                     context)
                        //                 .currentColors
                        //                 .primaryColor
                        //             : Provider.of<ComindColorsNotifier>(
                        //                     context)
                        //                 .currentColors
                        //                 .secondaryColor,
                        width: _isHovered ? 1.0 : 5.0,
                      )
                    : const BorderSide(),

                left: widget.lineLocation == LineLocation.left
                    ? BorderSide(
                        color: Colors.transparent,
                        width: _isHovered ? 1.0 : 5.0,
                      )
                    : const BorderSide(
                        color: Colors.transparent,
                      ),

                // // Bottom
                bottom: widget.lineLocation == LineLocation.bottom
                    ? BorderSide(
                        color: Colors.transparent,
                        width: _isHovered ? 10.0 : 5.0,
                      )
                    : const BorderSide(
                        color: Colors.transparent,
                      ),
              ),
            ),
            child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    // Top appears if !underline
                    top: widget.lineLocation == LineLocation.top
                        ? BorderSide(
                            color: colorIndex == 0
                                ? Colors.transparent
                                : colorIndex == 1
                                    ? Provider.of<ComindColorsNotifier>(context)
                                        .currentColors
                                        .tertiaryColor
                                    : colorIndex == 2
                                        ? Provider.of<ComindColorsNotifier>(
                                                context)
                                            .currentColors
                                            .primaryColor
                                        : Provider.of<ComindColorsNotifier>(
                                                context)
                                            .currentColors
                                            .secondaryColor,
                            width: _isHovered ? 6.0 : 2.0,
                          )
                        : const BorderSide(
                            color: Colors.transparent,
                            width: 0.0,
                          ),

                    // Left appears if !underline
                    left: widget.lineLocation == LineLocation.left
                        ? BorderSide(
                            color: colorIndex == 0
                                ? Colors.transparent
                                : colorIndex == 1
                                    ? Provider.of<ComindColorsNotifier>(context)
                                        .currentColors
                                        .tertiaryColor
                                    : colorIndex == 2
                                        ? Provider.of<ComindColorsNotifier>(
                                                context)
                                            .currentColors
                                            .primaryColor
                                        : Provider.of<ComindColorsNotifier>(
                                                context)
                                            .currentColors
                                            .secondaryColor,
                            width: _isHovered ? 6.0 : 3.0,
                          )
                        : const BorderSide(
                            color: Colors.transparent,
                            width: 0.0,
                          ),

                    bottom: widget.lineLocation == LineLocation.bottom
                        ? BorderSide(
                            color: colorIndex == 0
                                ? Colors.transparent
                                : colorIndex == 1
                                    ? Provider.of<ComindColorsNotifier>(context)
                                        .currentColors
                                        .tertiaryColor
                                    : colorIndex == 2
                                        ? Provider.of<ComindColorsNotifier>(
                                                context)
                                            .currentColors
                                            .primaryColor
                                        : Provider.of<ComindColorsNotifier>(
                                                context)
                                            .currentColors
                                            .secondaryColor,
                            width: _isHovered ? 30.0 : 3.0,
                          )
                        : const BorderSide(
                            color: Colors.transparent,
                            width: 0.0,
                          ),
                  ),
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: !widget.lineOnly ? 0 : 1,
                  child: Padding(
                    padding: widget.lineLocation == LineLocation.left
                        ? const EdgeInsets.fromLTRB(6, 0, 0, 0)
                        : widget.lineLocation == LineLocation.right
                            ? const EdgeInsets.fromLTRB(0, 0, 6, 0)
                            : const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Text(
                      widget.text,
                      style: widget.textStyle.copyWith(
                        fontSize: widget.fontSize,
                      ),
                    ),
                  ),
                )
                // child: Text(
                //   widget.text,
                //   style: widget.textStyle,
                // ),
                ),
          ),
        ),
      ),
    );
  }
}
