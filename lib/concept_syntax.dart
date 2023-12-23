// Parses {concept} into <a href="https://en.wikipedia.org/wiki/Concept">concept</a>.

import 'package:markdown/markdown.dart';

/// A helper class holds params of link context.
/// Footnote creation needs other info in [_tryCreateReferenceLink].

/// Character `{`.
const int $lbrace = 0x7B;

/// Character `}`.
const int $rbrace = 0x7D;

/// Character `\`.
const int $backslash = 0x5C;

/// Character `(`.
const int $lparen = 0x28;

/// Character `)`.
const int $rparen = 0x29;

// Matches `{concept}`.
class ConceptSyntax extends DelimiterSyntax {
  ConceptSyntax()
      : super(
          r'\{',
          requiresDelimiterRun: true,
          startCharacter: $lbrace,
        );

  @override
  bool onMatch(
    InlineParser parser,
    Match match,
  ) {
    final runLength = match.group(0)!.length;
    final matchStart = parser.pos;
    final matchEnd = parser.pos + runLength;
    final text = Text(parser.source.substring(matchStart, matchEnd));
    if (!requiresDelimiterRun) {
      parser.pushDelimiter(SimpleDelimiter(
        node: text,
        length: runLength,
        char: parser.source.codeUnitAt(matchStart),
        canOpen: true,
        canClose: false,
        syntax: this,
        endPos: matchEnd,
      ));
      parser.addNode(text);
      return true;
    }

    final delimiterRun = DelimiterRun.tryParse(
      parser,
      matchStart,
      matchEnd,
      syntax: this,
      node: text,
      allowIntraWord: allowIntraWord,
      tags: tags ?? const [],
    );
    if (delimiterRun != null) {
      parser.pushDelimiter(delimiterRun);
      parser.addNode(text);
      return true;
    } else {
      parser.advanceBy(runLength);
      return false;
    }
  }
}
