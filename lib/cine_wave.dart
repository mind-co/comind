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
    return amplitude *
        math.sin((x + startPoint) * frequency * 1 * (math.pi / 180));
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

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (int x = 0; x < size.width; x++) {
//       // Rotation should be a score of 1 to 100 for percentage of rotation. It is
//       // descaled by the frequency.
//       // final rotation = x / size.width * frequency * pi / 90;
//       final rotation = (x / size.width) * 3;

//       final rotationInThree = rotation % 3;

//       // tracks which color we are on.
//       int colorIndex = rotationInThree < 1
//           ? 1
//           : rotationInThree < 2
//               ? 2
//               : 3;

//       // Get amplitude and frequency scalars
//       // based on the color we are on.
//       var amplitudeScalar = colorIndex == 1
//           ? primaryAmplitude
//           : colorIndex == 2
//               ? secondaryAmplitude
//               : tertiaryAmplitude;
//       var frequencyScalar = colorIndex == 1
//           ? primaryFrequency
//           : colorIndex == 2
//               ? secondaryFrequency
//               : tertiaryFrequency;

//       final y = f(x.toDouble()) * size.height;

//       Color color;

//       // This is the interpolation for the first color.
//       if (rotationInThree < 1) {
//         // Set the color
//         color = Color.lerp(primaryColor, secondaryColor, rotationInThree)!;
//       }
//       // This is the interpolation for the second color.
//       else if (rotationInThree < 2) {
//         // Set the color
//         color = Color.lerp(secondaryColor, tertiaryColor, rotationInThree - 1)!;
//       }

//       // This is the interpolation for the third color.
//       else {
//         // Set the color
//         color = Color.lerp(tertiaryColor, primaryColor, rotationInThree - 2)!;
//       }

//       final paint = Paint()
//         ..color = color
//         // ..color = color.withOpacity((rotationInThree % 1))
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 20;

//       if (x > 0) {
//         // Draw the line.
//         canvas.drawLine(Offset((x - 1).toDouble(), f((x - 1).toDouble())),
//             Offset(x.toDouble(), y), paint);
//       }
//     }
//   }
// }

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

      // The base opacity
      var a = 1;

      // var opacity = sqrt(a * convergence);
      var opacity = pow(a * convergence, 1).toDouble();
      const double stroke = 2;

      var paint1 = Paint()
        ..color = primaryColor.withOpacity(opacity)
        ..strokeWidth = stroke * 1.8;

      var paint2 = Paint()
        ..color = secondaryColor.withOpacity(opacity)
        ..strokeWidth = stroke * 1.3;

      var paint3 = Paint()
        ..color = tertiaryColor.withOpacity(opacity)
        ..strokeWidth = stroke;

      const double shift1 = 0;
      const double amp1 = 4;
      const double freq1 = 3.4;

      const double shift2 = 0;
      const double amp2 = 6;
      const double freq2 = 3.8;

      const double shift3 = 10;
      const double amp3 = 4;
      const double freq3 = 8;

      var startPoint1 = Offset(
          x - 1,
          f(x + shift1 - 1, amplitude: amp1 * convergence, frequency: freq1)
                  .toDouble() *
              convergence);
      var endPoint1 = Offset(
          x - 0,
          f(x + shift1, amplitude: amp1 * convergence, frequency: freq1)
                  .toDouble() *
              convergence);

      var startPoint2 = Offset(
          x - 1,
          f(x - 1 + shift2, amplitude: amp2, frequency: freq2).toDouble() *
              convergence);
      var endPoint2 = Offset(
          x.toDouble(),
          f(x + shift2, amplitude: amp2, frequency: freq2).toDouble() *
              convergence);
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

  CineWave(
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
      duration: const Duration(seconds: 30),
      // duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    // _animation = Tween<double>(begin: 0, end: 0).animate(
    if (widget.goLeft) {
      _animation = Tween<double>(begin: 0, end: 3 / 2 * pi).animate(
        CurvedAnimation(
            parent: _controller,
            // curve: Curves.easeInOutCubicEmphasized,
            // curve: Curves.slowMiddle,
            curve: Curves.easeInOut
            //
            ),
      );
    } else {
      _animation = Tween<double>(begin: 3 / 2 * pi, end: 0).animate(
        CurvedAnimation(
            parent: _controller,
            // curve: Curves.easeInOutCubicEmphasized,
            // curve: Curves.slowMiddle,
            curve: Curves.easeInOut

            // curve: Curves.linear
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
                frequency: widget.frequency,
                // frequency: log(widget.frequency * _animation.value + 1),
                // amplitude: (_animation.value - 3 / 4 * pi).abs() *
                //     widget.amplitude *
                //     50,
                amplitude: widget.amplitude,
                startPoint: _animation.value * 100,
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
