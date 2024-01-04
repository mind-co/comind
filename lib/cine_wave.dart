import 'dart:math' as math;
import 'dart:math';
import 'package:comind/colors.dart';
import 'package:comind/misc/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CineWavePainter extends CustomPainter {
  final double amplitude;
  final double frequency;
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;
  final double startPoint;

  CineWavePainter({
    required this.amplitude,
    required this.frequency,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
    this.startPoint = 0,
  });

  @override
  bool shouldRepaint(CineWavePainter oldDelegate) {
    // Return true if the start point has changed, the frequency has changed,
    // or the amplitude has changed.
    if (oldDelegate.startPoint != startPoint) {
      return true;
    } else if (oldDelegate.frequency != frequency) {
      return true;
    } else if (oldDelegate.amplitude != amplitude) {
      return true;
    } else {
      return false;
    }
  }

  static const double _interpLocation = 0.9;
  @override
  void paint(Canvas canvas, Size size) {
    // primaryColor: Provider.of<ComindColorsNotifier>(context)
    //         .currentColors
    //         .primaryColor,
    //     secondaryColor: Provider.of<ComindColorsNotifier>(context)
    //         .currentColors
    //         .secondaryColor,
    //     tertiaryColor: Provider.of<ComindColorsNotifier>(context)
    //         .currentColors
    //         .tertiaryColor,
    for (int x = 0; x < size.width; x++) {
      final y = amplitude *
              math.sin(((x + startPoint) * frequency) * (math.pi / 180)) +
          size.height / 2;

      final rotation = x * frequency / 360;
      final rotationInThree = rotation % 3;

      Color color;
      if (rotationInThree < 1) {
        // Only interpolate when rotation is > 0.9.
        // Between 0.9 and 1, interpolate quickly.
        // Between 0 and 0.9, do not interpolate.
        final double rotationInThreeInterpolated = rotationInThree >
                _interpLocation
            ? min(1, (rotationInThree - _interpLocation)) * 1 / _interpLocation
            : 0;
        color = Color.lerp(
            primaryColor, secondaryColor, rotationInThreeInterpolated)!;
      } else if (rotationInThree < 2) {
        final double rotationInThreeInterpolated =
            rotationInThree > (1 + _interpLocation)
                ? min(1, (rotationInThree - (1 + _interpLocation))) *
                    1 /
                    _interpLocation
                : 0;
        color = Color.lerp(
            secondaryColor, tertiaryColor, rotationInThreeInterpolated)!;
      } else {
        final double rotationInThreeInterpolated =
            rotationInThree > (2 + _interpLocation)
                ? min(1, (rotationInThree - (2 + _interpLocation))) *
                    1 /
                    _interpLocation
                : 0;
        color = Color.lerp(
            tertiaryColor, primaryColor, rotationInThreeInterpolated)!;
      }

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      if (x > 0) {
        canvas.drawLine(
            Offset(
                x - 1.0,
                amplitude *
                        math.sin(((startPoint + x - 1) * frequency) *
                            (math.pi / 180)) +
                    size.height / 2),
            Offset(x.toDouble(), y),
            paint);
      }
    }
  }
}

class CineWave extends StatefulWidget {
  @override
  _CineWaveState createState() => _CineWaveState();
}

class _CineWaveState extends State<CineWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 0).animate(
      // _animation = Tween<double>(begin: 0, end: 3 * pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // This is the easing curve
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ComindColorsNotifier>(
      builder: (context, colorNotifier, child) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: CineWavePainter(
                // amplitude: 0,
                // amplitude: _animation.value / 9,
                amplitude: max(log(_animation.value * 10), 2),
                // frequency: 4 * pi,
                // frequency: log(_animation.value * 2),
                // frequency: pi / 2,
                frequency: _animation.value / 3,
                startPoint: _animation.value,
                primaryColor: colorNotifier.currentColors.primaryColor,
                secondaryColor: colorNotifier.currentColors.secondaryColor,
                tertiaryColor: colorNotifier.currentColors.tertiaryColor,
              ),
              child: Container(),
            );
          },
        );
      },
    );
  }
}
