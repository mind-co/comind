import 'package:comind/colors.dart';
import 'package:comind/main.dart';
import 'package:comind/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Provider.of<ComindColorsNotifier>(context).background,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Provider.of<ComindColorsNotifier>(context).onBackground,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Color Dialog'),
            onTap: () async {
              Color color = await colorDialog(context);
              Provider.of<ComindColorsNotifier>(context, listen: false)
                  .modifyColors(color);
            },
          ),
          ListTile(
            title: Text('Dark Mode'),
            onTap: () {
              Provider.of<ComindColorsNotifier>(context, listen: false)
                  .toggleTheme(
                      !Provider.of<ComindColorsNotifier>(context, listen: false)
                          .darkMode);
            },
          ),
          Visibility(
            visible: !Provider.of<AuthProvider>(context).isLoggedIn,
            child: ListTile(
              title: Text('Log in'),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ),
          Visibility(
            visible: !Provider.of<AuthProvider>(context).isLoggedIn,
            child: ListTile(
              title: Text('Sign up'),
              onTap: () {
                Navigator.pushNamed(context, '/signup');
              },
            ),
          ),

          // Logout button
          Visibility(
            visible: Provider.of<AuthProvider>(context).isLoggedIn,
            child: ListTile(
              title: Text('Log out'),
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
              },
            ),
          ),

          // Public
        ],
      ),
    );
  }
}


// Wrap(direction: Axis.vertical, children: [
//                 // // Color picker
//                 // ColorPicker(onColorSelected: (Color color) {
//                 //   Provider.of<ComindColorsNotifier>(context, listen: false)
//                 //       .modifyColors(color);
//                 // }),

//                 Opacity(
//                     opacity: .7,
//                     child:
//                         Text("Menu", style: getTextTheme(context).titleMedium)),

//                 // fills the left column so that button expansions don't do anything
//                 const SizedBox(height: 0, width: 200),

//                 // Public/private button
//                 TextButtonSimple(
//                     text: Provider.of<ComindColorsNotifier>(context).publicMode
//                         ? "Public"
//                         : "Private",
//                     onPressed: () {
//                       Provider.of<ComindColorsNotifier>(context, listen: false)
//                           .togglePublicMode(!Provider.of<ComindColorsNotifier>(
//                                   context,
//                                   listen: false)
//                               .publicMode);
//                     }),

//                 // Load public thoughts
//                 TextButtonSimple(
//                     text: "Load public",
//                     onPressed: () {
//                       // Clear top of mind
//                       Provider.of<ThoughtsProvider>(context, listen: false)
//                           .clear();

//                       // Remove related thoughts
//                       relatedThoughts.clear();

//                       // Fetch related thoughts
//                       _fetchStream(context);

//                       // Set mode to stream
//                       mode = Mode.public;
//                     }),

//                 // My thoughts
//                 TextButtonSimple(
//                     text: "My thoughts",
//                     onPressed: () {
//                       // Clear top of mind
//                       Provider.of<ThoughtsProvider>(context, listen: false)
//                           .clear();

//                       // Remove related thoughts
//                       relatedThoughts.clear();

//                       // Fetch related thoughts
//                       fetchUserThoughts();

//                       // Set mode to mythoughts
//                       mode = Mode.myThoughts;
//                     }),

//                 // Clear top of mind
//                 TextButtonSimple(
//                     text: "Clear",
//                     onPressed: () {
//                       Provider.of<ThoughtsProvider>(context, listen: false)
//                           .clear();

//                       // Remove related thoughts
//                       relatedThoughts.clear();
//                     }),

//                 // Color picker button
//                 TextButtonSimple(
//                     text: "Color",
//                     onPressed: () async {
//                       Color color = await colorDialog(context);
//                       Provider.of<ComindColorsNotifier>(context, listen: false)
//                           .modifyColors(color);
//                     }),

//                 // Dark mode
//                 TextButtonSimple(
//                     text: "Dark mode",
//                     onPressed: () {
//                       Provider.of<ComindColorsNotifier>(context, listen: false)
//                           .toggleTheme(!Provider.of<ComindColorsNotifier>(
//                                   context,
//                                   listen: false)
//                               .darkMode);
//                     }),

//                 // Login button
//                 Visibility(
//                   visible: !Provider.of<AuthProvider>(context).isLoggedIn,
//                   child: TextButtonSimple(
//                       text: "Log in",
//                       // Navigate to login page.
//                       onPressed: () {
//                         Navigator.pushNamed(context, "/login");
//                       }),
//                 ),

//                 // Sign up button
//                 Visibility(
//                   visible: !Provider.of<AuthProvider>(context).isLoggedIn,
//                   child: TextButtonSimple(
//                       text: "Sign up",
//                       // Navigate to sign up page.
//                       onPressed: () {
//                         Navigator.pushNamed(context, "/signup");
//                       }),
//                 ),

//                 // Settings
//                 // Visibility(
//                 //   child: ComindTextButton(
//                 // lineLocation: LineLocation.left,
//                 //       text: "Settings",
//                 //       onPressed: () {
//                 //         Navigator.pushNamed(
//                 //             context, "/settings");
//                 //       }),
//                 // ),

//                 const SizedBox(height: 20),
//                 Opacity(
//                     opacity: .7,
//                     child: Text("Dev buttons",
//                         style: getTextTheme(context).titleMedium)),

//                 // Debug button to add a top of mind thought
//                 Visibility(
//                   visible: true,
//                   child: TextButtonSimple(
//                       text: "TOM",
//                       onPressed: () {
//                         Provider.of<ThoughtsProvider>(context, listen: false)
//                             .addTopOfMind(Thought.fromString(
//                                 "I'm happy to have you here :smiley:",
//                                 "Co",
//                                 true,
//                                 title: "Welcome to comind"));
//                       }),
//                 ),

//                 const SizedBox(height: 20),
//                 Opacity(
//                     opacity: .5,
//                     child: Text("Other stuff",
//                         style: getTextTheme(context).titleMedium)),

                
//                 ),
//               ])