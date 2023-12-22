import 'package:comind/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Basic body text style widget
class BodyText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const BodyText(this.text, {this.style, this.textAlign, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ??
          Provider.of<ComindColorsNotifier>(context).textTheme.bodyMedium,
      textAlign: textAlign,
    );
  }
}
