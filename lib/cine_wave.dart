import 'dart:math' as math;
import 'dart:math';
import 'package:comind/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CineWavePainter extends CustomPainter {
  final double amplitude;
  final double frequency;
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;
  final double startPoint;

  // Fields to track amplitude and frequency for each color.
  final double primaryAmplitude;
  final double primaryFrequency;
  final double secondaryAmplitude;
  final double secondaryFrequency;
  final double tertiaryAmplitude;
  final double tertiaryFrequency;
  final bool goLeft;

  CineWavePainter({
    required this.amplitude,
    required this.frequency,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
    this.primaryAmplitude = 1,
    this.primaryFrequency = 1,
    this.secondaryAmplitude = 1,
    this.secondaryFrequency = 1,
    this.tertiaryAmplitude = 1,
    this.tertiaryFrequency = 1,
    this.startPoint = 0,
    this.goLeft = false,
  });

  double f(x, {double amplitude = 1, double frequency = 1}) {
    return amplitude * math.sin((x + startPoint) * frequency * (math.pi));
    // return x;
  }

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

// Simpler paint method
  @override
  void paint(Canvas canvas, Size size) {
    for (int x = 0; x < size.width; x++) {
      // A convergence parameter. This is the fraction [0,1]
      // that determines how much of the underlying
      // sine wave is visible -- at 1, the entire wave is visible
      // (in the center of the canvas) and at 0, the wave is
      // collapsed to a single point.
      //
      // at x=1, convergence is 0
      // at x=0, convergence is 0
      // at x=0.5, convergence is 1
      //
      // var convergence = 1 - (x / size.width - 0.5).abs() * 2;

      // Alternate convergence parameter. This is 0 at the outside edge
      // and 1 at the inside edge.
      // var convergence = (x / size.width - (goLeft ? 1 : 0)).abs();

      // Alternate convergence parameter. This is 1 at the outside edge
      // and 0 at the inside edge.
      var convergence = 1 - (x / size.width - (goLeft ? 0 : 1)).abs();

      // No convergence parameter. This is 1 everywhere.
      // var convergence = 1;

      // The base opacity
      var a = 1;

      // var opacity = sqrt(a * convergence);
      var opacity = pow(a * convergence, 1).toDouble();

      // Set the stroke width
      const double stroke = 2;

      var paint1 = Paint()
        ..color = secondaryColor.withOpacity(opacity)
        ..strokeWidth = stroke;

      var paint2 = Paint()
        ..color = tertiaryColor.withOpacity(opacity)
        ..strokeWidth = stroke;

      var paint3 = Paint()
        ..color = primaryColor.withOpacity(opacity)
        ..strokeWidth = stroke;

      const double baseAmp = 4;
      const double baseFreq = 0.01 * pi; // Debug
      // const double baseFreq = 18;

      const double shift1 = 0;
      const double amp1 = baseAmp;
      const double freq1 = baseFreq;

      const double shift2 = 0;
      const double amp2 = baseAmp;
      const double freq2 = baseFreq;

      const double shift3 = 0;
      const double amp3 = baseAmp;
      const double freq3 = baseFreq;

      // Line 1
      var startPoint1 = Offset(
          x - 1,
          f(x + shift1 - 1, amplitude: amp1 * convergence, frequency: freq1)
                      .toDouble() *
                  convergence -
              5);
      var endPoint1 = Offset(
          x - 0,
          f(x + shift1, amplitude: amp1 * convergence, frequency: freq1)
                      .toDouble() *
                  convergence -
              5);

      // Line 2
      var startPoint2 = Offset(
          x - 1,
          f(x - 1 + shift2, amplitude: amp2, frequency: freq2).toDouble() *
                  convergence +
              5);
      var endPoint2 = Offset(
          x.toDouble(),
          f(x + shift2, amplitude: amp2, frequency: freq2).toDouble() *
                  convergence +
              5);

      // Line 3
      var startPoint3 = Offset(
          x - 1,
          f(x - 1 + shift3, amplitude: amp3, frequency: freq3).toDouble() *
              convergence);
      var endPoint3 = Offset(
          x.toDouble(),
          f(x + shift3, amplitude: amp3, frequency: freq3).toDouble() *
              convergence);

      // All lines should converge at the same point on the left and right.

      // Draw the line.
      canvas.drawLine(startPoint1, endPoint1, paint1);
      canvas.drawLine(startPoint2, endPoint2, paint2);
      canvas.drawLine(startPoint3, endPoint3, paint3);

      // if (x > 0) {
      //   // Draw the line.
      //   canvas.drawLine(Offset((x - 1).toDouble(), f((x - 1).toDouble())),
      //       Offset(x.toDouble(), y), paintA);

      //   // Draw a second sine wave
      //   // canvas.drawLine(Offset((x - 1).toDouble(), f((x - 1).toDouble()) * 2),
      //   //     Offset(x.toDouble(), y), paintB);
      // }
    }
  }
}

