import 'package:comind/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ColorPicker extends StatefulWidget {
  final Function(Color) onColorSelected;

  const ColorPicker({Key? key, required this.onColorSelected})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Text("What color are you today?",
        //     style: Provider.of<ComindColorsNotifier>(context)
        //         .textTheme
        //         .titleMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildColorButton(Color.fromARGB(255, 151, 0, 251)),

            //
            _buildColorButton(const Color.fromARGB(255, 157, 46, 46)),

            // from #51AE5F
            _buildColorButton(const Color.fromARGB(255, 76, 198, 95)),

            // #3B5EDA, RGB: 59, 94, 218
            _buildColorButton(const Color.fromARGB(255, 59, 94, 218)),
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
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            setState(() {
              selectedColor = color;
            });
            widget.onColorSelected(color);
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selectedColor == color
                    ? Colors.white.withAlpha(64)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(8),
          ),
        ));
  }
}
