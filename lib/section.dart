import 'package:comind/cine_wave.dart';
import 'package:comind/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Section extends StatefulWidget {
  Section({
    Key? key,
    required this.text,
    required this.children,
    this.style,
    this.waves = true,
    this.expanded = true,
  }) : super(key: key);

  final String text;
  final List<Widget> children;
  final TextStyle? style;
  final bool waves;
  bool expanded;

  @override
  State<StatefulWidget> createState() => _SectionState();
}

class _SectionState extends State<Section> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // section header
      Material(
          child: InkWell(
              onTap: () {
                setState(() {
                  widget.expanded = !widget.expanded;
                });
              },
              child: SectionHeader(
                  text: widget.text,
                  style: widget.style,
                  waves: widget.waves))),

      // section body
      Visibility(
          visible: widget.expanded,
          child: Column(
            children: widget.children,
          )),
    ]);
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.text,
    this.style,
    this.waves = true,
  });

  final String text;
  final TextStyle? style;
  final bool waves;

  @override
  Widget build(BuildContext context) {
    const outsidePadding = 8.0;
    const insidePadding = 0.0;
    const cineEdgeInsetsLeft =
        EdgeInsets.fromLTRB(outsidePadding, 0, insidePadding, 0);
    const cineEdgeInsetsRight =
        EdgeInsets.fromLTRB(insidePadding, 0, outsidePadding, 0);

    // CineWave shape parameters
    const double waveAmplitude = 3.0;
    const double waveFrequency = 10;

    // Render
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (waves)
        const Expanded(
            child: Padding(
          padding: cineEdgeInsetsLeft,
          child: CineWave(
            amplitude: waveAmplitude,
            frequency: waveFrequency,
          ),
        )),
      Flexible(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            style: style ??
                Provider.of<ComindColorsNotifier>(context)
                    .currentColors
                    .textTheme
                    .titleLarge,
          ),
        ),
      ),
      if (waves)
        const Expanded(
            child: Padding(
          padding: cineEdgeInsetsRight,
          child: CineWave(
            amplitude: waveAmplitude,
            frequency: waveFrequency,
            goLeft: true,
          ),
        )),
    ]);
  }
}
