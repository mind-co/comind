import 'package:flutter/material.dart';
import 'package:comind/colors.dart';

class ComindDiv extends StatelessWidget {
  const ComindDiv({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          color: ComindColors.primaryColor,
          height: 2.0,
          // Occupy 1/3 of the screen
          width: MediaQuery.of(context).size.width / 3,
        ),
        Container(
          color: ComindColors.secondaryColor,
          height: 2.0,
          // Occupy 1/3 of the screen
          width: MediaQuery.of(context).size.width / 3,
        ),
        Container(
          color: ComindColors.tertiaryColor,
          height: 2.0,
          // Occupy 1/3 of the screen
          width: MediaQuery.of(context).size.width / 3,
        ),
      ],
    );
  }
}
