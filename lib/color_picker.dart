import 'package:flutter/material.dart';

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildColorButton(Colors.red),
        _buildColorButton(Colors.blue),
        _buildColorButton(const Color.fromARGB(255, 146, 215, 148)),
        _buildColorButton(Colors.yellow),
        _buildColorButton(Colors.purple),
        _buildColorButton(Colors.orange),
        _buildColorButton(Colors.pink[100]!),
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
        width: 50,
        height: 50,
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
