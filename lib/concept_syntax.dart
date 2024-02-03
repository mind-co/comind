// Parses {concept} into <a href="https://en.wikipedia.org/wiki/Concept">concept</a>.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

// Matches {[comind_name]}
class ComindSyntax extends md.InlineSyntax {
  static final String AST_SYMBOL = 'comindName';
  ComindSyntax() : super(_pattern);

  static const String _pattern = r'{([a-zA-Z0-9_]+)}';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text(AST_SYMBOL, match[1]!));
    return true;
  }
}

// Builder for comind syntax
// class ComindSyntaxBuilder extends MarkdownElementBuilder {
//   @override
//   Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
//     if (element.tag == ComindSyntax.AST_SYMBOL) {
//       return Text(
//         element.textContent,
//         style: const TextStyle(
//           fontFamily: "Bungee",
//           color: Colors.blue,
//           fontWeight: FontWeight.bold,
//         ),
//       );
//     }
//     return null;
//   }
// }

class ComindSyntaxBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag == ComindSyntax.AST_SYMBOL) {
      return ComindText(text: element.textContent);
    }
    return null;
  }
}

class ComindText extends StatelessWidget {
  final String text;

  ComindText({required this.text});

  @override
  Widget build(BuildContext context) {
    // Use the BuildContext to decide how to build the widget
    return Tooltip(
      message:
          'At some point this tooltip will be helpful. It is not helpful right now.',
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
