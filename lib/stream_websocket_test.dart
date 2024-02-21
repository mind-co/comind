import 'dart:math';

import 'package:comind/menu_bar.dart';
import 'package:comind/notification_display.dart';
import 'package:flutter/gestures.dart';
import 'package:line_icons/line_icons.dart';
import 'package:logging/logging.dart';
import 'package:comind/api.dart';
import 'package:comind/bottom_sheet.dart';
import 'package:comind/colors.dart';
import 'package:comind/hover_icon_button.dart';
import 'package:comind/input_field.dart';
import 'package:comind/main.dart';
import 'package:comind/main_layout.dart';
import 'package:comind/markdown_display_line.dart'; // new trial display
// import 'package:comind/markdown_display.dart'; // og display
import 'package:comind/misc/comind_logo.dart';
import 'package:comind/misc/util.dart';
import 'package:comind/providers.dart';
import 'package:comind/soul_blob.dart';
import 'package:comind/text_button.dart';
import 'package:comind/text_button_simple.dart';
import 'package:comind/types/thought.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Make a mode-to-title map
Map<UIMode, String> modeToTitle = {
  UIMode.stream: "Stream",
  UIMode.myThoughts: "My thoughts",
  UIMode.public: "Public stream",
  UIMode.consciousness: "Consciousness",
  UIMode.begin: "?",
  UIMode.notifications: "Notifications",
};

class Stream extends StatefulWidget {
  const Stream({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _StreamState createState() => _StreamState();
}

class _StreamState extends State<Stream> {
  //
  final TextEditingController _controller = TextEditingController();

  final _channel = WebSocketChannel.connect(
    Uri.parse('wss://echo.websocket.events'),
  );

  // When opened, initialize the websocket
  @override
  void initState() {
    super.initState();
    // Initialize the websocket
    // Provider.of<WebsocketProvider>(context, listen: false).connect();
  }

  // Ping/pong loop
  void _pingPongLoop() {
    // Send a ping
    _channel.sink.add("ping");

    // Wait a bit
    Future.delayed(Duration(seconds: 5), () {
      // Send a pong
      _channel.sink.add("partner!");

      // Loop
      _pingPongLoop();
    });
  }

  // Build the stream
  @override
  Widget build(BuildContext context) {
    // Start the ping/pong loop
    _pingPongLoop();

    // Return a blank thing for now.
    return Scaffold(
      body: StreamBuilder(
        stream: _channel.stream,
        builder: (context, snapshot) {
          return Text(snapshot.hasData ? '${snapshot.data}' : '');
        },
      ),
    );
    // return StreamBuilder<Mode>(
    //   stream: context.read<ModeProvider>().stream,
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       return _buildStream(context, snapshot.data!);
    //     } else {
    //       return Container();
    //     }
    //   },
    // );
  }
}
