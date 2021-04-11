import 'package:flutter/material.dart';
import 'package:main/creds_database.dart';

class MessagePage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: databaseReference.child("messages/").once(),
        builder: (BuildContext context, AsyncSnapshot _snapshot) {
          return Text('poti');
        });
  }
}
