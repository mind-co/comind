// Opens the color picker menu
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'colors.dart';

class ColorButton extends StatelessWidget {
  const ColorButton({Key? key, this.onPressed}) : super(key: key);

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Provider.of<ComindColorsNotifier>(context)
                      .colorScheme
                      .primary),
            ),
            hoverColor:
                Provider.of<ComindColorsNotifier>(context).colorScheme.primary,
            enableFeedback: true,
            onPressed: onPressed,
            icon: const Icon(Icons.circle))
      ],
    );
  }
}
