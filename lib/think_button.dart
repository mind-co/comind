// The "think" button is a text widget with the text think
// and a callback to the think() function.

import 'package:comind/providers.dart';
import 'package:comind/text_button_simple.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'colors.dart';

// Version with icon
class ThinkButton extends StatefulWidget {
  const ThinkButton({Key? key, required this.icon, this.onPressed})
      : super(key: key);

  final VoidCallback? onPressed;
  final IconData icon;

  @override
  // ignore: library_private_types_in_public_api
  _ThinkButtonState createState() => _ThinkButtonState();
}

class _ThinkButtonState extends State<ThinkButton> {
  @override
  Widget build(BuildContext context) {
    // Listener for public mode

    return Stack(
      children: [
        IconButton(
          style: ButtonStyle(
            // backgroundColor: MaterialStateProperty.all<Color>(
            //     Provider.of<ComindColorsNotifier>(context)
            //         .colorScheme
            //         .primary),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            fixedSize: MaterialStateProperty.all<Size>(const Size(45, 45)),
          ),
          hoverColor:
              Provider.of<ComindColorsNotifier>(context).colorScheme.primary,
          enableFeedback: true,
          onPressed: widget.onPressed,
          icon: Icon(
            widget.icon,
            color: Provider.of<ComindColorsNotifier>(context).onPrimary,
            size: 24,
          ),
          iconSize: 24,
        ),
      ],
    );
  }
}

// Version with text
// class ThinkButton extends StatefulWidget {
//   const ThinkButton({Key? key, this.onPressed}) : super(key: key);

//   final VoidCallback? onPressed;

//   @override
//   _ThinkButtonState createState() => _ThinkButtonState();
// }

// class _ThinkButtonState extends State<ThinkButton> {
//   @override
//   Widget build(BuildContext context) {
//     // return Stack(
//     //   children: [
//     //     Padding(
//     //       padding: const EdgeInsets.fromLTRB(0, 3, 3, 3),
//     //       child: TextButtonSimple(
//     //         text: 'Think',
//     //         onPressed: widget.onPressed!,
//     //         colorChoice: ColorChoice.primary,
//     //       ),
//     //     ),
//     //   ],
//     // );

//     return TextButtonSimple(
//       text: 'Think',
//       isHighlighted: true,
//       onPressed: widget.onPressed!,
//       colorChoice: ColorChoice.primary,
//     );
//   }
// }

// class ThinkButton extends StatelessWidget {
//   const ThinkButton({Key? key, this.onPressed}) : super(key: key);

//   final VoidCallback? onPressed;

//   @override
//   Widget build(BuildContext context) {
//     // Listener for public mode

//     return Stack(
//       children: [
//         IconButton(
//           style: ButtonStyle(
//             // backgroundColor: MaterialStateProperty.all<Color>(
//             //     Provider.of<ComindColorsNotifier>(context)
//             //         .colorScheme
//             //         .primary),
//             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//               RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(5.0),
//               ),
//             ),
//             fixedSize: MaterialStateProperty.all<Size>(Size(45, 45)),
//           ),
//           hoverColor:
//               Provider.of<ComindColorsNotifier>(context).colorScheme.primary,
//           enableFeedback: true,
//           onPressed: onPressed,
//           icon: Consumer<AuthProvider>(
//             builder: (context, authProvider, _) => FaIcon(
//               authProvider.publicMode
//                   ? FontAwesomeIcons.lightLightbulbOn
//                   : FontAwesomeIcons.lightLightbulb,
//               color: Provider.of<ComindColorsNotifier>(context).onPrimary,
//               size: 24,
//             ),
//           ),
//           //   Provider.of<AuthProvider>(context).publicMode
//           //       ? FontAwesomeIcons.lightLightbulbOn
//           //       : FontAwesomeIcons.lightLightbulb,
//           //   color: Provider.of<ComindColorsNotifier>(context).onPrimary,
//           //   size: 24,
//           // ),
//           // icon: Icon(Icons.send),
//           iconSize: 24,
//         ),
//       ],
//     );
//   }
// }

// // Version with text
// // class ThinkButton extends StatelessWidget {
// //   const ThinkButton({Key? key, this.onPressed}) : super(key: key);

// //   final VoidCallback? onPressed;

// //   @override
// //   Widget build(BuildContext context) {
// //     // return Stack(
// //     //   children: [
// //     //     Padding(
// //     //       padding: const EdgeInsets.fromLTRB(0, 3, 3, 3),
// //     //       child: TextButtonSimple(
// //     //         text: 'Think',
// //     //         onPressed: onPressed!,
// //     //         colorChoice: ColorChoice.primary,
// //     //       ),
// //     //     ),
// //     //   ],
// //     // );

// //     return TextButtonSimple(
// //       text: 'Think',
// //       isHighlighted: true,
// //       onPressed: onPressed!,
// //       colorChoice: ColorChoice.primary,
// //     );
// //   }
// // }
