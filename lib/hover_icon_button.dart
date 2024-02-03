import 'package:comind/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class HoverIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  const HoverIconButton(
      {super.key,
      required this.icon,
      required this.onPressed,
      this.size = 16.0});

  @override
  HoverIconButtonState createState() => HoverIconButtonState();
}

class HoverIconButtonState extends State<HoverIconButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() => _isHovering = true),
      onExit: (event) => setState(() => _isHovering = false),
      child: IconButton(
        hoverColor:
            Provider.of<ComindColorsNotifier>(context).primary.withAlpha(255),
        padding: EdgeInsets.zero,
        onPressed: widget.onPressed,
        visualDensity: VisualDensity.compact,
        icon: Opacity(
            opacity: _isHovering ? 1.0 : 0.5, // Change opacity on hover
            child: FaIcon(
              widget.icon,
              color: _isHovering
                  ? Provider.of<ComindColorsNotifier>(context).onPrimary
                  : Provider.of<ComindColorsNotifier>(context).onBackground,
              size: widget.size,
            )),
      ),
    );
  }
}