class CineWave extends StatefulWidget {
  // Setting up types for amplitude and frequency.
  final double amplitude;
  final double frequency;

  // Scalars to use for amplitude and frequency.
  // These are used to scale the amplitude and frequency
  // for each color.
  final double primaryAmplitude;
  final double primaryFrequency;
  final double secondaryAmplitude;
  final double secondaryFrequency;
  final double tertiaryAmplitude;
  final double tertiaryFrequency;

  // This is the direction the wave will go.
  final bool goLeft;

  const CineWave(
      {super.key,
      this.amplitude = 0,
      this.frequency = 0

      // Scalars to use for amplitude and frequency.
      // These are used to scale the amplitude and frequency
      // for each color.
      ,
      this.primaryAmplitude = 1,
      this.primaryFrequency = 1,
      this.secondaryAmplitude = 1,
      this.secondaryFrequency = 1,
      this.tertiaryAmplitude = 1,
      this.tertiaryFrequency = 1,
      this.goLeft = false})
      : super();

  @override
  // ignore: library_private_types_in_public_api
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
      duration: const Duration(seconds: 8),
      // duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: false);

    // _animation = Tween<double>(begin: 0, end: 0).animate(
    if (widget.goLeft) {
      _animation = Tween<double>(begin: 0, end: 10 * pi).animate(
        CurvedAnimation(
            parent: _controller,
            // curve: Curves.easeInOutCubicEmphasized,
            // curve: Curves.slowMiddle,
            // curve: Curves.bounceInOut
            // curve: Curves.easeInOut
            curve: Curves.linear
            //
            ),
      );
    } else {
      _animation = Tween<double>(begin: 10 * pi, end: 0).animate(
        CurvedAnimation(
            parent: _controller,
            // curve: Curves.easeInOutCubicEmphasized,
            // curve: Curves.slowMiddle,
            // curve: Curves.easeInOut
            // curve: Curves.bounceInOut
            curve: Curves.linear
            //
            ),
      );
    }
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
                // amplitude: log(_animation.value / 50 + 1),
                // frequency: widget.frequency /
                //         10 *
                //         (3 / 2 * pi - _animation.value).abs() +
                //     1,
                frequency: 1,
                // frequency: widget.frequency,
                // frequency: log(widget.frequency * _animation.value + 1),
                // amplitude: (_animation.value - 3 / 4 * pi).abs() *
                //     widget.amplitude *
                //     50,
                amplitude: 1,
                startPoint: _animation.value * 4,
                // startPoint: 0,
                primaryColor: colorNotifier.currentColors.primaryColor,
                secondaryColor: colorNotifier.currentColors.secondaryColor,
                tertiaryColor: colorNotifier.currentColors.tertiaryColor,
                primaryAmplitude: widget.primaryAmplitude,
                primaryFrequency: widget.primaryFrequency,
                secondaryAmplitude: widget.secondaryAmplitude,
                secondaryFrequency: widget.secondaryFrequency,
                tertiaryAmplitude: widget.tertiaryAmplitude,
                tertiaryFrequency: widget.tertiaryFrequency,

                goLeft: widget.goLeft,
              ),
              child: Container(),
            );
          },
        );
      },
    );
  }
}
