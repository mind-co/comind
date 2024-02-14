import 'package:comind/colors.dart';
import 'package:comind/main_layout.dart';
import 'package:comind/menu_bar.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/providers.dart';
import 'package:comind/types/concept.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
      appBar: comindAppBar(context, title: appBarTitle("Concepts", context)),

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
          width: ComindColors.maxWidth,
          child: ListView.builder(
            itemCount: Provider.of<ConceptsProvider>(context).concepts.length,
            itemBuilder: (context, index) {
              // Get the concept
              final concept =
                  Provider.of<ConceptsProvider>(context).concepts[index];

              return ConceptCard(
                concept: concept,
              );
            },
          ),
        ),
      ],
    );
  }
}

class ConceptCard extends StatelessWidget {
  final Concept concept;

  const ConceptCard({Key? key, required this.concept}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                elevation: 4,
                // decoration: BoxDecoration(
                //   color: Provider.of<ComindColorsNotifier>(context).primary,
                //   borderRadius:
                //       BorderRadius.circular(ComindColors.bubbleRadius),
                // ),
                color: Provider.of<ComindColorsNotifier>(context)
                    .primary
                    .withOpacity(0.7),
                borderRadius: BorderRadius.circular(ComindColors.bubbleRadius),
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                        child: Text(
                          concept.name,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: Provider.of<ComindColorsNotifier>(context)
                              .textTheme
                              .displaySmall,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                        child: Text(
                          // "${concept.numThoughts} thoughts",
                          concept.numThoughts == 1
                              ? "1 thought"
                              : "${concept.numThoughts} thoughts",
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: Provider.of<ComindColorsNotifier>(context)
                              .textTheme
                              .titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Description
            Visibility(
              visible: concept.description?.isNotEmpty ?? false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Container(
                  child: Center(
                    child: Text(
                      // "You have ${concept.numThoughts} thoughts about this concept.",
                      concept.description ?? "",
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // child: ListTile(
        //   // title: Text(concept.name, style: GoogleFonts.vt323()),
        //   // title: Text(concept.name.toUpperCase(), style: GoogleFonts.novaMono()),
        //   title:
        //       Text(concept.name, style: Theme.of(context).textTheme.titleMedium),
        //   subtitle: Text(
        //     "You have ${concept.numThoughts} thoughts about this concept.",
        //   ),
        // ),
      ),
    );
  }
}
