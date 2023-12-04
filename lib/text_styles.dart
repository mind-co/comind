import 'package:flutter/material.dart';

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
      style: style ?? Theme.of(context).textTheme.bodyMedium,
      textAlign: textAlign,
    );
  }
}
