import 'package:flutter/material.dart';
import 'package:main/creds_database.dart';

class Activity extends StatefulWidget {
  final user;
  @override
  _ActivityState createState() => _ActivityState();

  Activity(this.user);
}

class _ActivityState extends State<Activity> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: databaseReference.child("activity/" + widget.user).once(),
      builder: (context, _snapshot) {
        print(_snapshot.data);
      },
    );
  }
}
