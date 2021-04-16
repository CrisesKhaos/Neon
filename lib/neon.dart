import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:main/comments.dart';
import 'package:main/send_post.dart';
import 'package:main/user_profile_page.dart';
import 'post.dart';
import 'home_page.dart';
import 'widgets.dart';

class Neon {
  final String imgUrl;
  //post is the uid of the post
  final String post;
  //user the owner of the post which is being neoned
  final String user;
  //Owner is the person who is neoning the post
  final String owner;
  Neon(this.post, this.user, this.owner, this.imgUrl);
  Future<bool> monthExists() async {
    DataSnapshot neon = await databaseReference
        .child('Neons/' + owner)
        .child(DateTime.now().year.toString())
        .child(DateTime.now().month.toString())
        .once();
    return neon.value == null ? false : true;
  }

  void updatePost() async {
    DataSnapshot values =
        await databaseReference.child("posts/" + user).child(post).once();
    Post tempPost = createPost(user, values.value, this.post);
    Set hello = tempPost.neon;

    hello.add(owner);
    databaseReference.child('posts/' + this.user + "/" + this.post).update(
      {'neon': hello.toList()},
    );
    /*
        .then((_neoners) {
      if (_neoners.value == null) {
        List temp = [owner];
        databaseReference
            .child("posts/" + user)
            .child(post + "/neon")
            .set(temp);
      } else {
        Set temp = _neoners.value.toSet();
        print(temp);
        temp.add(owner);
        print(temp);

        databaseReference
            .child("posts/" + user + "/" + post)
            .update({"neon": temp.toList()});
      }
    });*/
  }

  void updateActivty() async {
    databaseReference.child('activity/' + this.user).push().set({
      "postId": this.post,
      "post": this.imgUrl,
      "action": "neon",
      "user": this.owner,
      "time": DateTime.now().microsecondsSinceEpoch
    });
  }

  void toDatabase() async {
    databaseReference
        .child('Neons/' + owner)
        .child(DateTime.now().year.toString())
        .set({
      DateTime.now().month.toString(): this.post + "(split)" + this.user
    });
    updatePost();
  }
}

class NeonPage extends StatefulWidget {
  final String user;
  final String visitor;
  NeonPage(this.user, this.visitor);
  @override
  _NeonPageState createState() => _NeonPageState();
}

class _NeonPageState extends State<NeonPage> {
  List<Post> neonTimeline = [];
  List months = [];

  void changelix(Function lix) {
    this.setState(() {
      lix();
    });
  }

