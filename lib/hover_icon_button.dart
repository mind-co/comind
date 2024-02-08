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
      this.size = 18.0});

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
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: IconButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                // side: BorderSide(
                //   color: Provider.of<ComindColorsNotifier>(context)
                //       .primary
                //       .withAlpha(64),
                //   width: 1.0, // Set the outline width
                // ),
              ),
            ),
            // shape: MaterialStateProperty.all(ContinuousRectangleBorder(
            //     borderRadius: BorderRadius.circular(30))), // Beveled corners
            padding: MaterialStateProperty.all(EdgeInsets.zero),

            // backgroundColor: MaterialStateProperty.all(
            //     Provider.of<ComindColorsNotifier>(context)
            //         .surface
            //         .withAlpha(200)
            //         ),
          ),
          hoverColor:
              Provider.of<ComindColorsNotifier>(context).primary.withAlpha(164),
          padding: EdgeInsets.zero,
          onPressed: widget.onPressed,
          visualDensity: VisualDensity.comfortable,
          icon: Opacity(
              opacity: _isHovering ? 1.0 : 0.5, // Change opacity on hover
              child: Icon(
                widget.icon,
                color: _isHovering
                    ? Provider.of<ComindColorsNotifier>(context).onPrimary
                    : Provider.of<ComindColorsNotifier>(context).onBackground,
                size: widget.size,
              )),
        ),
      ),
    );
  }
}
