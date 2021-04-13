import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:main/creds_database.dart';

class MessageListPage extends StatefulWidget {
  final String user;
  MessageListPage(this.user);

  @override
  _MessageListPageState createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  List<String> users = [];
  getList() async {
    DataSnapshot list =
        await databaseReference.child("messages/" + widget.user).once();
    if (list.value != null) {
      DataSnapshot data = await databaseReference
          .child("user_details/" + widget.user)
          .child("following")
          .once();
      print(data.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

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
