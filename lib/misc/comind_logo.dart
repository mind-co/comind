import 'package:comind/colors.dart';
import 'package:flutter/material.dart';

//
// Widget get ComindLogo {
//   const size = 30.0;
//   return (Row(
//     children: [
//       Text(
//         '{',
//         style: TextStyle(
//           color: ComindColors.primaryColor,
//           fontFamily: "Bungee Shade",
//           fontSize: size,
//         ),
//       ),
//       Text(
//         'co',
//         style: TextStyle(
//           color: ComindColors.secondaryColor,
//           fontFamily: "Bungee Shade",
//           fontSize: size,
//         ),
//       ),
//       Text(
//         'mind',
//         style: TextStyle(
//           color: ComindColors.tertiaryColor,
//           fontFamily: "Bungee Shade",
//           fontSize: size,
//         ),
//       ),
//       Text(
//         '}',
//         style: TextStyle(
//             color: ComindColors.primaryColor,
//             fontFamily: "Bungee Shade",
//             fontSize: size),
//       ),
//     ],
//   ));
// }

// The above but as a class
class ComindLogo extends StatelessWidget {
  const ComindLogo({Key? key}) : super(key: key);

  // Add a main axis alignment property, default to center
  static const MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center;

  @override
  Widget build(BuildContext context) {
    const size = 42.0;
    return (const Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Text(
          '{',
          style: TextStyle(
            color: ComindColors.primaryColor,
            fontFamily: "Bungee Shade",
            fontSize: size,
          ),
        ),
        Text(
          'co',
          style: TextStyle(
            color: ComindColors.secondaryColor,
            fontFamily: "Bungee Shade",
            fontSize: size,
          ),
        ),
        Text(
          'mind',
          style: TextStyle(
            color: ComindColors.tertiaryColor,
            fontFamily: "Bungee Shade",
            fontSize: size,
          ),
        ),
        Text(
          '}',
          style: TextStyle(
              color: ComindColors.primaryColor,
              fontFamily: "Bungee Shade",
              fontSize: size),
        ),
      ],
    ));
  }
}

// The above but as a class
class ComindHeader extends StatelessWidget {
  // Allow arbitrary text
  final String text;

  const ComindHeader({Key? key, required this.text}) : super(key: key);

  // Add a main axis alignment property, default to center
  final MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center;

  @override
  Widget build(BuildContext context) {
    const size = 34.0;
    return (Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Text(
          text,
          style: const TextStyle(
            color: ComindColors.primaryColor,
            fontFamily: "Bungee Shade",
            fontSize: size,
          ),
        ),
      ],
    ));
  }
}

class ComindIsLoading extends StatefulWidget {
  const ComindIsLoading({
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ComindIsLoadingState createState() => _ComindIsLoadingState();
}

class _ComindIsLoadingState extends State<ComindIsLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  static const size = 84.0;
  static const double moveRange = 5.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween(begin: -moveRange, end: moveRange).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Hey pal.",
          ),
          const ComindLineSpacer(),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(_animation.value, 0),
                    child: const Text(
                      '{',
                      style: TextStyle(
                        fontSize: size,
                        fontFamily: "Bungee Pop",
                        fontWeight: FontWeight.normal,
                        color: ComindColors.primaryColor,
                      ),
                    ),
                  ),
                  // Add space between the two characters
                  const SizedBox(width: 4),
                  const Text(
                    'O',
                    style: TextStyle(
                      fontSize: size,
                      fontFamily: "Bungee Pop",
                      fontWeight: FontWeight.normal,
                      color: ComindColors.secondaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Transform.translate(
                      offset: Offset(-_animation.value, 0),
                      child: const Text(
                        '}',
                        style: TextStyle(
                          fontSize: size,
                          fontFamily: "Bungee Pop",
                          fontWeight: FontWeight.normal,
                          color: ComindColors.tertiaryColor,
                        ),
                      ))
                ],
              );
            },
          ),
          // Add spacing between the two texts
          const ComindLineSpacer(),
          const Text("We're still thinkin' about stuff."),
          const ComindLineSpacer(),
          const Text(" Give us a sec."),
        ],
      ),
    );
  }
}

// Add a line spacer, just a divider of height 16.
// This basically separates lines of text,
// and is used to enforce consistency across copy.
class ComindLineSpacer extends StatelessWidget {
  const ComindLineSpacer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 16,
      thickness: 0,
      color: Colors.transparent,
    );
  }
}
