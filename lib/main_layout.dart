import 'dart:async';
import 'dart:math';

import 'package:comind/colors.dart';
import 'package:comind/providers.dart';
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
    return SingleChildScrollView(
      controller: _scrollController, // Add this line
      child: rowOfColumns(context),
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
      MediaQuery.of(context).size.width > 1000;

  //
  // Column width methods
  //
  double baseOuterWidth(BuildContext context) {
    double width =
        (MediaQuery.of(context).size.width - centerColumnWidth(context) - 25) /
            2;
    return max(0, width);
  }

  double leftColumnWidth(BuildContext context) {
    double width = min(300, baseOuterWidth(context));
    return max(0, width);
  }

  double centerColumnWidth(BuildContext context) {
    return MediaQuery.of(context).size.width >= ComindColors.maxWidth
        ? ComindColors.maxWidth
        : MediaQuery.of(context).size.width;
  }

  double rightColumnWidth(BuildContext context) {
    double width = min(300, baseOuterWidth(context));
    return max(0, width);
  }
}
