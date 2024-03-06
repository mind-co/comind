import 'package:comind/main_layout.dart';
import 'package:comind/markdown_display_line.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/types/thought.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<String> loadMarkdownAsset(String assetPath) async {
  return await rootBundle.loadString(assetPath);
}

class WelcomePage extends StatefulWidget {
  WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // Make a intro variable
  String intro = '';

  @override
  void initState() {
    loadMarkdownAsset('assets/intro.md').then((value) => setState(() {
          intro = value;
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: comindAppBar(context, title: appBarTitle('Welcome', context)),
      body: MainLayout(middleColumn: middleColumn(context)),
    );
  }

  Widget middleColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Intro
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: MarkdownThought(
            viewOnly: true,
            thought: Thought.fromString(intro, "cameron", true, title: "Howdy"),
          ),
        ),

        // Buttons
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Row(
        //     children: [
        //       // Login button
        //       TextButton(
        //         onPressed: () {
        //           Navigator.of(context).pushNamed('/login');
        //         },
        //         child: Text('Login'),
        //       ),

        //       // Spacer
        //       Spacer(),

        //       // Signup button
        //       TextButton(
        //         onPressed: () {
        //           Navigator.of(context).pushNamed('/signup');
        //         },
        //         child: Text('Signup'),
        //       ),
        //     ],
        //   ),
        // ),

        // Spacer
        // Spacer(),

        // // fin
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Text(
        //     'fin',
        //     style: TextStyle(
        //       color: Provider.of<ComindColorsNotifier>(context)
        //           .colorScheme
        //           .onPrimary
        //           .withAlpha(255),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
