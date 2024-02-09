import 'dart:async';
import 'package:flutter/material.dart';

class PopDrop extends StatefulWidget {
  final List<Widget> children;

  const PopDrop({Key? key, required this.children}) : super(key: key);

  @override
  _PopDropState createState() => _PopDropState();
}

class _PopDropState extends State<PopDrop> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.children.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      height: 400,
      child: ListView.builder(
        itemCount: _currentIndex + 1,
        itemBuilder: (context, index) {
          return widget.children[index];
        },
      ),
    );
  }
}
