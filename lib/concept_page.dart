import 'package:comind/main_layout.dart';
import 'package:comind/menu_bar.dart';
import 'package:comind/misc/util.dart';
import 'package:flutter/material.dart';

class ConceptPage extends StatefulWidget {
  const ConceptPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ConceptPageState createState() => _ConceptPageState();
}

class _ConceptPageState extends State<ConceptPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Return a ListView of concepts
    return Scaffold(
      // App bar
      appBar: comindAppBar(context, appBarTitle("Concepts", context)),

      // Drawer
      drawer: MenuDrawer(),

      // Body
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Your code here
          // Use authProvider to access authentication related data
          // Return the desired widget tree

          // return MainLayout(middleColumn: middleColumn(context));
          return middleColumn(context);
        },
      ),
    );
  }

  Widget middleColumn(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: 300,
          child: Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return Text('Concept $index');
              },
            ),
          ),
        ),
      ],
    );
  }
}
