import 'package:flutter/material.dart';

class ComindTextButton extends StatefulWidget {
  final String text;
  final double opacityOnHover;
  final TextStyle textStyle;
  final Function onPressed;
  final double opacity;
  final int colorIndex;
  final bool underline;

  ComindTextButton({
    required this.text,
    this.opacityOnHover = 1.0,
    this.textStyle = const TextStyle(fontFamily: "Bungee", fontSize: 16),
    required this.onPressed,
    this.opacity = 0.5,
    this.colorIndex = 1, // 1 = primary, 2 = secondary, 3 = tertiary
    this.underline = true,
  });

  @override
  _ComindTextButtonState createState() => _ComindTextButtonState();
}

class _ComindTextButtonState extends State<ComindTextButton> {
  bool _isHovered = false;
  bool _isPressed = false;
  int colorIndex = 0;

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
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 2, 4, 0),
          child: Opacity(
            opacity: _isHovered ? widget.opacityOnHover : widget.opacity,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.transparent,
                    width: _isHovered ? 1.0 : 4.0,
                  ),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorIndex == 0
                          ? Colors.red
                          : colorIndex == 1
                              ? Colors.blue
                              : colorIndex == 2
                                  ? Colors.red
                                  : Colors.green,
                      width: _isHovered ? 6.0 : 3.0,
                    ),
                  ),
                ),
                child: Text(
                  widget.text,
                  style: widget.textStyle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
