import 'package:comind/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

//
// Widget get ComindLogo {
//   const size = 30.0;
//   return (Row(
//     children: [
//       Text(
//         '{',
//         style: TextStyle(
//           color: Provider.of<ComindColorsNotifier>(context).primaryColor,
//           fontFamily: "Bungee Shade",
//           fontSize: size,
//         ),
//       ),
//       Text(
//         'co',
//         style: TextStyle(
//           color: Provider.of<ComindColorsNotifier>(context).secondaryColor,
//           fontFamily: "Bungee Shade",
//           fontSize: size,
//         ),
//       ),
//       Text(
//         'mind',
//         style: TextStyle(
//           color: Provider.of<ComindColorsNotifier>(context).tertiaryColor,
//           fontFamily: "Bungee Shade",
//           fontSize: size,
//         ),
//       ),
//       Text(
//         '}',
//         style: TextStyle(
//             color: Provider.of<ComindColorsNotifier>(context).primaryColor,
//             fontFamily: "Bungee Shade",
//             fontSize: size),
//       ),
//     ],
//   ));
// }

// The short comind logo
// ignore: must_be_immutable
class ComindShortLogo extends StatelessWidget {
  const ComindShortLogo({
    Key? key,
    required this.colors,
  }) : super(key: key);

  // Add a main axis alignment property, default to center
  static const MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center;
  final ComindColorsNotifier colors;

  @override
  Widget build(BuildContext context) {
    const size = 68.0;
    return (Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Text(
          '{',
          style: TextStyle(
            color: colors.currentColors.primaryColor,
            fontFamily: "Bungee",
            fontSize: size,
          ),
        ),
        Text(
          'c',
          style: TextStyle(
            color: colors.currentColors.secondaryColor,
            fontFamily: "bunpop",
            fontSize: size,
          ),
        ),
        Text(
          'o',
          style: TextStyle(
            color: colors.currentColors.tertiaryColor,
            fontFamily: "bunpop",
            fontSize: size,
          ),
        ),
        Text(
          '}',
          style: TextStyle(
              color: colors.currentColors.primaryColor,
              fontFamily: "bunpop",
              fontSize: size),
        ),
      ],
    ));
  }
}

// The comind logo
class ComindLogo extends StatelessWidget {
  const ComindLogo({
    Key? key,
    required this.colors,
  }) : super(key: key);

  // Add a main axis alignment property, default to center
  static const MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center;
  final ComindColorsNotifier colors;

  // This function is used when the logo is hovered.
  // When hovered, secondary=primary, tertiary=secondary, primary=tertiary
  // This is a simple color shift.
  void shiftColors(ComindColorsNotifier colors) {
    return colors.currentColors.setColors(
      colors.currentColors.secondaryColor,
      colors.currentColors.tertiaryColor,
      colors.currentColors.primaryColor,
    );
  }

