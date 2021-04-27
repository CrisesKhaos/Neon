import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:main/comments.dart';
import 'package:main/database.dart';
import 'package:main/post.dart';
import 'package:main/user_profile_page.dart';
import 'package:main/widgets.dart';

class Message {
  String sender;
  String message;
  final bool isPost;
  String postId;
  String postUser;
  final String id;
  Message(
    this.isPost,
    this.id, {
    this.sender = '',
    this.message = '',
    this.postId = '',
    this.postUser = '',
  });
}

class MessageListPage extends StatefulWidget {
  final String user;
  MessageListPage(this.user);

  @override
  _MessageListPageState createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  //!turn this into a class
  List users = [];
  List<int> unseen = [];
  List lastMessages = [];
  List extra = [];

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
          this.unseen.add(event.snapshot.value['unseen']);
          this.users.add(event.snapshot.key);
          this.lastMessages.add(event.snapshot.value['last']);
        });
      });
    }

    DataSnapshot data =
        await databaseReference.child("user_details/" + widget.user).child("following").once();
    data.value.forEach((value) {
      if (!users.contains(value) && value != widget.user)
        setState(() {
          this.extra.add(value);
        });
    });
  }

  @override
  void initState() {
    super.initState();
    getList();
  }

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
              onTap: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MessagePage(widget.user, users[index])),
                );
              },
              trailing: unseen[index] != 0
                  ? Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width / 15,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.pink,
                              Colors.purple,
                            ],
                          ),
                          color: Colors.blueGrey),
                      child: Text(
                        unseen[index].toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ))
                  : null,
              subtitle: lastMessages[index] != null
                  ? Text(
                      lastMessages[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
            );
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
                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w600),
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
                          builder: (context) => MessagePage(widget.user, extra[index - (users.length + 1)])));
                });
        },
      ),
    );
  }
}

