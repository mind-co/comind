// import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:comind/misc/comind_logo.dart';
import 'package:comind/providers.dart';
import 'package:comind/comind_div.dart';
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
  } else {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
  }
}

// App bar widget
// Original definition:
// AppBar(
//           backgroundColor: Theme.of(context).colorScheme.background,
//           // backgroundColor: Colors.white,
//           title: ComindLogo(key: UniqueKey()),
//           centerTitle: true,
//           // elevation: 100,
//           scrolledUnderElevation: 0,
//           // Add toolbar
//           toolbarHeight: 100,
//           actions: [
//             // Add dark mode toggle
//             IconButton(
//               icon: const Icon(Icons.dark_mode),
//               onPressed: () {
//                 Provider.of<ThemeProvider>(context, listen: false)
//                     .toggleTheme();
//               },
//             ),
//           ],
//           // bottom: const PreferredSize(
//           //   preferredSize: Size.fromHeight(4.0),
//           //   child: ComindDiv(),
//           // )
//         ),
comindAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Theme.of(context).colorScheme.background,
    // backgroundColor: Colors.white,
    title: ComindLogo(key: UniqueKey()),
    centerTitle: true,
    // elevation: 100,
    scrolledUnderElevation: 0,
    // Add toolbar
    toolbarHeight: 100,
    actions: [
      // Add dark mode toggle
      IconButton(
        icon: const Icon(Icons.dark_mode),
        onPressed: () {
          Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
        },
      ),
    ],
    // bottom: const PreferredSize(
    //   // Make this no wider than 600 pixels with a height of 4
    //   preferredSize: Size.fromHeight(4.0),
    //   child: ComindDiv(),
    // )
  );
}
