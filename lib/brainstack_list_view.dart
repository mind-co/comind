// ignore_for_file: prefer_const_constructors

import 'package:comind/api.dart';
import 'package:comind/brainstack_display.dart';
import 'package:comind/colors.dart';
import 'package:comind/hover_icon_button.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/providers.dart';
import 'package:comind/text_button_simple.dart';
import 'package:comind/types/brainstacks.dart';
import 'package:comind/types/thought.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class BrainStackListView extends StatefulWidget {
  const BrainStackListView({Key? key}) : super(key: key);

  @override
  _BrainStackListViewState createState() => _BrainStackListViewState();
}

class _BrainStackListViewState extends State<BrainStackListView> {
  // The brainstacks
  late Brainstacks brainstacks = const Brainstacks(brainstacks: []);

  // Method to get the brainstacks from the server
  Future<void> getBrainstacks() async {
    // Get the brainstacks
    final brainstacks = await fetchBrainstacks(context);

    // Set the state
    setState(() {
      this.brainstacks = brainstacks;
    });
  }

  // Override the initState method
  @override
  void initState() {
    super.initState();
    getBrainstacks();
  }

  @override
  Widget build(BuildContext context) {
    ComindColors colors =
        Provider.of<ComindColorsNotifier>(context).currentColors;

    // Return the brainstacks
    return Scaffold(
      appBar: comindAppBar(context, title: appBarTitle("Streams", context)),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              backgroundColor: colors.colorScheme.surface,
              onPressed: () {
                // Make a new brainstack
                var newBrainstack = Brainstack(
                    title: "untitled",
                    description: "",
                    brainstackId: generateUUID4(Provider.of<AuthProvider>(
                            context,
                            listen: false)
                        .username), // Generate a new UUID for the brainstack
                    thoughtIds: []);

                // Add a new brainstack to the list
                brainstacks.add(newBrainstack);

                // Save the brainstack to the server
                createBrainstack(
                  context,
                  id: newBrainstack.brainstackId,
                  title: newBrainstack.title,
                  description: newBrainstack.description,
                );

                // Set the state
                setState(() {});
              },
              child: Icon(LineIcons.plus),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              backgroundColor: colors.colorScheme.surface,
              onPressed: () {
                getBrainstacks();
              },
              child: Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: ComindColors.maxWidth,
          child: ListView.builder(
            itemCount: brainstacks.length,
            itemBuilder: (context, index) {
              final brainstack = brainstacks[index];
              return BrainstackDisplay(
                brainstack: brainstack,
                onDelete: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Confirm Delete"),
                        content: Text(
                            "Are you sure you want to delete this brainstack?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              // Delete the brainstack
                              deleteBrainstack(
                                  context, brainstack.brainstackId);

                              // Remove the brainstack from the list
                              setState(() {
                                brainstacks.removeAt(index);
                              });

                              Navigator.of(context).pop();
                            },
                            child: Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );
                },
                backgroundColor: index == 0
                    ? ComindColors.primaryColorDefault
                    : index == 1
                        ? ComindColors.secondaryColorDefault
                        : index == 2
                            ? Color(0xFF009877)
                            : Colors.deepPurple,
                style: colors.textTheme.titleMedium!,
                bodyStyle: colors.textTheme.bodyMedium!,
                footerStyle: colors.textTheme.labelSmall!,
              );
            },
          ),
        ),
      ),
    );
  }
}
