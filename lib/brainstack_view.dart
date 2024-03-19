import 'package:comind/api.dart';
import 'package:comind/main_layout.dart';
import 'package:comind/misc/loading.dart';
import 'package:comind/misc/util.dart';
import 'package:flutter/material.dart';

class BrainstackLoader extends StatelessWidget {
  final String? id;
  final Brainstack? brainstack;

  BrainstackLoader({this.id, this.brainstack});

  // Future<Brainstack> _fetchBrainstack(BuildContext context, String id) {
  //   // Fetch the brainstack
  // }

  @override
  Widget build(BuildContext context) {
    return Text("Sorry this is not implemented yet");
    // return FutureBuilder(
    //     future: _fetchBrainstack(id!),
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.done) {
    //         return BrainstackView(brainstack: snapshot.data!);
    //       } else {
    //         return const Loading();
    //       }
    //     });
  }
}

class Brainstack {
  final String title;
  final String description;
  final Color color;
  List<String> thoughtIds;

  Brainstack(
      {required this.thoughtIds,
      this.title = '',
      this.description = '',
      this.color = Colors.white30});
}

class BrainstackView extends StatefulWidget {
  final Brainstack brainstack;

  BrainstackView({required this.brainstack});

  @override
  _BrainstackViewState createState() => _BrainstackViewState();
}

class _BrainstackViewState extends State<BrainstackView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: comindAppBar(context,
          title: appBarTitle(widget.brainstack.title, context)),
      body: SizedBox(
        child: ListView.builder(
          itemCount: widget.brainstack.thoughtIds.length,
          itemBuilder: (context, index) {
            String thoughtId = widget.brainstack.thoughtIds[index];
            return Text(thoughtId);
          },
        ),
      ),
    );
  }
}
