import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:main/post.dart';
import 'package:main/widgets.dart';
import 'home_page.dart';

class SendTile {
  final String user;
  bool value;

  SendTile(this.user, {this.value = false});
}

class SendPost extends StatefulWidget {
  //*user is the eprson sending the post
  final String user;
  final Post post;
  SendPost(this.user, this.post);

  @override
  _SendPostState createState() => _SendPostState();
}

class _SendPostState extends State<SendPost> {
  List<SendTile> users = [];
  List<SendTile> virgins = [];
  List<String> contains = [];

  //updating the db
  //doing the same thing for to whom and the user itself
  //and then again for the virgins
  //should convert this inta a fuction
  void done() async {
    users.forEach((element) {
      if (element.value == true) {
        databaseReference.child("messages/" + widget.user + "/" + element.user).update({
          "last": "Sent a post by " + widget.post.userName,
          "time": -DateTime.now().microsecondsSinceEpoch,
        });
        databaseReference.child("messages/" + element.user + "/" + widget.user).update({
          "last": "Sent a post by " + widget.post.userName,
          "time": -DateTime.now().microsecondsSinceEpoch,
          'unseen': ServerValue.increment(1)
        });
        databaseReference.child('messages/' + widget.user + '/' + element.user).push().set({
          'user': widget.user,
          'postId': widget.post.rand,
          'postUser': widget.post.userName,
          'isPost': true,
          "time": DateTime.now().millisecondsSinceEpoch
        });
      }
      if (element.value == true) {
        databaseReference.child('messages/' + element.user + '/' + widget.user).push().set({
          'user': widget.user,
          'postId': widget.post.rand,
          'postUser': widget.post.userName,
          'isPost': true,
          "time": DateTime.now().millisecondsSinceEpoch
        });
      }
    });
    virgins.forEach((element) {
      if (element.value == true) {
        databaseReference.child("messages/" + widget.user + "/" + element.user).update({
          "last": "Sent a post by " + " " + widget.post.userName,
          "time": -DateTime.now().microsecondsSinceEpoch,
        });
        databaseReference.child("messages/" + element.user + "/" + widget.user).update({
          "last": "Sent a post by " + widget.post.userName,
          "time": -DateTime.now().microsecondsSinceEpoch,
          'unseen': ServerValue.increment(1)
        });
        databaseReference.child('messages/' + widget.user + '/' + element.user).push().set({
          'user': widget.user,
          'postId': widget.post.rand,
          'postUser': widget.post.userName,
          'isPost': true,
          "time": DateTime.now().millisecondsSinceEpoch
        });
        databaseReference.child('messages/' + element.user + '/' + widget.user).push().set({
          'user': widget.user,
          'postId': widget.post.rand,
          'postUser': widget.post.userName,
          'isPost': true,
          "time": DateTime.now().millisecondsSinceEpoch
        });
      }
    });
  }

  getList() async {
    DataSnapshot list = await databaseReference.child("messages/" + widget.user).once();
    if (list.value != null) {
      databaseReference
          .child("messages/" + widget.user)
          .orderByChild('time')
          .onChildAdded
          .listen((Event event) async {
        if (!mounted) return;
        setState(() {
          this.users.add(SendTile(event.snapshot.key));
          this.contains.add(event.snapshot.key);
        });
      });
    }

    DataSnapshot data =
        await databaseReference.child("user_details/" + widget.user).child("following").once();
    data.value.forEach((value) {
      if (!contains.contains(value) && value != widget.user)
        setState(() {
          this.virgins.add(SendTile(value));
        });
    });
  }

  @override
  void initState() {
    super.initState();
    getList();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.user);
    return Scaffold(
      appBar: AppBar(
        title: Text('Send'),
        actions: [
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              done();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: ListView.builder(
        // ignore: missing_return
        itemCount: virgins.length + users.length + 1,
        // ignore: missing_return
        itemBuilder: (context, index) {
          if (index < users.length)
            return CheckboxListTile(
              controlAffinity: ListTileControlAffinity.trailing,
              secondary: FutureBuilder(
                future: getPfp(users[index].user),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.toString().isNotEmpty)
                      return ClipOval(
                        child: Image.network(
                          snapshot.data,
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                      );
                    else
                      return Icon(
                        Icons.account_circle,
                        size: 40,
                      );
                  }
                  return CircularProgressIndicator();
                },
              ),
              activeColor: Colors.pink,
              title: Text(
                users[index].user,
                style: TextStyle(fontSize: 20),
              ),
              onChanged: (value) {
                setState(() {
                  users[index].value = !users[index].value;
                });
              },
              value: users[index].value,
            );
          else if (index == users.length && virgins.length != 0)
            return Divider(
              height: 50,
              thickness: 1.2,
              indent: 20,
              endIndent: 20,
            );
          else if (virgins.length != 0)
            return CheckboxListTile(
              controlAffinity: ListTileControlAffinity.trailing,
              secondary: FutureBuilder(
                future: getPfp(virgins[index - (users.length + 1)].user),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.toString().isNotEmpty)
                      return ClipOval(
                        child: Image.network(
                          snapshot.data,
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                      );
                    else
                      return Icon(
                        Icons.account_circle,
                        size: 40,
                      );
                  }
                  return CircularProgressIndicator();
                },
              ),
              title: Text(
                virgins[index - (users.length + 1)].user,
                style: TextStyle(fontSize: 20),
              ),
              onChanged: (value) {
                setState(() {
                  virgins[index - (users.length + 1)].value = !virgins[index - (users.length + 1)].value;
                });
              },
              activeColor: Colors.pink,
              value: virgins[index - (users.length + 1)].value,
            );
        },
      ),
    );
  }
}
