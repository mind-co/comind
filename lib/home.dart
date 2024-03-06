import 'package:comind/colors.dart';
import 'package:comind/main_layout.dart';
import 'package:comind/markdown_display_line.dart';
import 'package:comind/misc/comind_logo.dart';
import 'package:comind/text_button_simple.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  final shadowOffset = 4.0;

  // Constructor with key
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('Home'),
        // ),
        body: MainLayout(
      // middleColumn: PopDrop(
      //   children: [
      //     ComindLogo(colors: Provider.of<ComindColorsNotifier>(context)),
      //     coThought(context, "Welcome to Comind!", "A welcome from Co",
      //         linkable: false),
      //     coThought(context, "Welcome to Comind!", ""),
      //   ],
      // ),
      middleColumn: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            child:
                ComindLogo(colors: Provider.of<ComindColorsNotifier>(context)),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: coThought(context, "Welcome to Comind!", "A welcome from Co",
                linkable: false),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: coThought(
                context,
                "Comind is in **pre-alpha** phase. Most shit is broken. Don't expect things to work, your data could all disappear, etc. That said, you can probably sign up and things might work, but it's mostly a dumpster fire right now.",
                "Project status",
                linkable: false),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: coThought(
                context,
                "Comind is lots of things. In fact, it is perhaps too many things. Whatever it is, it's a place to think good thoughts.",
                "Co is confused",
                linkable: false),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: coThought(
                context,
                "Things you can do on Comind: \n- **Dump all your weird thoughts into a bucket** and let the robots organize it for you. Robots are good at that now.\n- **Share and learn** from other people's thoughts. Think communally.\n- **Live thinking sesisons with your friendos and randos.** It's like a party, but with words.\n- **Build a personal knowledge graph.** Comind makes it super easy, I promise.",
                "Co tries to explain what the heck comind is",
                linkable: false),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: coThought(
                context,
                "The best part? **Concepts come to life**. You and me and your kinda quirky friend Paul think thoughts, and many of those are about similar topics. \n\n Personalities grow to represent each concept -- and they're all unique. They remember you, they comment on things you think, and they contribute their perspective.\n\nIt's cool. Or at least, I think so.",
                "Co tells you the best part",
                linkable: false),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: coThought(
                context,
                "This project is a work of love by [Cameron Pfiffer](https://twitter.com/cameron_pfiffer) and mindco. You can support its development at [Patreon](https://www.patreon.com/comind).",
                "Co tells you about the creators",
                linkable: false),
          ),

          // Footer
          Container(
            color: Provider.of<ComindColorsNotifier>(context)
                .currentColors
                .colorScheme
                .background,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButtonSimple(
                        fontScalar: 2,
                        text: "BUCKLE UP",
                        onPressed: () =>
                            {Navigator.pushNamed(context, '/login')}),
                    // TextButtonSimple(
                    //     text: "Terms of Service",
                    //     onPressed: () => {
                    //           Navigator.pushNamed(context, '/tos'),
                    //         }),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Text(" | ",
                    //       style: Theme.of(context).textTheme.bodyLarge),
                    // ),
                    // TextButtonSimple(
                    //     text: "Privacy Policy",
                    //     onPressed: () => {
                    //           Navigator.pushNamed(context, '/privacy'),
                    //         }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
