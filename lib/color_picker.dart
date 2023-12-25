import 'package:comind/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ColorPicker extends StatefulWidget {
  final Function(Color) onColorSelected;

  const ColorPicker({Key? key, required this.onColorSelected})
      : super(key: key);

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("What color are you today?",
            style: Provider.of<ComindColorsNotifier>(context)
                .textTheme
                .titleMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildColorButton(Color.fromARGB(255, 32, 61, 77)),

            //
            _buildColorButton(Color.fromARGB(255, 157, 46, 46)),

            // from #51AE5F
            _buildColorButton(Color.fromARGB(255, 76, 198, 95)),

            // #3B5EDA, RGB: 59, 94, 218
            _buildColorButton(Color.fromARGB(255, 59, 94, 218)),
            // _buildColorButton(Colors.yellow),
            // _buildColorButton(Colors.purple),
            // _buildColorButton(Colors.orange),
            // _buildColorButton(Colors.pink[100]!),
          ],
        ),
      ],
    );
  }

  Widget _buildColorButton(Color color) {
    return Material(
        child: InkWell(
      splashColor: color,
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          selectedColor = color;
        });
        widget.onColorSelected(color);
      },
      child: Container(
        color: color,
        width: 20,
        height: 20,
        margin: EdgeInsets.all(8),
      ),
    ));

    // return GestureDetector(
    //   onTap: () {
    //     setState(() {
    //       selectedColor = color;
    //     });
    //     widget.onColorSelected(color);
    //   },
    //   // child: Center(
    //   //   child: Container(
    //   //     width: 30,
    //   //     height: 30,
    //   //     margin: EdgeInsets.all(8),
    //   //     decoration: BoxDecoration(
    //   //       color: color,
    //   //       shape: BoxShape.circle,
    //   //       border: Border.all(
    //   //         color: selectedColor == color ? Colors.black : Colors.transparent,
    //   //         width: 6,
    //   //       ),
    //   //     ),
    //   //   ),
    //   // ),
    // );
  }
}
