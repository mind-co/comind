import 'package:comind/colors.dart';
import 'package:comind/markdown_display_line.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/providers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class NotificationDisplay extends StatefulWidget {
  ComindNotification notification;

  NotificationDisplay({required this.notification, Key? key}) : super(key: key);

  @override
  _NotificationDisplayState createState() => _NotificationDisplayState();
}

class _NotificationDisplayState extends State<NotificationDisplay> {
  @override
  Widget build(BuildContext context) {
    // Build your UI here using the notification object
    // return Card(
    //   child: ListTile(
    //     title: Text(widget.notification.message),
    //     subtitle: Text(widget.notification.createdAt.toString()),
    //   ),
    // );

    // This one's pretty good. I like the serifs.
    // final titleStyle = GoogleFonts.dmSerifDisplay(
    //     fontSize: 24,
    //     fontWeight: FontWeight.w400,
    //     color:
    //         Provider.of<ComindColorsNotifier>(context).colorScheme.onBackground
    //     // .withOpacity(0.7),
    //     );

    // Next up is abril fatface
    // final titleStyle = GoogleFonts.bungee(
    //     fontSize: 20,
    //     fontWeight: FontWeight.w300,
    //     color:
    //         Provider.of<ComindColorsNotifier>(context).colorScheme.onBackground
    //     // .withOpacity(0.7),
    //     );

    final titleStyle = Provider.of<ComindColorsNotifier>(context)
        .textTheme
        .bodyMedium!
        .copyWith(
          fontWeight: FontWeight.w600,
          color: Provider.of<ComindColorsNotifier>(context)
              .colorScheme
              .onBackground,
        );

    return coThought(
        context, widget.notification.message ?? "", "Notification");

    return Material(
      child: InkWell(
        onTap: () {
          // Handle notification tap

          // debug: toggle read status

          setState(() {
            widget.notification.readStatus = !widget.notification.readStatus;
          });
        },
        child: Opacity(
          opacity: widget.notification.readStatus ? 0.5 : 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 8, 0),
                        child: Text(
                            widget.notification.message ??
                                "Thinking about this notification...",
                            style: Provider.of<ComindColorsNotifier>(context)
                                .textTheme
                                .bodyMedium
                            // style: TextStyle(
                            //   fontWeight: widget.notification.readStatus
                            //       ? FontWeight.normal
                            //       : FontWeight.bold,
                            // ),
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 8, 0),
                        child: Text(
                          formatTimestamp(
                              widget.notification.createdAt.toString()),
                          // widget.notification.createdAt.toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
