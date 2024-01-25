import 'dart:math';

import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  // Columns
  final Widget leftColumn;
  final Widget middleColumn;
  final Widget rightColumn;

  // Constructor
  const MainLayout({
    Key? key,
    this.leftColumn = const SizedBox(),
    required this.middleColumn,
    this.rightColumn = const SizedBox(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left column
            if (showSideColumns(context))
              SizedBox(
                width: leftColumnWidth(context),
                child: leftColumn,
              ),

            // Middle column
            SizedBox(
              width: centerColumnWidth(context),
              child: middleColumn,
            ),

            // Right column
            if (showSideColumns(context))
              SizedBox(
                width: rightColumnWidth(context),
                child: rightColumn,
              ),
          ],
        ),
      ),
    );
  }

  bool showSideColumns(BuildContext context) =>
      MediaQuery.of(context).size.width > 800;
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
    return MediaQuery.of(context).size.width > 550
        ? 550
        : MediaQuery.of(context).size.width;
  }

  double rightColumnWidth(BuildContext context) {
    return min(300, baseOuterWidth(context));
  }
}
