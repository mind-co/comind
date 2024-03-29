// Dispatches the user to where the need to go.
// If not logged in, send them to the login page.
// If logged in, send them to the home page.
import 'package:comind/brainstack_list_view.dart';
import 'package:comind/brainstack_view.dart';
import 'package:comind/concept_page.dart';
import 'package:comind/home.dart';
import 'package:comind/login.dart';
import 'package:comind/providers.dart';
import 'package:comind/stream.dart';
import 'package:comind/thought_editor_basic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dispatch extends StatelessWidget {
  const Dispatch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the auth provider
    final authProvider = Provider.of<AuthProvider>(context);

    // Return loading screen
    //authProvider.isLoggedIn == null) {

    // return WelcomePage();

    // If the user is logged in, send them to the home page
    if (authProvider.isLoggedIn) {
      return Navigator(
        onGenerateRoute: (settings) {
          // Handle '/'
          if (settings.name == '/') {
            return MaterialPageRoute(
              builder: (context) => const Dispatch(),
            );
          }

          // Handle '/login'
          if (settings.name == '/login') {
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            );
          }

          // Handle /concepts
          if (settings.name == '/concepts') {
            return MaterialPageRoute(
              builder: (context) => const ConceptPage(),
            );
          }

          // Handle /brainstacks
          if (settings.name == '/brainstacks') {
            return MaterialPageRoute(
              builder: (context) => const BrainStackListView(),
            );
          }

          // Handle /brainstacks/:id
          var brainstackUri = Uri.parse(settings.name!);
          if (brainstackUri.pathSegments.length == 2 &&
              brainstackUri.pathSegments.first == 'brainstacks') {
            var id = brainstackUri.pathSegments[1];
            // BrainstackLoader.loadBrainstack(context, id: id, brainstack: null);
            return MaterialPageRoute(
              builder: (context) => BrainstackLoader(id: id, brainstack: null),
            );
          }

          // Handle '/thoughts'
          // if (settings.name == '/thoughts') {
          //   return MaterialPageRoute(
          //     builder: (context) => const ThoughtListScreen(),
          //   );
          // }

          // Handle '/thoughts/:id'
          var uri = Uri.parse(settings.name!);
          if (uri.pathSegments.length == 2 &&
              uri.pathSegments.first == 'thoughts') {
            var id = uri.pathSegments[1];
            ThoughtLoader.loadThought(context, id: id, thought: null);

            // return MaterialPageRoute(
            //   builder: (context) => ThoughtEditorScreen(id: id),
            // );
          }

          // Handle '/'
          return MaterialPageRoute(
            builder: (context) => const Stream(),
          );
        },
        pages: [
          // Load the login screen if the user is not logged in
          if (!authProvider.isLoggedIn)
            const MaterialPage(
              child: LoginScreen(),
            ),

          // // Load the thought list screen
          // if (authProvider.isLoggedIn)
          //   const MaterialPage(
          //     child: ThoughtListScreen(),
          //   ),

          // // Load the stream only if the user is logged in
          if (authProvider.isLoggedIn)
            const MaterialPage(
              child: Stream(),
            ),

          // // Brainstack page
          // if (authProvider.isLoggedIn)
          //   MaterialPage(
          //     child: const BrainStackView(),
          //   ),
        ],
        onPopPage: (route, result) => route.didPop(result),
      );
    } else {
      return Navigator(
        pages: [
          // MaterialPage(
          //   // child: Stream(),
          //   child: LoginScreen(),
          // ),

          // Return home page
          MaterialPage(child: HomePage()),
        ],
        onPopPage: (route, result) => route.didPop(result),
        onGenerateRoute: (settings) {
          // Condition the onGenerateRoute on the path
          if (settings.name == '/') {
            return MaterialPageRoute(
              builder: (context) => const Dispatch(),
            );
          }

          // Handle '/login'
          if (settings.name == '/login') {
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            );
          }

          // Handle sign up
          if (settings.name == '/signup') {
            return MaterialPageRoute(
                builder: (context) => const LoginScreen(initToSignUp: true));
          }

          // Handle '/thoughts'
          // if (settings.name == '/thoughts') {
          //   return MaterialPageRoute(
          //     builder: (context) => const ThoughtListScreen(),
          //   );
          // }

          // Handle '/thoughts/:id'
          var uri = Uri.parse(settings.name!);
          if (uri.pathSegments.length == 2 &&
              uri.pathSegments.first == 'thoughts') {
            var id = uri.pathSegments[1];
            ThoughtLoader.loadThought(context, id: id, thought: null);
          }

          // Handle '/'
          return MaterialPageRoute(
            builder: (context) => const Stream(),
          );
        },
      );
    }
  }
}
