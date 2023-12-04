import 'package:flutter/material.dart';
import 'package:comind/colors.dart';

// Colored bar that is n pixes high but alternates between the three colors.
class ComindDiv extends StatefulWidget {
  const ComindDiv({Key? key}) : super(key: key);

  @override
  _ComindDivState createState() => _ComindDivState();
}

class _ComindDivState extends State<ComindDiv>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;

  // Dont' like how they lok with separate animations
  // late Animation<double> _animation2;
  // late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation1 = Tween<double>(begin: 2, end: 20).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
        // curve: const Interval(0.0, 0.33),
      ),
    );

    // _animation2 = Tween<double>(begin: 2, end: 4).animate(
    //   CurvedAnimation(
    //     parent: _controller,
    //     curve: const Interval(0.33, 0.66),
    //   ),
    // );

    // _animation3 = Tween<double>(begin: 2, end: 4).animate(
    //   CurvedAnimation(
    //     parent: _controller,
    //     curve: const Interval(0.66, 1.0),
    //   ),
    // );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 3,
                height: _animation1.value,
                color: ComindColors.primaryColor,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 3,
                height: _animation1.value,
                color: ComindColors.secondaryColor,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 3,
                height: _animation1.value,
                color: ComindColors.tertiaryColor,
              ),
            ],
          );
        },
      ),
    );
  }
}