  // Build the widget
  @override
  Widget build(BuildContext context) {
    const size = 68.0;
    return (Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        ////////////////////
        // Modern take on the logo
        ////////////////////
        // Long version
        // Text(
        //   '∙',
        //   style: TextStyle(
        //     decorationThickness: 2,
        //     decoration: TextDecoration.underline,
        //     decorationColor: Provider.of<ComindColorsNotifier>(context).primaryColor,
        //     fontFamily: "Bungee",
        //     fontSize: size,
        //   ),
        // ),
        // Text(
        //   'co',
        //   style: TextStyle(
        //     decorationThickness: 2,
        //     decoration: TextDecoration.underline,
        //     decorationColor: Provider.of<ComindColorsNotifier>(context).secondaryColor,
        //     fontFamily: "Bungee",
        //     fontSize: size,
        //   ),
        // ),
        // Text(
        //   'mind',
        //   style: TextStyle(
        //     decorationThickness: 2,
        //     decoration: TextDecoration.underline,
        //     decorationColor: Provider.of<ComindColorsNotifier>(context).tertiaryColor,
        //     fontFamily: "Bungee",
        //     fontSize: size,
        //   ),
        // ),
        // Text(
        //   '∙',
        //   style: TextStyle(
        //       decoration: TextDecoration.underline,
        //       decorationThickness: 2,
        //       decorationColor: Provider.of<ComindColorsNotifier>(context).primaryColor,
        //       fontFamily: "Bungee",
        //       fontSize: size),
        // ),

        // Short version
        // Text(
        //   '∙',
        //   style: TextStyle(
        //     decorationThickness: 2,
        //     decoration: TextDecoration.underline,
        //     decorationColor: Provider.of<ComindColorsNotifier>(context).primaryColor,
        //     fontFamily: "Bungee",
        //     fontSize: size,
        //   ),
        // ),
        // Text(
        //   'c',
        //   style: TextStyle(
        //     decorationThickness: 2,
        //     decoration: TextDecoration.underline,
        //     decorationColor: Provider.of<ComindColorsNotifier>(context).secondaryColor,
        //     fontFamily: "Bungee",
        //     fontSize: size,
        //   ),
        // ),
        // Text(
        //   'o',
        //   style: TextStyle(
        //     decorationThickness: 2,
        //     decoration: TextDecoration.underline,
        //     decorationColor: Provider.of<ComindColorsNotifier>(context).tertiaryColor,
        //     fontFamily: "Bungee",
        //     fontSize: size,
        //   ),
        // ),
        // Text(
        //   '∙',
        //   style: TextStyle(
        //       decoration: TextDecoration.underline,
        //       decorationThickness: 2,
        //       decorationColor: Provider.of<ComindColorsNotifier>(context).primaryColor,
        //       fontFamily: "Bungee",
        //       fontSize: size),
        // ),

        ////////////////////
        /// Original logo
        /// //////////////////
        Text(
          '{',
          style: TextStyle(
            // decorationThickness: 2,
            // decoration: TextDecoration.underline,
            color: colors.currentColors.primaryColor,
            fontFamily: "bunpop",
            fontSize: size,
          ),
        ),
        Text(
          'co',
          style: TextStyle(
            // decorationThickness: 2,
            // decoration: TextDecoration.underline,
            color: colors.currentColors.secondaryColor,
            fontFamily: "bunpop",
            fontSize: size,
          ),
        ),
        Text(
          'mind',
          style: TextStyle(
            // decorationThickness: 2,
            // decoration: TextDecoration.underline,
            color: colors.currentColors.tertiaryColor,
            fontFamily: "bunpop",
            fontSize: size,
          ),
        ),
        Text(
          '}',
          style: TextStyle(
              // decoration: TextDecoration.underline,
              // decorationThickness: 2,

              color: colors.currentColors.primaryColor,
              fontFamily: "bunpop",
              fontSize: size),
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
  static const double moveRange = 30.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween(begin: -moveRange, end: moveRange).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut,
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
              var textStyle = TextStyle(
                fontSize: size,
                fontFamily: "bunpop",
                color: Provider.of<ComindColorsNotifier>(context)
                    .currentColors
                    .primaryColor,
              );
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(_animation.value - 20, 0),
                    child: Text('{',
                        style: textStyle.copyWith(
                          color: Provider.of<ComindColorsNotifier>(context)
                              .currentColors
                              .primaryColor,
                        )),
                  ),
                  // Add space between the two characters
                  const SizedBox(width: 4),
                  Text(
                    'O',
                    style: textStyle.copyWith(
                      color: Provider.of<ComindColorsNotifier>(context)
                          .currentColors
                          .secondaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Transform.translate(
                      offset: Offset(-_animation.value + 20, 0),
                      child: Text(
                        '}',
                        style: textStyle.copyWith(
                          color: Provider.of<ComindColorsNotifier>(context)
                              .currentColors
                              .tertiaryColor,
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
