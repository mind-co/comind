//////////////////////////////////////////////
/// Login page
///
/// This page is the first page that the user
/// sees when they open the app. It allows the user to
/// log in to their account, or create a new account.
///
/// We use firebase authentication to handle the login
/// and account creation.
///
/// You can read more about firebase authentication here:
/// https://firebase.google.com/docs/auth/flutter/password-auth
///

import 'package:comind/api.dart';
import 'package:comind/bottom_sheet.dart';
import 'package:comind/colors.dart';
import 'package:comind/markdown_display.dart';
import 'package:comind/misc/comind_logo.dart';
import 'package:comind/providers.dart';
import 'package:comind/sign_up.dart';
import 'package:comind/text_button.dart';
import 'package:comind/text_button_simple.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // for the utf8.encode method

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, this.initToSignUp = false}) : super(key: key);

  final bool initToSignUp;

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  bool signUpMode = false;
  bool usernameAvailable = false;
  bool emailAvailable = false;
  static const double cursorWidth = 12;

  final edgeInsets = const EdgeInsets.fromLTRB(12, 16, 12, 16);

  // Initialize the state
  // currently this is only setting signUpMode to true if initToSignUp is true
  @override
  void initState() {
    super.initState();
    if (widget.initToSignUp) {
      signUpMode = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the colors
    var colors = Provider.of<ComindColorsNotifier>(context).colorScheme;

    return Scaffold(
      // ignore: library_private_types_in_public_api
      appBar: AppBar(
        backgroundColor: colors.background,
        // backgroundColor: Colors.white,

        // If the width of the screen is less than 550 pixels, use the
        // ComindLogo class, otherwise use the original definition
        title: ComindLogo(
          key: UniqueKey(),
          colors: Provider.of<ComindColorsNotifier>(context),
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),

      body: signUpMode ? signUpPage(context) : loginPage(context),
      bottomSheet: ComindBottomSheet(),
    );
  }

  String validateUsername(String username) {
    if (username.isEmpty) return "Username cannot be empty";
    if (username.length < 2) return "Username too short";
    if (username.length > 30) return "Username too long";
    if (username.contains(" ")) return "Username cannot contain spaces";
    if (username.contains("@")) return "Username cannot contain @";
    if (username.contains(".")) return "Username cannot contain .";
    if (username.contains("#")) return "Username cannot contain #";
    if (username.contains("\$")) return "Username cannot contain \$";
    if (username.contains("[")) return "Username cannot contain [";
    if (username.contains("]")) return "Username cannot contain ]";
    if (username.contains("/")) return "Username cannot contain /";
    if (username.contains("\\")) return "Username cannot contain \\";
    if (username.contains("%")) return "Username cannot contain %";
    if (username.contains("&")) return "Username cannot contain &";
    if (username.contains("*")) return "Username cannot contain *";
    if (username.contains("(")) return "Username cannot contain (";
    if (username.contains(")")) return "Username cannot contain )";
    if (username.contains("+")) return "Username cannot contain +";
    if (username.contains("=")) return "Username cannot contain =";
    if (username.contains("?")) return "Username cannot contain ?";
    if (username.contains("!")) return "Username cannot contain !";
    if (username.contains(",")) return "Username cannot contain ,";
    if (username.contains(";")) return "Username cannot contain ;";
    if (username.contains(":")) return "Username cannot contain :";
    if (username.contains("<")) return "Username cannot contain <";
    if (username.contains(">")) return "Username cannot contain >";
    if (username.contains("{")) return "Username cannot contain {";
    if (username.contains("}")) return "Username cannot contain }";
    if (username.contains("|")) return "Username cannot contain |";
    if (username.contains("`")) return "Username cannot contain `";
    if (username.contains("~")) return "Username cannot contain ~";
    if (username.contains("'")) return "Username cannot contain '";
    if (username.contains("\"")) return "Username cannot contain \"";

    return "";
  }

  Center loginPage(BuildContext context) {
    var textStyle = TextStyle(
        fontFamily: "Bungee",
        color: Provider.of<ComindColorsNotifier>(context)
            .colorScheme
            .onBackground
            .withAlpha(150));
    return Center(
      child: SizedBox(
        width: ComindColors.maxWidth,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // coThought(context, "Welcome to Comind!"),

              // ALERT DO NOT ENTER SENSITIVE PASSWORDS
              coThought(
                  context,
                  "This is a **test version** of Comind. Do not enter any sensitive passwords. HTTPs does not work yet, so your password will be sent in plain text.",
                  "Warning"),

              // Email field
              Padding(
                padding: edgeInsets,
                child: TextFormField(
                  cursorWidth: cursorWidth,
                  controller: _emailController,
                  onChanged: (value) => setState(() {
                    // signUpMode = value.contains('@');
                  }),
                  // ignore: library_private_types_in_public_api
                  validator: (val) =>
                      !val!.contains('@') ? 'Invalid Email' : null,
                  // ignore: library_private_types_in_public_api
                  onSaved: (val) => _emailController.text = val!,
                  decoration: InputDecoration(
                    labelStyle: textStyle,
                    // ignore: library_private_types_in_public_api
                    border: const OutlineInputBorder(),
                    labelText: 'Email or Username',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Provider.of<ComindColorsNotifier>(context)
                              .colorScheme
                              .onBackground
                              .withAlpha(150),
                          width: 1.0,
                          style: BorderStyle.solid),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Provider.of<ComindColorsNotifier>(context)
                              .colorScheme
                              .onBackground
                              .withAlpha(50),
                          width: 1.0,
                          style: BorderStyle.solid),
                    ),
                    // icon: Icon(
                    //   Icons.mail,
                    //   color: Colors.grey,
                    // ),
                  ),
                ),
              ),

              // Password field
              Padding(
                padding: edgeInsets,
                child: TextFormField(
                  cursorWidth: cursorWidth,
                  controller: _passwordController,
                  // ignore: library_private_types_in_public_api
                  validator: (val) =>
                      val!.length < 6 ? 'Password too short' : null,
                  // ignore: library_private_types_in_public_api
                  onSaved: (val) => _passwordController.text = val!,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelStyle: textStyle,
                    // ignore: library_private_types_in_public_api
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Provider.of<ComindColorsNotifier>(context)
                              .colorScheme
                              .onBackground
                              .withAlpha(150),
                          width: 1.0,
                          style: BorderStyle.solid),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Provider.of<ComindColorsNotifier>(context)
                              .colorScheme
                              .onBackground
                              .withAlpha(50),
                          width: 1.0,
                          style: BorderStyle.solid),
                    ),
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    // icon: Icon(
                    //   Icons.lock,
                    //   color: Colors.grey,
                    // ),
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  // padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Login button
                      loginButton(1),

                      // Divider line
                      // horizontalSpacerLine(context),

                      //////////////
                      // orTextLoginRow(context),

                      // Vertical spacer
                      Container(
                          height: 16,
                          width: 1,
                          color: Provider.of<ComindColorsNotifier>(context)
                              .colorScheme
                              .onBackground
                              .withAlpha(150)),

                      // Divider line
                      // horizontalSpacerLine(context),

                      //////////////
                      /// Sign up  button
                      ///
                      signupButton(0.5),
                    ],
                  ),
                ),
              ),

              // sorry(),
            ],
          ),
        ),
      ),
    );
  }

  SingleChildScrollView signUpPage(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: SizedBox(
          width: ComindColors.maxWidth,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ALERT DO NOT ENTER SENSITIVE PASSWORDS
                coThought(
                    context,
                    "This is a **test version** of Comind. Do not enter any sensitive passwords. HTTPs does not work yet, so your password will be sent in plain text.",
                    "Warning"),

                Text(
                  "Sign up",
                  style: Provider.of<ComindColorsNotifier>(context)
                      .textTheme
                      .titleSmall,
                ),

                // Username field
                Padding(
                  padding: edgeInsets,
                  child: TextFormField(
                    cursorWidth: cursorWidth,
                    controller: _usernameController,
                    onChanged: (value) async {
                      usernameAvailable = (!await userExists(value));
                      setState(() {
                        // signUpMode = value.contains('@');
                        // Check if the username is available
                        print("Username available: $usernameAvailable");
                      });
                    },
                    // ignore: library_private_types_in_public_api
                    validator: (val) => validateUsername(val!),
                    // ignore: library_private_types_in_public_api
                    onSaved: (val) => _usernameController.text = val!,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: _usernameController.text.isEmpty
                              ? Provider.of<ComindColorsNotifier>(context)
                                  .colorScheme
                                  .onBackground
                                  .withAlpha(150)
                              : usernameAvailable
                                  ? ComindColors.primaryColorDefault
                                  : ComindColors.secondaryColorDefault),
                      // ignore: library_private_types_in_public_api
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Provider.of<ComindColorsNotifier>(context)
                                .colorScheme
                                .onBackground
                                .withAlpha(150),
                            width: 1.0,
                            style: BorderStyle.solid),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Provider.of<ComindColorsNotifier>(context)
                                .colorScheme
                                .onBackground
                                .withAlpha(50),
                            width: 1.0,
                            style: BorderStyle.solid),
                      ),
                      border: OutlineInputBorder(),
                      labelText: _usernameController.text.isEmpty
                          ? 'Username'
                          : usernameAvailable
                              ? 'Username available'
                              : 'Username taken',
                    ),
                  ),
                ),

                // Email field
                Padding(
                  padding: edgeInsets,
                  child: TextFormField(
                    cursorWidth: cursorWidth,
                    controller: _emailController,
                    onChanged: (value) async {
                      emailAvailable = (!await emailExists(value));
                      setState(() {});
                    },
                    // ignore: library_private_types_in_public_api
                    validator: (val) =>
                        !val!.contains('@') ? 'Invalid Email' : null,
                    // ignore: library_private_types_in_public_api
                    onSaved: (val) => _emailController.text = val!,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: _emailController.text.isEmpty
                            ? Provider.of<ComindColorsNotifier>(context)
                                .colorScheme
                                .onBackground
                                .withAlpha(150)
                            : EmailValidator.validate(_emailController.text)
                                ? emailAvailable
                                    ? ComindColors.primaryColorDefault
                                    : ComindColors.secondaryColorDefault
                                : ComindColors.secondaryColorDefault,
                      ),
                      // ignore: library_private_types_in_public_api
                      border: OutlineInputBorder(),
                      labelText: _emailController.text.isEmpty
                          ? 'Email'
                          : EmailValidator.validate(_emailController.text)
                              ? emailAvailable
                                  ? 'Email available'
                                  : 'Email taken'
                              : 'Email not valid',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Provider.of<ComindColorsNotifier>(context)
                                .colorScheme
                                .onBackground
                                .withAlpha(150),
                            width: 1.0,
                            style: BorderStyle.solid),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Provider.of<ComindColorsNotifier>(context)
                                .colorScheme
                                .onBackground
                                .withAlpha(50),
                            width: 1.0,
                            style: BorderStyle.solid),
                      ),
                      // icon: Icon(
                      //   Icons.mail,
                      //   color: Colors.grey,
                      // ),
                    ),
                  ),
                ),

                // Divider
                Padding(
                  padding: edgeInsets,
                  child: const Divider(
                    height: 2,
                    color: Colors.grey,
                  ),
                ),

                // Password field
                Padding(
                  padding: edgeInsets,
                  child: TextFormField(
                    cursorWidth: cursorWidth,
                    controller: _passwordController,
                    // ignore: library_private_types_in_public_api
                    validator: (val) =>
                        val!.length < 6 ? 'Password too short' : null,
                    // ignore: library_private_types_in_public_api
                    onSaved: (val) => _passwordController.text = val!,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: Provider.of<ComindColorsNotifier>(context)
                              .colorScheme
                              .onBackground
                              .withAlpha(150)),
                      // ignore: library_private_types_in_public_api
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Provider.of<ComindColorsNotifier>(context)
                                .colorScheme
                                .onBackground
                                .withAlpha(150),
                            width: 1.0,
                            style: BorderStyle.solid),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Provider.of<ComindColorsNotifier>(context)
                                .colorScheme
                                .onBackground
                                .withAlpha(50),
                            width: 1.0,
                            style: BorderStyle.solid),
                      ),
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      // icon: Icon(
                      //   Icons.lock,
                      //   color: Colors.grey,
                      // ),
                    ),
                  ),
                ),

                // Password confirmation field
                if (signUpMode)
                  Center(
                    child: Padding(
                      padding: edgeInsets,
                      child: TextFormField(
                        cursorWidth: cursorWidth,
                        controller: _passwordConfirmationController,
                        // ignore: library_private_types_in_public_api
                        validator: (val) =>
                            val!.length < 6 ? 'Password too short' : null,
                        // ignore: library_private_types_in_public_api
                        onSaved: (val) => _passwordController.text = val!,
                        obscureText: true,
                        decoration: InputDecoration(
                          // ignore: library_private_types_in_public_api
                          border: OutlineInputBorder(),
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(
                              color: Provider.of<ComindColorsNotifier>(context)
                                  .colorScheme
                                  .onBackground
                                  .withAlpha(150)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                    Provider.of<ComindColorsNotifier>(context)
                                        .colorScheme
                                        .onBackground
                                        .withAlpha(150),
                                width: 1.0,
                                style: BorderStyle.solid),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                    Provider.of<ComindColorsNotifier>(context)
                                        .colorScheme
                                        .onBackground
                                        .withAlpha(50),
                                width: 1.0,
                                style: BorderStyle.solid),
                          ),
                          // icon: Icon(
                          //   Icons.lock,
                          //   color: Colors.grey,
                          // ),
                        ),
                      ),
                    ),
                  ),

                if (_passwordController.text !=
                    _passwordConfirmationController.text)
                  Padding(
                    padding: edgeInsets,
                    child: const Text("Passwords don't match",
                        style: TextStyle(color: Colors.red)),
                  ),

                Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    // padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //////////////
                        /// Sign up  button
                        ///
                        signupButton(1),

                        // Divider line
                        // horizontalSpacerLine(context),

                        //////////////
                        // orTextLoginRow(context),

                        // Vertical spacer
                        Container(
                            height: 16,
                            width: 1,
                            color: Provider.of<ComindColorsNotifier>(context)
                                .colorScheme
                                .onBackground
                                .withAlpha(150)),

                        // Divider line
                        // horizontalSpacerLine(context),

                        // Login button
                        loginButton(0.4),
                      ],
                    ),
                  ),
                ),

                sorry(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding sorry() {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Center(
        child: Text(
            "(also I'm sorry if this is broken, I'm still working on it)",
            style: TextStyle(fontSize: 12)),
      ),
    );
  }

  Padding orTextLoginRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text("or",
          style: TextStyle(
              color: Provider.of<ComindColorsNotifier>(context)
                  .colorScheme
                  .onBackground
                  .withAlpha(150))),
    );
  }

  Expanded horizontalSpacerLine(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        color: Provider.of<ComindColorsNotifier>(context)
            .colorScheme
            .onBackground
            .withAlpha(16),
      ),
    );
  }

  Padding loginButton(double opacity) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButtonSimple(
        text: "Login",
        onPressed: () async {
          setState(() {
            signUpMode = false;
          });

          // Send the login request
          var loginResult =
              await login(_emailController.text, _passwordController.text);

          // If the login was successful, go to the home page
          // if (loginResult.success && loginResult.token != null) {
          //   SharedPreferences prefs = await SharedPreferences.getInstance();
          //   await prefs.setString('token', loginResult.token!);
          //   Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => const MyHomePage(title: 'Comind'),
          //     ),
          //   );
          // }

          // If the login was unsuccessful, show an error message
          // ignore: use_build_context_synchronously
          if (loginResult.success && loginResult.token != null) {
            SharedPreferences.getInstance().then((value) => {
                  value.setString('token', loginResult.token!),
                  Provider.of<AuthProvider>(context, listen: false).login()
                });

            if (mounted) {
              // Make the auth provider update
              Provider.of<AuthProvider>(context, listen: false).login();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  showCloseIcon: true,
                  content: Text("Login successful"),
                ),
              );
            }

            // Go home, '/'
            // ignore: use_build_context_synchronously
            // Navigator.of(context).pushReplacement<void, MaterialPageRoute>(
            //   MaterialPageRoute(
            //     builder: (context) => const ThoughtListScreen(),
            //   ),
            // );
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop(false);
          } else {
            // ignore: library_private_types_in_public_api, use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                showCloseIcon: true,
                content: Text("${loginResult.message}"),
              ),
            );
          }
        },
      ),
    );
  }

  Padding signupButton(double opacity) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButtonSimple(
        text: "Sign up",
        onPressed: () async {
          if (signUpMode) {
            // Validate the fields

            // Check that the username is valid
            if (validateUsername(_usernameController.text) != "" &&
                !usernameAvailable) {
              // ignore: library_private_types_in_public_api
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(validateUsername(_usernameController.text)),
                ),
              );
              return;
            }

            // Check that the passwords match
            if (_passwordController.text !=
                _passwordConfirmationController.text) {
              // ignore: library_private_types_in_public_api
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Passwords don't match"),
                ),
              );
              return;
            }

            // Check that the passwords are long enough
            if (_passwordController.text.length < 6 ||
                _passwordConfirmationController.text.length < 6) {
              // ignore: library_private_types_in_public_api
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Password too short"),
                ),
              );
              return;
            }

            // Check that the email is valid
            if (!EmailValidator.validate(_emailController.text)) {
              // ignore: library_private_types_in_public_api
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Invalid email"),
                ),
              );
              return;
            }

            // if (!EmailValidator.validate(_emailController.text)) ||
            //     validateUsername(_usernameController.text) !=
            //         "" || // If "", it's valid
            //     _passwordController.text !=
            //         _passwordConfirmationController.text ||
            //     _passwordConfirmationController.text.length < 6 ||
            //     _passwordController.text.length < 6) {
            //   // ignore: library_private_types_in_public_api
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     const SnackBar(
            //       content: Text('Please fill out all fields'),
            //     ),
            //   );
            //   return;
            // }

            // generate bcrypt hash
            final String hashed =
                BCrypt.hashpw(_passwordController.text, BCrypt.gensalt());

            var newUserResult = await newUser(
                _usernameController.text, _emailController.text, hashed);

            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("New user result: $newUserResult"),
              ),
            );
          } else {
            setState(() {
              signUpMode = true;
            });
          }
        },
      ),
    );
  }
}
