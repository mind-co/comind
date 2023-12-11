// import 'package:comind/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:comind/misc/comind-logo.dart';
// import 'package:super_editor/super_editor.dart';

// class ThoughtEditorScreen extends StatefulWidget {
//   const ThoughtEditorScreen({super.key});

//   @override
//   _ThoughtEditorScreenState createState() => _ThoughtEditorScreenState();
// }

// class _ThoughtEditorScreenState extends State<ThoughtEditorScreen> {
//   final TextEditingController _textEditingController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.background,
//         title: ComindLogo(key: UniqueKey()),
//         centerTitle: true,
//         elevation: 0,
//         actions: [
//           // Add dark mode toggle
//           IconButton(
//             icon: const Icon(Icons.dark_mode),
//             onPressed: () {
//               // Toggle the brightness
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: TextField(
//           style: TextStyle(
//             color: ComindColors().getTextColorBasedOnBackground(
//                 Theme.of(context).colorScheme.background),
//           ),
//           controller: _textEditingController,
//           maxLines: null, // Allows the text field to expand to multiple lines
//           expands: true, // Expands the text field as needed

//           cursorColor: ComindColors().getTextColorBasedOnBackground(
//               Theme.of(context).colorScheme.background),
//           // cursorColor: Colors.white,
//           decoration: const InputDecoration(
//             hintText: 'Get thinky...',
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _textEditingController.dispose();
//     super.dispose();
//   }
// }

// class _StandardEditor extends StatefulWidget {
//   const _StandardEditor();

//   @override
//   State<_StandardEditor> createState() => _StandardEditorState();
// }

// class _StandardEditorState extends State<_StandardEditor> {
//   final GlobalKey _docLayoutKey = GlobalKey();

//   late MutableDocument _doc;
//   late MutableDocumentComposer _composer;
//   late Editor _docEditor;

//   late FocusNode _editorFocusNode;

//   late ScrollController _scrollController;

//   @override
//   void initState() {
//     super.initState();
//     _doc = createInitialDocument();
//     _composer = MutableDocumentComposer();
//     _docEditor =
//         createDefaultDocumentEditor(document: _doc, composer: _composer);
//     _editorFocusNode = FocusNode();
//     _scrollController = ScrollController();
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _editorFocusNode.dispose();
//     _composer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SuperEditor(
//       editor: _docEditor,
//       document: _doc,
//       composer: _composer,
//       focusNode: _editorFocusNode,
//       scrollController: _scrollController,
//       documentLayoutKey: _docLayoutKey,
//     );
//   }
// }

// MutableDocument createInitialDocument() {
//   return MutableDocument(
//     nodes: [
//       ParagraphNode(
//         id: Editor.createNodeId(),
//         text: AttributedText(
//           "Super Editor is a toolkit to help you build document editors, document layouts, text fields, and more.",
//         ),
//       ),
//     ],
//   );
// }
