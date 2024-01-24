import 'package:comind/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComindBottomSheet extends StatelessWidget {
  const ComindBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("made with ❤️ by mindco",
            style: TextStyle(
                fontSize: 12,
                color: Provider.of<ComindColorsNotifier>(context)
                    .colorScheme
                    .onBackground
                    .withAlpha(150))),
      ),
    );
  }
}
