import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:main/message.dart';
import 'package:main/widgets.dart';
import 'home_page.dart';

class SendTile {
  final String user;
  final bool value;

  SendTile(this.user, {this.value = false});
}

class SendPost extends StatefulWidget {
  //*user is the eprson sending the post
  final String user;
  SendPost(this.user);

  @override
  _SendPostState createState() => _SendPostState();
}

class _SendPostState extends State<SendPost> {
  List<SendTile> users = [];
  List<SendTile> virgins = [];
  List<String> contains = [];
  getList() async {
    DataSnapshot list =
        await databaseReference.child("messages/" + widget.user).once();
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

    DataSnapshot data = await databaseReference
        .child("user_details/" + widget.user)
        .child("following")
        .once();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Send'),
      ),
      body: ListView.builder(
        // ignore: missing_return
        itemCount: virgins.length + users.length + 1,
        itemBuilder: (context, index) {
          if (index < users.length)
            return ListTile(
              leading: FutureBuilder(
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
              title: Text(
                users[index].user,
                style: TextStyle(fontSize: 20),
              ),
              onTap: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MessagePage(widget.user, users[index].user)),
                );
              },
            );
          else if (index == users.length && virgins.length != 0)
            return Divider(
              height: 50,
              thickness: 1.2,
              indent: 20,
              endIndent: 20,
            );
          else if (virgins.length != 0)
            return ListTile(
                leading: FutureBuilder(
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
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessagePage(widget.user,
                            virgins[index - (users.length + 1)].user),
                      ));
                });
        },
      ),
    );
  }
}
