import 'package:comind/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HoverIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  const HoverIconButton(
      {super.key,
      required this.icon,
      required this.onPressed,
      this.size = 32.0});

  @override
  _HoverIconButtonState createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<HoverIconButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() => _isHovering = true),
      onExit: (event) => setState(() => _isHovering = false),
      child: IconButton(
        hoverColor: Provider.of<ComindColorsNotifier>(context)
            .colorScheme
            .primary
            .withAlpha(255),
        padding: EdgeInsets.zero,
        onPressed: widget.onPressed,
        visualDensity: VisualDensity.compact,
        icon: Opacity(
          opacity: _isHovering ? 1.0 : 0.5, // Change opacity on hover
          child: Icon(
            widget.icon,
            size: widget.size,
            color: Provider.of<ComindColorsNotifier>(context)
                .colorScheme
                .onPrimary
                .withAlpha(255),
          ),
        ),
      ),
    );
  }
}
