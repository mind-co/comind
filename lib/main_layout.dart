import 'dart:async';
import 'dart:math';

import 'package:comind/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IgnoreArrowKeyTraversalPolicy extends FocusTraversalPolicy {
  @override
  FocusNode? findFirstFocusInDirection(
      FocusNode currentNode, TraversalDirection direction) {
    // Implement the logic to find the first focus node in the given direction
    return null;
  }

  @override
  Iterable<FocusNode> sortDescendants(
      Iterable<FocusNode> descendants, FocusNode currentNode) {
    // Implement the logic to sort the descendants based on the currentNode
    return [];
  }

  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    // Implement the logic to determine if potentialNextNode is in the given direction from currentNode
    return false;
  }
}

class MainLayout extends StatefulWidget {
  // Columns
  final Widget leftColumn;
  final Widget middleColumn;
  final Widget rightColumn;

  // Constructor
  MainLayout({
    Key? key,
    this.leftColumn = const SizedBox(),
    required this.middleColumn,
    this.rightColumn = const SizedBox(),
  }) : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Scroll controller and focus node
  final ScrollController _scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  Timer _scrollTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {});

  // This is the units of scroll per key press.
  // A scale of 20 means 1/20th of the screen height per key press.
  final double _arrowScrollScalar = 20;
  final double _pageScrollScalar = 2;

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: IgnoreArrowKeyTraversalPolicy(),
      child: KeyboardListener(
        onKeyEvent: (KeyEvent event) {
          double scale = event.logicalKey == LogicalKeyboardKey.arrowUp ||
                  event.logicalKey == LogicalKeyboardKey.arrowDown
              ? _arrowScrollScalar
              : _pageScrollScalar;

          if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
              event.logicalKey == LogicalKeyboardKey.pageUp) {
            double newOffset = _scrollController.offset -
                MediaQuery.of(context).size.height / scale;
            if (newOffset > _scrollController.position.minScrollExtent) {
              _scrollController.jumpTo(newOffset);
            } else {
              _scrollController
                  .jumpTo(_scrollController.position.minScrollExtent);
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
              event.logicalKey == LogicalKeyboardKey.pageDown) {
            double newOffset = _scrollController.offset +
                MediaQuery.of(context).size.height / scale;
            if (newOffset < _scrollController.position.maxScrollExtent) {
              _scrollController.jumpTo(newOffset);
            } else {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            }
          }
        },
        focusNode: focusNode,
        child: SingleChildScrollView(
          controller: _scrollController, // Add this line
          child: rowOfColumns(context),
        ),
      ),
    );
  }

  Row rowOfColumns(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left column
        if (showSideColumns(context))
          SizedBox(
            width: leftColumnWidth(context),
            child: widget.leftColumn,
          ),

        // Middle column
        Container(
          width: centerColumnWidth(context),
          child: widget.middleColumn,
        ),

        // Right column
        if (showSideColumns(context))
          SizedBox(
            width: rightColumnWidth(context),
            child: widget.rightColumn,
          ),
      ],
    );
  }

  bool showSideColumns(BuildContext context) =>
      MediaQuery.of(context).size.width > 0;
  // MediaQuery.of(context).size.width > 800 && getTopOfMind(context) != null;

  //
  // Column width methods
  //
  double baseOuterWidth(BuildContext context) {
    return (MediaQuery.of(context).size.width -
            centerColumnWidth(context) -
            25) /
        2;
  }

  double leftColumnWidth(BuildContext context) {
    return min(300, baseOuterWidth(context));
  }

  double centerColumnWidth(BuildContext context) {
    return MediaQuery.of(context).size.width >= ComindColors.maxWidth
        ? ComindColors.maxWidth
        : MediaQuery.of(context).size.width;
  }

  double rightColumnWidth(BuildContext context) {
    return min(300, baseOuterWidth(context));
  }
}
