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

  @override
  void paint(Canvas canvas, Size size) {
    for (int x = 0; x < size.width; x++) {
      // Rotation should be a score of 1 to 100 for percentage of rotation. It is
      // descaled by the frequency.
      // final rotation = x / size.width * frequency * pi / 90;
      final rotation = (x / size.width) * 3;

      final rotationInThree = rotation % 3;

      // tracks which color we are on.
      int colorIndex = rotationInThree < 1
          ? 1
          : rotationInThree < 2
              ? 2
              : 3;

      // Get amplitude and frequency scalars
      // based on the color we are on.
      var amplitudeScalar = colorIndex == 1
          ? primaryAmplitude
          : colorIndex == 2
              ? secondaryAmplitude
              : tertiaryAmplitude;
      var frequencyScalar = colorIndex == 1
          ? primaryFrequency
          : colorIndex == 2
              ? secondaryFrequency
              : tertiaryFrequency;

      final y = amplitude *
              amplitudeScalar *
              math.sin(((x + startPoint) * frequency * frequencyScalar) *
                  (math.pi / 180)) +
          size.height / 2;

      Color color;

      // This is the interpolation for the first color.
      if (rotationInThree < 1) {
        // Set the color
        color = Color.lerp(primaryColor, secondaryColor, rotationInThree)!;
      }
      // This is the interpolation for the second color.
      else if (rotationInThree < 2) {
        // Set the color
        color = Color.lerp(secondaryColor, tertiaryColor, rotationInThree - 1)!;
      }

      // This is the interpolation for the third color.
      else {
        // Set the color
        color = Color.lerp(tertiaryColor, primaryColor, rotationInThree - 2)!;
      }

      final paint = Paint()
        ..color = color
        // ..color = color.withOpacity((rotationInThree % 1))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      if (x > 0) {
        // Draw the line.
        canvas.drawLine(
            Offset(
                x - 1.0,
                amplitude *
                        amplitudeScalar *
                        math.sin(((startPoint + x - 1) *
                                frequency *
                                frequencyScalar) *
                            (math.pi / 180)) +
                    size.height / 2),
            Offset(x.toDouble(), y),
            paint);
      }
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
      this.tertiaryFrequency = 1})
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
      duration: const Duration(seconds: 20),
      // duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: false);

    // _animation = Tween<double>(begin: 0, end: 0).animate(
    _animation = Tween<double>(begin: 0, end: 3 / 2 * pi).animate(
      CurvedAnimation(
          parent: _controller,
          // curve: Curves.decelerate,
          // curve: Curves.slowMiddle,
          curve: Curves.linear),
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
                // amplitude: log(_animation.value / 50 + 1),
                // frequency: widget.frequency * _animation.value,
                frequency: widget.frequency,
                // frequency: log(widget.frequency * _animation.value + 1),
                amplitude: (360 - _animation.value).abs() * widget.amplitude,
                // amplitude: widget.amplitude,
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
              ),
              child: Container(),
            );
          },
        );
      },
    );
  }
}