  void getdata() async {
    DataSnapshot _snapshot =
        await databaseReference.child("Neons/" + widget.user).once();

    if (_snapshot.value != null) {
      Map<dynamic, dynamic> mainValues = _snapshot.value["2021"];
      List codes = mainValues.values.toList();
      List months = mainValues.keys.toList();
      setState(() {
        this.months = months;
      });
      codes.forEach((value) async {
        List postValues = value.split('(split)');
        print(postValues[0]);
        DataSnapshot postSnapshot = await databaseReference
            .child('posts/' + postValues[1] + "/" + postValues[0])
            .once();
        print(postSnapshot.value);
        if (postSnapshot.value != null) {
          Post tempPost =
              createPost(postValues[1], postSnapshot.value, postSnapshot.key);
          if (postSnapshot.value['comments'] != null) {
            postSnapshot.value["comments"].forEach((key, value) {
              tempPost.comments
                  .add(new Comment(value["user"], value['comment']));
              tempPost.comments.reversed;
            });
          }

          setState(() {
            neonTimeline.add(tempPost);
          });
        } else
          print("null");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    print(neonTimeline.length);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          widget.user + "'s" + ' Neons',
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: neonTimeline.length != 0
          ? ListView.builder(
              itemCount: neonTimeline.length,
              itemBuilder: (context, index) {
                TextEditingController commentCont = new TextEditingController();
                Post post = neonTimeline[index];
                print(giveMonth(int.parse(months[index])));
                return Card(
                  elevation: 10,
                  shadowColor: Colors.pink[200],
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          giveMonth(int.parse(months[index])),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            child: FutureBuilder(
                              future: getPfp(post.userName),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.hasData) {
                                  print(snapshot.data);
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
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfilePage(
                                            post.userName,
                                            widget.visitor,
                                            solo: true,
                                          )));
                            },
                            child: Padding(
                              child: Text(post.userName),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                            ),
                          ),
                        ],
                      ),
                      Image.network(post.imageUrl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.favorite),
                            onPressed: () {
                              this.changelix(
                                  () => post.likePost(widget.visitor));
                            },
                            color: post.usersLiked.contains(widget.visitor)
                                ? Colors.redAccent[700]
                                : Colors.black,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 5),
                            child: Text(
                              post.usersLiked.length.toString(),
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Spacer(),
                          IconButton(
                              icon: Icon(Icons.send_rounded),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SendPost(widget.visitor)));
                              }),
                          IconButton(
                            alignment: Alignment.center,
                            icon: post.neon.contains(widget.visitor)
                                ? Icon(Icons.label_important_rounded)
                                : Icon(Icons.label_important_outline_rounded),
                            onPressed: post.neon.contains(widget.visitor)
                                ? null
                                : () async {
                                    Neon neon = new Neon(
                                        post.rand,
                                        post.userName,
                                        widget.visitor,
                                        post.imageUrl);
                                    if (await neon.monthExists())
                                      oneAlertBox(context,
                                          "You can Neon only one post per month!");
                                    else {
                                      neon.toDatabase();
                                      if (await neon.monthExists()) {
                                        neon.updateActivty();
                                        oneAlertBox(
                                            context, "Neon added succesfully!");
                                        post.neon.add(widget.visitor);
                                        setState(() {});
                                      } else
                                        oneAlertBox(
                                            context, "Something went wrong! ");
                                    }
                                  },
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                            child: RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: post.userName + "  ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                                children: [
                                  TextSpan(
                                      text: post.caption,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ))
                                ],
                              ),
                            )),
                      ),
                      if (post.comments.isNotEmpty)
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                              child: RichText(
                                textAlign: TextAlign.left,
                                text: TextSpan(
                                  text: post.comments[0].owner + "  ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                  children: [
                                    TextSpan(
                                        text: post.comments[0].comment,
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ))
                                  ],
                                ),
                              )),
                        ),
                      if (post.comments.length > 1)
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                              child: RichText(
                                textAlign: TextAlign.left,
                                text: TextSpan(
                                  text: post.comments[1].owner + "  ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                  children: [
                                    TextSpan(
                                        text: post.comments[1].comment,
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ))
                                  ],
                                ),
                              )),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        child: GestureDetector(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "View comments",
                              style: TextStyle(color: Colors.black38),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CommentsPage(post, widget.visitor),
                              ),
                            );
                          },
                        ),
                      ),
                      TextField(
                        controller: commentCont,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.message),
                          labelText: "Add a comment..",
                          suffixIcon: IconButton(
                              icon: Icon(Icons.send),
                              splashColor: Colors.pinkAccent[100],
                              onPressed: () {
                                if (commentCont.text.isNotEmpty) {
                                  databaseReference
                                      .child("posts/" +
                                          post.userName +
                                          "/" +
                                          post.rand)
                                      .child("comments/")
                                      .push()
                                      .set({
                                    "user": widget.visitor,
                                    "comment": commentCont.text
                                  });
                                  post.comments.add(Comment(
                                      widget.visitor, commentCont.text));
                                  if (widget.visitor != post.userName)
                                    databaseReference
                                        .child("activity/" + post.userName)
                                        .push()
                                        .set({
                                      "postId": post.rand,
                                      "post": post.imageUrl,
                                      "comment": commentCont.text,
                                      "action": "comment",
                                      "user": widget.visitor,
                                      "time":
                                          DateTime.now().microsecondsSinceEpoch
                                    });
                                  setState(() {});
                                  commentCont.clear();
                                }
                                FocusScope.of(context).unfocus();
                              }),
                        ),
                      ),
                    ],
                  ),
                );
              })
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "😔",
                    style: TextStyle(
                      fontSize: 100,
                    ),
                  ),
                  Text(
                    "No neons yet",
                    style: TextStyle(fontSize: 25),
                  )
                ],
              ),
            ),
    );
  }
}
