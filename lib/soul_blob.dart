import 'dart:math';
import 'package:comind/colors.dart';
import 'package:flutter/material.dart';

// Custom Painter for drawing the bottom third of a circle
class SoulBlobPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;
  final Color backgroundColor;

  SoulBlobPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintPrimary = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final paintSecondary = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    final paintTertiary = Paint()
      ..color = tertiaryColor
      ..style = PaintingStyle.fill;

    // Center of the circle
    final center = Offset(size.width / 2, size.height / 2);

    // Outer radius of the circle
    final outerRadius = size.width * 0.7;

    // Inner radius of the circle
    final innerRadius = outerRadius * 0.5;

    // Angles for the left half
    const startAngleLeft = pi / 2;
    const sweepAngleLeft = pi;

    // Angles for the right half
    const startAngleRight = pi / 2;
    const sweepAngleRight = -pi;

    // Bottom third of the circle
    final pathLeft = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngleLeft,
        sweepAngleLeft,
        false,
      )
      ..lineTo(center.dx, center.dy);

    // Top left third of the circle
    final pathRight = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngleRight,
        sweepAngleRight,
        false,
      )
      ..lineTo(center.dx, center.dy);

    // Draw the bottom third of the circle
    canvas.drawPath(pathLeft, paintSecondary);

    // Draw the top left third of the circle
    canvas.drawPath(pathRight, paintTertiary);

    // Draw a background circle in the center
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 4;

    // Draw a background circle to separate the center from the rest
    canvas.drawCircle(center, innerRadius * 1.5, backgroundPaint);

    // Draw a vertical line to separate the left and right halves
    final linePaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawLine(
      Offset(center.dx, center.dy - outerRadius),
      Offset(center.dx, center.dy + outerRadius),
      linePaint,
    );

    // Draw the center of the circle
    final centerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repaint only if the color changes
    if (oldDelegate is SoulBlobPainter) {
      return primaryColor != oldDelegate.primaryColor ||
          secondaryColor != oldDelegate.secondaryColor ||
          tertiaryColor != oldDelegate.tertiaryColor ||
          backgroundColor != oldDelegate.backgroundColor;
    }
    return true;
  }
}

// Widget that uses the custom painter
class SoulBlob extends StatelessWidget {
  // Colors
  ComindColors comindColors;

  SoulBlob({
    Key? key,
    required this.comindColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20), // Size of the widget
      painter: SoulBlobPainter(
          primaryColor: comindColors.primaryColor,
          secondaryColor: comindColors.secondaryColor,
          tertiaryColor: comindColors.tertiaryColor,
          backgroundColor: comindColors.colorScheme.background),
    );
  }
}

// A color bar, 2 px tall and 200 px wide. Primary color.
class ColorBar extends StatelessWidget {
  final ComindColors comindColors;
  final ColorChoice colorChoice;
  final double height;

  ColorBar({
    Key? key,
    required this.comindColors,
    this.colorChoice = ColorChoice.primary,
    this.height = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: colorChoice == ColorChoice.primary
          ? comindColors.primaryColor
          : colorChoice == ColorChoice.secondary
              ? comindColors.secondaryColor
              : comindColors.tertiaryColor,
    );
  }
}

// A color block, 200 px wide and 200 px tall. Primary color.
class ColorBlock extends StatelessWidget {
  final ComindColors comindColors;
  final ColorChoice colorChoice;
  final double radius;

  ColorBlock({
    Key? key,
    required this.comindColors,
    this.radius = 200,
    this.colorChoice = ColorChoice.primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Make a circle
    return Container(
      height: radius,
      width: radius,
      decoration: BoxDecoration(
        color: colorChoice == ColorChoice.primary
            ? comindColors.primaryColor
            : colorChoice == ColorChoice.secondary
                ? comindColors.secondaryColor
                : comindColors.tertiaryColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
