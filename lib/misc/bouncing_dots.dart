import 'package:comind/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BouncingDotsWidget extends StatefulWidget {
  @override
  _BouncingDotsWidgetState createState() => _BouncingDotsWidgetState();
}

class _BouncingDotsWidgetState extends State<BouncingDotsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dot1Animation;
  late Animation<double> _dot2Animation;
  late Animation<double> _dot3Animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    const curve = Curves.bounceOut;

    _dot1Animation = Tween<double>(begin: 0, end: 50).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.8, curve: curve),
      ),
    );

    _dot2Animation = Tween<double>(begin: 0, end: 50).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1, curve: curve),
      ),
    );

    _dot3Animation = Tween<double>(begin: 0, end: 50).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1, curve: curve),
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Style
    const style = TextStyle(fontSize: 78, fontFamily: "bunpop");

    // Build the widget
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -75 + _dot1Animation.value),
              child: child,
            );
          },
          child: Text('.',
              style: style.copyWith(
                  color: Provider.of<ComindColorsNotifier>(context).primary)),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -75 + _dot2Animation.value),
              child: child,
            );
          },
          child: Text(
            ' . ',
            style: style.copyWith(
                color: Provider.of<ComindColorsNotifier>(context).secondary),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -75 + _dot3Animation.value),
              child: child,
            );
          },
          child: Text(
            '.',
            style: style.copyWith(
                color: Provider.of<ComindColorsNotifier>(context).tertiary),
          ),
        ),
      ],
    );
  }
}
