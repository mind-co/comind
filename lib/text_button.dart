import 'package:comind/colors.dart';
import 'package:flutter/material.dart';

enum LineLocation { top, bottom, left, right }

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
    required this.text,
    this.opacityOnHover = 1.0,
    this.textStyle = const TextStyle(
      fontFamily: "Bungee",
      fontSize: 14,
    ),
    required this.onPressed,
    this.opacity = 0.5,
    this.colorIndex = 1, // 1 = primary, 2 = secondary, 3 = tertiary
    this.lineLocation = LineLocation.bottom,
    this.fontSize = 16,
    this.lineOnly = true,
  });

  @override
  _ComindTextButtonState createState() => _ComindTextButtonState();
}

class _ComindTextButtonState extends State<ComindTextButton> {
  bool _isHovered = false;
  bool _isPressed = false;
  int colorIndex = 0;
  // bool lineOnly = true;

  // Method to make the color shift to the next one
  void shiftColor() {
    setState(() {
      colorIndex = colorIndex == 0
          ? 1
          : colorIndex == 1
              ? 2
              : colorIndex == 2
                  ? 3
                  : 1;
    });
  }

  // Initialization
  @override
  void initState() {
    super.initState();
    colorIndex = widget.colorIndex;
  }

  @override
  Widget build(BuildContext context) {
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
          // shiftColor();

          // Turn ispressed on and disable it after 100ms
          setState(() {
            _isPressed = true;
          });
          Future.delayed(const Duration(milliseconds: 100), () {
            setState(() {
              _isPressed = false;
            });
          });
        },
        child: Opacity(
          opacity: _isHovered ? widget.opacityOnHover : widget.opacity,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                // Top
                top: widget.lineLocation == LineLocation.top
                    ? BorderSide(
                        color: Colors.transparent,
                        width: _isHovered ? 1.0 : 4.0,
                      )
                    : BorderSide(
                        color: Colors.transparent,
                      ),

                // Bottom
                bottom: widget.lineLocation == LineLocation.bottom
                    ? BorderSide(
                        color: Colors.transparent,
                        width: _isHovered ? 1.0 : 4.0,
                      )
                    : BorderSide(
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
                                    ? ComindColors().tertiaryColor
                                    : colorIndex == 2
                                        ? ComindColors().primaryColor
                                        : ComindColors().secondaryColor,
                            width: _isHovered ? 6.0 : 3.0,
                          )
                        : BorderSide(
                            color: Colors.transparent,
                            width: 0.0,
                          ),

                    bottom: widget.lineLocation == LineLocation.bottom
                        ? BorderSide(
                            color: colorIndex == 0
                                ? Colors.transparent
                                : colorIndex == 1
                                    ? ComindColors().tertiaryColor
                                    : colorIndex == 2
                                        ? ComindColors().primaryColor
                                        : ComindColors().secondaryColor,
                            width: _isHovered ? 6.0 : 3.0,
                          )
                        : BorderSide(
                            color: Colors.transparent,
                            width: 0.0,
                          ),
                  ),
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: !widget.lineOnly ? 0 : 1,
                  child: Text(
                    widget.text,
                    style: widget.textStyle.copyWith(
                      fontSize: widget.fontSize,
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
