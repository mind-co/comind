// Dispatches the user to where the need to go.
// If not logged in, send them to the login page.
// If logged in, send them to the home page.
import 'package:comind/login.dart';
import 'package:comind/main.dart';
import 'package:comind/providers.dart';
import 'package:comind/stream.dart';
import 'package:comind/thought_editor_basic.dart';
import 'package:comind/welcome_page.dart';
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

    return WelcomePage();

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

          // Handle '/thoughts'
          if (settings.name == '/thoughts') {
            return MaterialPageRoute(
              builder: (context) => const ThoughtListScreen(),
            );
          }

          // Handle '/thoughts/:id'
          var uri = Uri.parse(settings.name!);
          if (uri.pathSegments.length == 2 &&
              uri.pathSegments.first == 'thoughts') {
            var id = uri.pathSegments[1];
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ThoughtEditorScreen(id: id),
              ),
            );

            // return MaterialPageRoute(
            //   builder: (context) => ThoughtEditorScreen(id: id),
            // );
          }

          // Handle '/'
          return MaterialPageRoute(
            builder: (context) => const ThoughtListScreen(),
          );
        },
        pages: [
          // Load the login screen if the user is not logged in
          // if (!authProvider.isLoggedIn)
          //   const MaterialPage(
          //     child: LoginScreen(),
          //   ),

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
        ],
        onPopPage: (route, result) => route.didPop(result),
      );
    } else {
      return Navigator(
        pages: const [
          MaterialPage(
            child: Stream(),
            // child: LoginScreen(),
          ),
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
          if (settings.name == '/thoughts') {
            return MaterialPageRoute(
              builder: (context) => const ThoughtListScreen(),
            );
          }

          // Handle '/thoughts/:id'
          var uri = Uri.parse(settings.name!);
          if (uri.pathSegments.length == 2 &&
              uri.pathSegments.first == 'thoughts') {
            var id = uri.pathSegments[1];
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ThoughtEditorScreen(id: id),
              ),
            );
          }

          // Handle '/'
          return MaterialPageRoute(
            builder: (context) => const ThoughtListScreen(),
          );
        },
      );
    }
  }
}
