import 'package:comind/colors.dart';
import 'package:comind/markdown_display.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/stream.dart';
import 'package:comind/text_button.dart';
import 'package:comind/types/thought.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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
      appBar: comindAppBar(context),
      body: SizedBox(
        width: ComindColors.maxWidth,
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Empty thing to make it centered
              Expanded(
                child: Container(width: 200),
              ),
              SizedBox(
                width: ComindColors.maxWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MarkdownThought(
                        thought: Thought.fromString(
                          intro,
                          "cameron",
                          true,
                          title: "Welcome to Comind",
                        ),
                        type: MarkdownDisplayType.fullScreen),

                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: TheMarkdownBox(text: intro),
                    // ),

                    // Button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ComindTextButton(
                          onPressed: () async {
                            // Make uri
                            var url = Uri(
                              scheme: 'https',
                              host: 'www.patreon.com',
                              path: 'comind',
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          text: 'Patreon',
                        ),
                        ComindTextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          text: 'Register',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Empty thing to make it centered
              Expanded(
                child: Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
