// Dispatches the user to where the need to go.
// If not logged in, send them to the login page.
// If logged in, send them to the home page.
import 'package:comind/login.dart';
import 'package:comind/main.dart';
import 'package:comind/misc/comind_logo.dart';
import 'package:comind/misc/loading.dart';
import 'package:comind/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dispatch extends StatelessWidget {
  const Dispatch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the auth provider
    final authProvider = Provider.of<AuthProvider>(context);

    // Return loading screen
    if (true) {
      //authProvider.isLoggedIn == null) {
      return const Scaffold(
        body: Center(
          child: ComindIsLoading(),
        ),
      );
    }

    // If the user is logged in, send them to the home page
    // if (authProvider.isLoggedIn) {
    //   return Navigator(
    //     pages: const [
    //       MaterialPage(
    //         child: ThoughtListScreen(),
    //       ),
    //     ],
    //     onPopPage: (route, result) => route.didPop(result),
    //   );
    // }

    // // Otherwise, send them to the login page
    // return Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => LoginScreen()),
    // );
  }
}
