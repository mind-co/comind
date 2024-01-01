// An animated "loading" widget using bungee font.
// Letters are animated to bounce up and down.
//
// Path: lib/misc/loading.dart

import 'package:comind/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Loading extends StatefulWidget {
  final String text;
  final double fontSize;

  const Loading({
    Key? key,
    this.text = 'thing',
    this.fontSize = 24.0,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    // Initialize the animation
    _animation = Tween<double>(begin: 0, end: 10).animate(_controller);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Hey there. We're still loading that\n",
                  style: Provider.of<ComindColorsNotifier>(context)
                      .textTheme
                      .bodyLarge),
              Text('${widget.text}',
                  style: Provider.of<ComindColorsNotifier>(context)
                      .textTheme
                      .displaySmall),
              Text("\nFor you.",
                  style: Provider.of<ComindColorsNotifier>(context)
                      .textTheme
                      .bodyLarge),
            ],
          );
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
