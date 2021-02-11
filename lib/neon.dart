import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'post.dart';
import 'home_page.dart';

class Neon {
  final String post;
  final String user;
  final String owner;
  Neon(this.post, this.user, this.owner);
  Future<bool> monthExists() async {
    DataSnapshot neon = await databaseReference
        .child('Neons/' + owner)
        .child(DateTime.now().year.toString())
        .child(DateTime.now().month.toString())
        .once();
    return neon.value == null ? false : true;
  }

  void toDatabase() async {
    databaseReference
        .child('Neons/' + owner)
        .child(DateTime.now().year.toString())
        .child(DateTime.now().month.toString())
        .set({"post": this.post, "user": this.user});
  }
}

class NeonPage extends StatefulWidget {
  final String user;
  final String visitor;
  final List<Post> neons;
  NeonPage(this.user, this.visitor, this.neons);
  @override
  _NeonPageState createState() => _NeonPageState();
}

class _NeonPageState extends State<NeonPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink,
          title: Text(
            "x" + 's' + ' Neons',
            style: TextStyle(fontSize: 25),
          ),
        ),
        body: PostList(widget.neons, widget.visitor));
  }
}
