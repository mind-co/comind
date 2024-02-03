import 'package:comind/misc/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Clock {
  Stream<DateTime> get timeStream {
    return Stream.periodic(Duration(seconds: 1), (_) => DateTime.now());
  }
}

class ClockWidget extends StatefulWidget {
  @override
  _ClockWidgetState createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late Stream<DateTime> _timeStream;

  @override
  void initState() {
    super.initState();
    _timeStream = Clock().timeStream;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _timeStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final time = snapshot.data;
          final formattedTime =
              DateFormat('h:mm a').format(time!).toLowerCase();
          return Text(formattedTime, style: getTextTheme(context).bodyMedium);
        } else {
          return Text('Hey there');
        }
      },
    );
  }
}
