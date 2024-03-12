// ignore_for_file: prefer_const_constructors

import 'package:comind/api.dart';
import 'package:comind/colors.dart';
import 'package:comind/hover_icon_button.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/text_button_simple.dart';
import 'package:comind/types/brainstacks.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BrainStackListView extends StatefulWidget {
  const BrainStackListView({Key? key}) : super(key: key);

  @override
  _BrainStackListViewState createState() => _BrainStackListViewState();
}

class _BrainStackListViewState extends State<BrainStackListView> {
  // The brainstacks
  late Brainstacks brainstacks = const Brainstacks(brainstacks: [
    Brainstack(
        title: "Judy's criminal record",
        description:
            "A bunch of documents about Judy getting up to some stuff man",
        brainstackId: "abc",
        thoughtIds: ["a", "b", "c", "d", "d", "f"]),
    Brainstack(
        title: "Recipes",
        description:
            "Mostly Hungarian dishes, with a few chocolate-based deserts.",
        brainstackId: "abc",
        thoughtIds: ["a", "b", "c"]),
    Brainstack(
        title: "Evil stuff",
        description:
            "Plans to take over the world. Are you sure you should be doing that?",
        brainstackId: "abc",
        thoughtIds: ["a", "b"]),
    Brainstack(
        title: "Judy's criminal record",
        description:
            "A bunch of documents about Judy getting up to some stuff man",
        brainstackId: "abc",
        thoughtIds: ["a", "b", "c", "d", "d", "f"]),
    Brainstack(
        title: "Recipes",
        description:
            "Mostly Hungarian dishes, with a few chocolate-based deserts.",
        brainstackId: "abc",
        thoughtIds: ["a", "b", "c"]),
    Brainstack(
        title: "Evil stuff",
        description:
            "Plans to take over the world. Are you sure you should be doing that?",
        brainstackId: "abc",
        thoughtIds: ["a", "b"]),
    Brainstack(
        title: "Judy's criminal record",
        description:
            "A bunch of documents about Judy getting up to some stuff man",
        brainstackId: "abc",
        thoughtIds: ["a", "b", "c", "d", "d", "f"]),
    Brainstack(
        title: "Recipes",
        description:
            "Mostly Hungarian dishes, with a few chocolate-based deserts.",
        brainstackId: "abc",
        thoughtIds: ["a", "b", "c"]),
    Brainstack(
        title: "Evil stuff",
        description:
            "Plans to take over the world. Are you sure you should be doing that?",
        brainstackId: "abc",
        thoughtIds: ["a", "b"])
  ]);

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
      appBar: comindAppBar(context, title: appBarTitle("Brainstacks", context)),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              backgroundColor: colors.colorScheme.surface,
              onPressed: () {
                // Controllers for title + description
                TextEditingController titleController = TextEditingController();
                TextEditingController descriptionController =
                    TextEditingController();

                // Make a dialog with a text field for the title
                // and a text field for the description
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Create a new brainstack"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: titleController,
                            decoration: InputDecoration(
                              labelText: "Title",
                            ),
                          ),
                          TextField(
                            controller: descriptionController,
                            decoration: InputDecoration(
                              labelText: "Description",
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            // Create the brainstack
                            createBrainstack(context, titleController.text,
                                description: descriptionController.text,
                                color: colors.primaryColor);
                            Navigator.of(context).pop();
                          },
                          child: Text("Create"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Icon(Icons.add),
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
                backgroundColor: index == 0
                    ? ComindColors.primaryColorDefault
                    : index == 1
                        ? ComindColors.secondaryColorDefault
                        : index == 2
                            ? ComindColors.tertiaryColorDefault
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

class BrainstackDisplay extends StatefulWidget {
  final Brainstack brainstack;
  final TextStyle style;
  final TextStyle bodyStyle;
  final TextStyle footerStyle;
  final Color backgroundColor;

  BrainstackDisplay({
    Key? key,
    required this.brainstack,
    this.style = const TextStyle(fontSize: 24),
    this.bodyStyle = const TextStyle(fontSize: 16),
    this.footerStyle = const TextStyle(fontSize: 16),
    this.backgroundColor = Colors.deepPurple,
  }) : super(key: key);

  @override
  _BrainstackDisplayState createState() => _BrainstackDisplayState();
}

class _BrainstackDisplayState extends State<BrainstackDisplay> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _titleEditable = false;
  bool _descriptionEditable = false;

  get actionBarFontScalar => 1.0;
  get actionBarOutlined => false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.brainstack.title);
    _descriptionController =
        TextEditingController(text: widget.brainstack.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //
    ComindColors colors =
        Provider.of<ComindColorsNotifier>(context).currentColors;

    //
    final emptyBorder = OutlineInputBorder(
        // Make the border onbackground
        borderSide: BorderSide(color: colors.colorScheme.onBackground),

        // Rounded borders
        borderRadius:
            BorderRadius.all(Radius.circular(ComindColors.bubbleRadius)));

    var title = widget.brainstack.title;
    var description = widget.brainstack.description;
    var numThoughts = widget.brainstack.length;

    var titleOrEditable = _titleEditable
        ? TextField(
            style: widget.style,
            controller: _titleController,
            autofocus: true,
            cursorColor: Colors.white,
            autocorrect: true,
            onTap: () {
              setState(() {
                _titleEditable = true;
              });
            },
            onSubmitted: (value) {
              // Send the updated info to the server
              saveBrainstackMetadata(
                context,
                widget.brainstack.brainstackId,
                title: title,
              );

              setState(() {
                _titleEditable = false;
              });
            },
            onTapOutside: (_) {
              setState(() {
                _titleEditable = false;
              });
            },
            decoration: InputDecoration(
              focusedBorder: emptyBorder,
              disabledBorder: emptyBorder,
              enabledBorder: emptyBorder,
              contentPadding: EdgeInsets.all(8),
            ),
          )
        : GestureDetector(
            onTap: () {
              setState(() {
                _titleEditable = true;
              });
            },
            child: Text(title, style: widget.style),
          );

    var descriptionOrEditable = _descriptionEditable
        ? TextField(
            controller: _descriptionController,
            style: widget.bodyStyle,
            autofocus: true,
            cursorColor: Colors.white,
            maxLength: 200,
            minLines: 1,
            maxLines: 100,
            onTap: () => {
              setState(() {
                _descriptionEditable = true;
              })
            },
            onTapOutside: (_) {
              setState(() {
                _descriptionEditable = false;
              });
            },
            decoration: InputDecoration(
              disabledBorder: emptyBorder,
              focusedBorder: emptyBorder,
              enabledBorder: emptyBorder,
              contentPadding: EdgeInsets.all(8),
            ),
          )
        : GestureDetector(
            onTap: () {
              setState(() {
                _descriptionEditable = true;
              });
            },
            child: Text(description),
          );

    return SizedBox(
        child: Card(
      color: widget.backgroundColor.withOpacity(0.5),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: titleOrEditable,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: descriptionOrEditable,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  "$numThoughts thoughts",
                  style: widget.footerStyle,
                ),
                Spacer(),

                // Delete button
                TextButtonSimple(
                  onPressed: () {
                    // Delete the brainstack
                    // deleteBrainstack(context, widget.brainstack.brainstackId);
                  },
                  fontScalar: actionBarFontScalar,
                  outlined: actionBarOutlined,
                  text: "Delete",
                  // style: widget.footerStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
