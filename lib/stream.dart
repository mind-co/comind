// Stream
//
// This is teh sccreen for the stream of conciousness.
// Here, one thought is displayed, and three optional thoughts are provided.
// The user can choose to add a link, or move on to the next thought.
// The user can also write a thought, which may link to the current thought
// previous thoughts, or none.
// The user can also choose to go back to the previous thought.

// imports
import 'package:comind/main.dart';
import 'package:comind/markdown_display.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/text_button.dart';
import 'package:flutter/material.dart';
import 'package:comind/types/thought.dart';
import 'package:comind/input_field.dart';
import 'package:comind/api.dart';
import 'package:google_fonts/google_fonts.dart';

// StreamScreen
//
class StreamScreen extends StatefulWidget {
  @override
  _StreamScreenState createState() => _StreamScreenState();
}

// _StreamScreenState
//
class _StreamScreenState extends State<StreamScreen> {
  // Array of previous thoughts, called the train
  List<Thought> train = [
    Thought.lorem(),
    Thought.basic(),
    Thought.screenplay()
  ];

  // Controller for the main text field
  TextEditingController _primaryController = TextEditingController();

  // Search mode
  bool searchMode = false;

  // Fetch thoughts
  void _fetchThoughts() async {
    // Get the thoughts
    var thoughts = await fetchThoughts();

    // Set the state
    setState(() {
      train = thoughts;
    });

    print("Fetched thoughts");
  }

  // _StreamScreenState
  //
  @override
  void initState() {
    super.initState();
  }

  // build
  //
  @override
  Widget build(BuildContext context) {
    // var textStyle = TextStyle(
    //   fontFamily: "Bungee",
    //   fontSize: 20,
    // );
    var textStyle = GoogleFonts.bungeeInline(
      fontSize: 20,
    );
    return Scaffold(
        appBar: comindAppBar(context),
        body: Center(
            // Display each thought in the train
            child: ListView(children: [
          Column(
            children: [
              for (var i = 0; i < train.length; i++)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: MarkdownThought(
                    thought: train[i],
                    context: context,
                    // opacity: i == train.length - 1 ? 1 : 0.5,
                  ),
                ),

              // Vertical line
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: Container(
                  height: 14,
                  width: 2,
                  color: Colors.grey,
                ),
              ),

              // Main text field
              MainTextField(
                primaryController: _primaryController,
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hey, thanks for spending time here.",
                    )
                  ],
                ),
              ),
            ],
          ),
        ])));
  }
}
// child: SizedBox(
//           width: 700,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: <Widget>[
//               // Show the thought
//               MarkdownThought(thought: thought, context: context),

//               // Action row
//               Center(
//                 child:         ),
//             ],
//           ),
//         ),
