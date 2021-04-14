import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:main/creds_database.dart';
import 'package:main/widgets.dart';

class Message {
  final String sender;
  final String message;
  Message(this.sender, this.message);
}

class MessageListPage extends StatefulWidget {
  final String user;
  MessageListPage(this.user);

  @override
  _MessageListPageState createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  List users = [];
  List extra = [];
  int messages = 0;
  getList() async {
    DataSnapshot list =
        await databaseReference.child("messages/" + widget.user).once();
    if (list.value != null) {
      list.value.forEach((key, value) {
        print(key);
        setState(() {
          messages++;
          this.users.add(key);
        });
      });
    }
    DataSnapshot data = await databaseReference
        .child("user_details/" + widget.user)
        .child("following")
        .once();
    data.value.forEach((value) {
      if (!users.contains(value) && value != widget.user)
        setState(() {
          this.extra.add(value);
        });
    });
    print(extra);
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
        title: Text("Chats"),
      ),

      //! pls send help
      body: ListView.separated(
        itemCount: users.length + extra.length + 1,
        padding: EdgeInsets.all(8),
        separatorBuilder: (context, index) => Divider(),
        // ignore: missing_return
        itemBuilder: (context, index) {
          if (index < users.length)
            return ListTile(
                leading: FutureBuilder(
                  future: getPfp(users[index]),
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
                  users[index],
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MessagePage(widget.user, users[index])));
                });
          else if (index == users.length && extra.length != 0)
            return Container(
              height: MediaQuery.of(context).size.height / 12,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                gradient: LinearGradient(
                  colors: [
                    Colors.purple,
                    Colors.pink[500],
                    Colors.pink[300],
                  ],
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Start a Conversation...",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w600),
                ),
              ),
            );
          else if (extra.length != 0)
            return ListTile(
                leading: FutureBuilder(
                  future: getPfp(extra[index - (users.length + 1)]),
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
                  extra[index - (users.length + 1)],
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MessagePage(
                              widget.user, extra[index - (users.length + 1)])));
                });
        },
      ),
    );
  }
}

class MessagePage extends StatefulWidget {
  final String user;
  final String toWhom;
  MessagePage(this.user, this.toWhom);
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  List<Message> chats = [];
  bool virgin = true;
  TextEditingController mainCont = new TextEditingController();

  getChats() async {
    databaseReference
        .child("messages/" + widget.user + "/" + widget.toWhom)
        .orderByChild('time')
        .onChildAdded
        .listen((Event event) async {
      Map chat = event.snapshot.value;
      Message msg = Message(chat["user"], chat["message"]);
      setState(() {
        chats.add(msg);
      });
    }).onError((e) {
      print(e + "yeeeeeeeeet");
    });
    print("hiiiiiiiiii");
  }

  @override
  void initState() {
    super.initState();
    getChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.toWhom),
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder(
                  stream: databaseReference
                      .child("messages/" + widget.user + "/" + widget.toWhom)
                      .onChildAdded,
                  builder: (context, event) {
                    return ListView.builder(
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          return Align(
                              alignment: chats[index].sender == widget.user
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Card(
                                margin: EdgeInsets.fromLTRB(4, 4, 7, 4),
                                color: chats[index].sender == widget.user
                                    ? Colors.pink
                                    : Colors.white60,
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(7, 3, 7, 3),
                                  constraints: BoxConstraints(
                                      maxWidth: 3 *
                                          (MediaQuery.of(context).size.width) /
                                          4),
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    chats[index].message,
                                    style: TextStyle(
                                        color:
                                            chats[index].sender == widget.user
                                                ? Colors.white
                                                : Colors.black),
                                  ),
                                ),
                              ));
                        });
                  })),
          TextField(
            controller: mainCont,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.message),
              labelText: "Send a message..",
              suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  splashColor: Colors.pinkAccent[100],
                  onPressed: () async {
                    if (mainCont.text.isNotEmpty) {
                      await databaseReference
                          .child(
                              "messages/" + widget.user + "/" + widget.toWhom)
                          .update(
                              {"time": DateTime.now().microsecondsSinceEpoch});
                      await databaseReference
                          .child(
                              "messages/" + widget.user + "/" + widget.toWhom)
                          .push()
                          .set({
                        "user": widget.user,
                        "message": mainCont.text,
                        "time": DateTime.now().millisecondsSinceEpoch
                      });
                      await databaseReference
                          .child(
                              "messages/" + widget.toWhom + "/" + widget.user)
                          .push()
                          .set({
                        "user": widget.user,
                        "message": mainCont.text,
                        "time": DateTime.now().millisecondsSinceEpoch
                      });
                      await databaseReference
                          .child(
                              "messages/" + widget.toWhom + "/" + widget.user)
                          .update(
                              {"time": DateTime.now().microsecondsSinceEpoch});
                    }

                    mainCont.clear();
                    FocusScope.of(context).unfocus();
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