//? The second page starts *actual chats
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
      if (chat["isPost"] == null) {
        Message msg = Message(
          false,
          event.snapshot.key,
          sender: chat["user"],
          message: chat["message"],
        );

        setState(() {
          if (virgin) virgin = false;
          chats.add(msg);
        });
      } else {
        Message msg = Message(
          true,
          event.snapshot.key,
          sender: chat['user'],
          postId: chat['postId'],
          postUser: chat['postUser'],
        );
        setState(() {
          chats.add(msg);
        });
      }
    }).onError((e) {
      print(e + "yeeeeeeeeet");
    });
  }

  Future<Post> getPost(int index) async {
    DataSnapshot postV =
        await databaseReference.child("posts/" + chats[index].postUser + "/" + chats[index].postId).once();
    Post post = createPost(chats[index].postUser, postV.value, postV.key);
    return post;
  }

  @override
  void initState() {
    super.initState();
    getChats();
  }

  @override
  Widget build(BuildContext context) {
    //! check if 0 or not so u dnt have to write evry build

    databaseReference.child("messages/" + widget.user + "/" + widget.toWhom).update({'unseen': 0});
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 35,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: FutureBuilder(
                future: getPfp(widget.toWhom),
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
                        size: 30,
                      );
                  }
                  return Container();
                },
              ),
            ),
            Text(widget.toWhom),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder(
                  stream:
                      databaseReference.child("messages/" + widget.user + "/" + widget.toWhom).onChildAdded,
                  builder: (context, event) {
                    return ListView.builder(
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          return Align(
                              alignment: chats[index].sender == widget.user
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: chats[index].isPost
                                  //? this is the post one
                                  ? Slidable(
                                      actionPane: SlidableBehindActionPane(),
                                      secondaryActions: [
                                        IconButton(
                                            constraints: BoxConstraints(minWidth: 50),
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red[600],
                                            ),
                                            onPressed: () async {
                                              setState(() {
                                                chats.removeAt(index);
                                              });

                                              await databaseReference
                                                  .child("messages/" + widget.user + "/" + widget.toWhom)
                                                  .child(chats[index].id)
                                                  .remove();

                                              await databaseReference
                                                  .child("messages/" + widget.toWhom + "/" + widget.user)
                                                  .child(chats[index].id)
                                                  .remove();
                                            })
                                      ],
                                      actionExtentRatio: 1 / 10,
                                      child: GestureDetector(
                                        onTap: () async {
                                          Post postPush = await getPost(index);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => CommentsPage(
                                                  postPush,
                                                  widget.user,
                                                  title: "Post",
                                                ),
                                              ));
                                        },
                                        child: FutureBuilder(
                                          future: getPost(index),
                                          builder: (context, post) {
                                            if (post.hasData)
                                              return Container(
                                                constraints: BoxConstraints(
                                                    maxWidth: 3 * (MediaQuery.of(context).size.width) / 4),
                                                margin: EdgeInsets.fromLTRB(4, 4, 7, 4),
                                                child: Card(
                                                  margin: EdgeInsets.all(0),
                                                  color: chats[index].sender == widget.user
                                                      ? Colors.pink
                                                      : Colors.white60,
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Padding(
                                                            child: FutureBuilder(
                                                              future: getPfp(post.data.userName),
                                                              builder: (BuildContext context,
                                                                  AsyncSnapshot snapshot) {
                                                                if (snapshot.hasData) {
                                                                  if (snapshot.data.toString().isNotEmpty)
                                                                    return ClipOval(
                                                                      child: Image.network(
                                                                        snapshot.data,
                                                                        height: 30,
                                                                        width: 30,
                                                                        fit: BoxFit.cover,
                                                                      ),
                                                                    );
                                                                  else
                                                                    return Icon(
                                                                      Icons.account_circle,
                                                                      size: 32,
                                                                    );
                                                                }
                                                                return Container();
                                                              },
                                                            ),
                                                            padding: EdgeInsets.symmetric(
                                                                horizontal: 10, vertical: 5),
                                                          ),
                                                          Align(
                                                            alignment: Alignment.centerLeft,
                                                            child: Padding(
                                                              child: GestureDetector(
                                                                child: Text(
                                                                  post.data.userName,
                                                                  style: TextStyle(
                                                                    color: Colors.black,
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => ProfilePage(
                                                                              post.data.userName, widget.user,
                                                                              solo: true)));
                                                                },
                                                              ),
                                                              padding: EdgeInsets.symmetric(
                                                                  horizontal: 10, vertical: 5),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Image.network(
                                                        post.data.imageUrl,
                                                        loadingBuilder: (BuildContext context, Widget child,
                                                            ImageChunkEvent loadingProgress) {
                                                          if (loadingProgress == null) {
                                                            return child;
                                                          }
                                                          return Center(
                                                            child: CircularProgressIndicator(
                                                              value: loadingProgress.expectedTotalBytes !=
                                                                      null
                                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                                      loadingProgress.expectedTotalBytes
                                                                  : null,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      Align(
                                                        alignment: Alignment.topLeft,
                                                        child: Container(
                                                            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                                            child: RichText(
                                                              maxLines: 1,
                                                              textAlign: TextAlign.left,
                                                              text: TextSpan(
                                                                text: post.data.userName + "  ",
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Colors.black),
                                                                children: [
                                                                  TextSpan(
                                                                      text: post.data.caption,
                                                                      style: TextStyle(
                                                                        fontWeight: FontWeight.normal,
                                                                      ))
                                                                ],
                                                              ),
                                                            )),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            else
                                              return CircularProgressIndicator.adaptive();
                                          },
                                        ),
                                      ),
                                    )
                                  //? this the not poast the post return a gesture detector where this return a card
                                  : Slidable(
                                      actionPane: SlidableBehindActionPane(),
                                      actionExtentRatio: .6,
                                      secondaryActions: [
                                        IconSlideAction(
                                            foregroundColor: Colors.red,
                                            icon: Icons.delete,
                                            onTap: () async {
                                              setState(() {
                                                chats.removeAt(index);
                                              });
                                              await databaseReference
                                                  .child("messages/" + widget.user + "/" + widget.toWhom)
                                                  .child(chats[index].id)
                                                  .remove();

                                              await databaseReference
                                                  .child("messages/" + widget.toWhom + "/" + widget.user)
                                                  .child(chats[index].id)
                                                  .remove();
                                            })
                                      ],
                                      child: Card(
                                        margin: EdgeInsets.fromLTRB(4, 4, 7, 4),
                                        color:
                                            chats[index].sender == widget.user ? Colors.pink : Colors.white60,
                                        child: Container(
                                          margin: EdgeInsets.fromLTRB(7, 3, 7, 3),
                                          constraints: BoxConstraints(
                                              maxWidth: 3 * (MediaQuery.of(context).size.width) / 4),
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            chats[index].message,
                                            style: TextStyle(
                                                color: chats[index].sender == widget.user
                                                    ? Colors.white
                                                    : Colors.black),
                                          ),
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
                    FocusScope.of(context).unfocus();
                    String hello = mainCont.text;
                    mainCont.clear();
                    if (hello.isNotEmpty && hello != null) {
                      //* updating the time of the last msg sent so it can be sorted
                      //*and also the last message
                      //? of to whom
                      await databaseReference.child("messages/" + widget.user + "/" + widget.toWhom).update({
                        "last": hello,
                        "time": -DateTime.now().microsecondsSinceEpoch,
                      });
                      await databaseReference
                          .child("messages/" + widget.user + "/" + widget.toWhom)
                          .push()
                          .set({
                        "user": widget.user,
                        "message": hello,
                        "time": DateTime.now().millisecondsSinceEpoch,
                      });
                      await databaseReference
                          .child("messages/" + widget.toWhom + "/" + widget.user)
                          .push()
                          .set({
                        //user is the person send the message
                        "user": widget.user,
                        "message": hello,
                        "time": DateTime.now().millisecondsSinceEpoch
                      });

                      //* updating the time of the last msg sent so it can be sorted
                      //*and also the last message
                      //? of to whom
                      //? and also its unseen meassages so proper can be displayed

                      await databaseReference.child("messages/" + widget.toWhom + "/" + widget.user).update({
                        "time": -DateTime.now().microsecondsSinceEpoch,
                        "last": hello,
                        'unseen': ServerValue.increment(1)
                      });
                    }
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
