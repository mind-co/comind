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
            _buildColorButton(Color.fromARGB(255, 143, 36, 0)),
            _buildColorButton(Color.fromARGB(255, 55, 0, 91)),
            _buildColorButton(const Color.fromARGB(255, 146, 215, 148)),

            // from #51AE5F
            _buildColorButton(const Color.fromARGB(255, 81, 174, 95)),
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
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
        widget.onColorSelected(color);
      },
      child: Container(
        width: 30,
        height: 30,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selectedColor == color ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
