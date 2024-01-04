import 'package:flutter/material.dart';
import 'package:comind/colors.dart';
import 'package:provider/provider.dart';

//
class ComindDiv extends StatelessWidget {
  const ComindDiv({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Container(
                color: Provider.of<ComindColorsNotifier>(context)
                    .currentColors
                    .primaryColor)),
        Expanded(
            child: Container(
                color: Provider.of<ComindColorsNotifier>(context)
                    .currentColors
                    .secondaryColor)),
        Expanded(
            child: Container(
                color: Provider.of<ComindColorsNotifier>(context)
                    .currentColors
                    .tertiaryColor)),
      ],
    );
  }
}

// // Colored bar that is n pixes high but alternates between the three colors.
// class ComindDiv extends StatefulWidget {
//   const ComindDiv({Key? key}) : super(key: key);

//   @override
//   _ComindDivState createState() => _ComindDivState();
// }

// class _ComindDivState extends State<ComindDiv>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation1;

//   // Dont' like how they lok with separate animations
//   // late Animation<double> _animation2;
//   // late Animation<double> _animation3;

//   @override
//   void initState() {
//     super.initState();

//     // _animation2 = Tween<double>(begin: 2, end: 4).animate(
//     //   CurvedAnimation(
//     //     parent: _controller,
//     //     curve: const Interval(0.33, 0.66),
//     //   ),
//     // );

//     // _animation3 = Tween<double>(begin: 2, end: 4).animate(
//     //   CurvedAnimation(
//     //     parent: _controller,
//     //     curve: const Interval(0.66, 1.0),
//     //   ),
//     // );

//     _controller.repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: Container(
//             height: _animation1.value,
//             color: Provider.of<ComindColorsNotifier>(context)
//                 .currentColors
//                 .primaryColor,
//           ),
//         ),
//         Expanded(
//           child: Container(
//             height: _animation1.value,
//             color: Provider.of<ComindColorsNotifier>(context)
//                 .currentColors
//                 .secondaryColor,
//           ),
//         ),
//         Expanded(
//           child: Container(
//             height: _animation1.value,
//             color: Provider.of<ComindColorsNotifier>(context)
//                 .currentColors
//                 .tertiaryColor,
//           ),
//         ),
//       ],
//     );
//   }
// }
