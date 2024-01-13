// import 'package:intl/intl.dart';
import 'package:comind/colors.dart';
import 'package:comind/providers.dart';
import 'package:comind/types/thought.dart';
import 'package:flutter/material.dart';
import 'package:comind/misc/comind_logo.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

String formatTimestamp(String timestamp) {
  DateTime now = DateTime.now();
  DateTime dateTime = DateTime.parse(timestamp);
  Duration difference = now.difference(dateTime);

  if (difference.inDays > 360) {
    var yeardiff = (difference.inDays / 360).floor();
    return '$yeardiff year${yeardiff > 1 ? 's' : ''} ago';
  } else if (difference.inDays > 30) {
    var monthdiff = (difference.inDays / 30).floor();
    return '$monthdiff month${monthdiff > 1 ? 's' : ''} ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inMinutes >= 5) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
  } else {
    return '';
  }
}

String exactTimestamp(String timestamp) {
  DateTime dateTime = DateTime.parse(timestamp);

  // Return in Month Day, Year -- Hour:Minute format
  return DateFormat('MMMM d, y HH:mm').format(dateTime);
}

// App bar widget
AppBar comindAppBar(BuildContext context) {
  // Get the colors
  ComindColorsNotifier colors = Provider.of<ComindColorsNotifier>(context);

  // Determine whether to use the long or short logo
  var title = Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      MediaQuery.of(context).size.width > ComindColors.maxWidth
          ? ComindLogo(
              key: UniqueKey(),
              colors: colors,
            )
          : ComindShortLogo(
              key: UniqueKey(),
              colors: colors,
            ),
      // Text(
      //   isPublic,
      //   style: colors.textTheme.titleSmall,
      // ),
      // MSmall grey divider
      //
    ],
  );

  // Determine when to use
  return AppBar(
    backgroundColor: Colors.transparent,
    // backgroundColor: Colors.white,

    // If the width of the screen is less than 550 pixels, use the
    // ComindLogo class, otherwise use the original definition
    title: title,
    centerTitle: true,
    scrolledUnderElevation: 0,
    elevation: 0,

    // Add toolbar
    toolbarHeight: 90,
    actions: [
      // Add dark mode toggle
      IconButton(
        icon: colors.darkMode
            ? const Icon(Icons.dark_mode)
            : const Icon(Icons.light_mode),
        onPressed: () {
          Provider.of<ComindColorsNotifier>(context, listen: false)
              .toggleTheme(!colors.darkMode);
        },
      ),
    ],
  );
}

String getToken(BuildContext context) {
  print(Provider.of<AuthProvider>(context, listen: false).isLoggedIn);
  print("Token: " +
      Provider.of<AuthProvider>(context, listen: false).token.toString());
  return Provider.of<AuthProvider>(context, listen: false).token;
}

Color getPrimaryColor(BuildContext context) {
  return Provider.of<ComindColorsNotifier>(context, listen: false)
      .currentColors
      .primaryColor;
}

Color getSecondaryColor(BuildContext context) {
  return Provider.of<ComindColorsNotifier>(context, listen: false)
      .currentColors
      .secondaryColor;
}

Color getTertiaryColor(BuildContext context) {
  return Provider.of<ComindColorsNotifier>(context, listen: false)
      .currentColors
      .tertiaryColor;
}

TextTheme getTextTheme(BuildContext context) {
  return Provider.of<ComindColorsNotifier>(context, listen: false).textTheme;
}

Thought? getTopOfMind(BuildContext context) {
  return Provider.of<ThoughtsProvider>(context, listen: false).topOfMind;
}
