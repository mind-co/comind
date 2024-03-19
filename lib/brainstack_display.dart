import 'package:flutter/material.dart';
import 'package:comind/api.dart';
import 'package:comind/colors.dart';
import 'package:comind/text_button_simple.dart';
import 'package:comind/types/brainstacks.dart';
import 'package:provider/provider.dart';

class BrainstackDisplay extends StatefulWidget {
  final Brainstack brainstack;
  final TextStyle style;
  final TextStyle bodyStyle;
  final TextStyle footerStyle;
  final Color backgroundColor;

  // onDelete function
  final void Function() onDelete;

  BrainstackDisplay({
    Key? key,
    required this.brainstack,
    required this.onDelete,
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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Controllers for title + description
    _titleController = TextEditingController(text: widget.brainstack.title);
    _descriptionController =
        TextEditingController(text: widget.brainstack.description);

    // Get the colors
    ComindColors colors =
        Provider.of<ComindColorsNotifier>(context).currentColors;

    //
    final emptyBorder = OutlineInputBorder(
        // Make the border onbackground
        borderSide:
            BorderSide(color: colors.colorScheme.onBackground.withAlpha(128)),

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
            maxLength: 64,
            autofocus: true,
            cursorColor: Colors.white,
            autocorrect: true,
            onTap: () {
              setState(() {
                _titleEditable = true;
              });
            },
            onSubmitted: (value) {
              // Validate the title
              if (value.isEmpty || value == title || value.length > 64) {
                return;
              }

              // Send the updated info to the server
              saveBrainstackMetadata(
                context,
                widget.brainstack.brainstackId,
                title: _titleController.text,
              );

              setState(() {
                _titleEditable = false;
                title = _titleController.text;
              });
            },
            decoration: InputDecoration(
              focusedBorder: emptyBorder,
              disabledBorder: emptyBorder,
              enabledBorder: emptyBorder,
              contentPadding: EdgeInsets.all(8),
            ),
          )
        : Text(title, style: widget.style);

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
            decoration: InputDecoration(
              disabledBorder: emptyBorder,
              focusedBorder: emptyBorder,
              enabledBorder: emptyBorder,
              contentPadding: EdgeInsets.all(8),
            ),
          )
        : SizedBox(width: ComindColors.maxWidth, child: Text(description));

    return SizedBox(
        child: Material(
      child: InkWell(
        borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
        onTap: () => {
          // Push a BrainstackLoader onto the stack
          Navigator.pushNamed(
              context, '/brainstacks/${widget.brainstack.brainstackId}')
        },
        child: Card(
          color: widget.backgroundColor.withOpacity(0.5),
          child: Column(
            children: [
              SizedBox(
                width: ComindColors.maxWidth,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: titleOrEditable,
                ),
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

                    // Cancel edit button
                    Visibility(
                      visible: _titleEditable || _descriptionEditable,
                      child: TextButtonSimple(
                        onPressed: () {
                          setState(() {
                            _titleEditable = false;
                            _descriptionEditable = false;
                            _titleController.text = title;
                            _descriptionController.text = description;
                          });
                        },
                        fontScalar: actionBarFontScalar,
                        outlined: actionBarOutlined,
                        text: "Cancel",
                        // style: widget.footerStyle,
                      ),
                    ),

                    // Save title button
                    Visibility(
                      visible: _titleEditable,
                      child: TextButtonSimple(
                        onPressed: () {
                          // Send the updated info to the server
                          saveBrainstackMetadata(
                            context,
                            widget.brainstack.brainstackId,
                            title: _titleController.text,
                          );

                          setState(() {
                            _titleEditable = false;
                            title = _titleController.text;
                          });
                        },
                        fontScalar: actionBarFontScalar,
                        outlined: actionBarOutlined,
                        text: "Save",
                        // style: widget.footerStyle,
                      ),
                    ),

                    // Delete button
                    Visibility(
                      visible: !_titleEditable && !_descriptionEditable,
                      child: TextButtonSimple(
                        onPressed: widget.onDelete ?? () {},
                        fontScalar: actionBarFontScalar,
                        outlined: actionBarOutlined,
                        text: "Delete",
                        // style: widget.footerStyle,
                      ),
                    ),

                    // Edit button
                    Visibility(
                      visible: !_titleEditable && !_descriptionEditable,
                      child: TextButtonSimple(
                        onPressed: () {
                          setState(() {
                            _titleEditable = true;
                            _descriptionEditable = true;
                          });
                        },
                        fontScalar: actionBarFontScalar,
                        outlined: actionBarOutlined,
                        text: "Edit",
                        // style: widget.footerStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
