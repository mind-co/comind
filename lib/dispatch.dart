// Dispatches the user to where the need to go.
// If not logged in, send them to the login page.
// If logged in, send them to the home page.
import 'package:comind/login.dart';
import 'package:comind/main.dart';
import 'package:comind/misc/comind_logo.dart';
import 'package:comind/misc/loading.dart';
import 'package:comind/providers.dart';
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
        pages: const [
          MaterialPage(
            child: ThoughtListScreen(),
          ),
        ],
        onPopPage: (route, result) => route.didPop(result),
      );
    } else {
      return Navigator(
        pages: const [
          MaterialPage(child: ThoughtListScreen()),
          MaterialPage(
            child: LoginScreen(),
          ),
        ],
        onPopPage: (route, result) => route.didPop(result),
      );
    }
  }
}
