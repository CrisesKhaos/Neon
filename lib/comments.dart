import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:main/post.dart';
import 'package:main/user_profile_page.dart';
import 'discover.dart';
import 'neon.dart';
import 'widgets.dart';

class Comment {
  final String owner;
  final String comment;

  Comment(this.owner, this.comment);
}

class CommentsPage extends StatefulWidget {
  final Post post;
  //user is the person visiting
  final String user;
  final String title;
  CommentsPage(this.post, this.user, {this.title = "Comments"});
  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  List<Comment> comments = [];
  List<Post> timeline = [];
  bool hasPosts = true;
  getComments20() async {
    databaseReference
        .child("posts/" + widget.post.userName + "/" + widget.post.rand)
        .child("comments")
        .once()
        .then((snap) {
      print(snap.value);
      snap.value.forEach((key, value) {
        setState(() {
          comments.add(
            new Comment(value['user'], value['comment']),
          );
        });
      });
    });
  }

  void changelix(Function lix) {
    this.setState(() {
      lix();
    });
  }

  Future<bool> isNeoned(Post post) async {
    if (widget.post.neon != null) {
      if (widget.post.neon.contains(widget.user))
        return true;
      else
        return false;
    } else
      return false;
  }

  void hello() async {
    databaseReference
        .child('timelines/' + widget.user)
        .orderByChild('time')
        .onChildAdded
        .listen(
      (Event event) async {
        String element = event.snapshot.value['widget.post'].toString();
        List postValues = element.split('(split)');
        DataSnapshot postSnapshot = await databaseReference
            .child('widget.posts/' + postValues[0] + "/" + postValues[1])
            .once();
        if (postSnapshot.value != null) {
          Post tempPost =
              createPost(postValues[0], postSnapshot.value, postSnapshot.key);
          if (postSnapshot.value['comments'] != null) {
            postSnapshot.value["comments"].forEach((key, value) {
              tempPost.comments
                  .add(new Comment(value["user"], value['comment']));
              tempPost.comments.reversed;
            });
          }
          setState(() {
            timeline.add(tempPost);
          });
        } else
          print("null");
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getComments20();
    hello();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController commentCont = new TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: this.comments.length + 1,
              itemBuilder: (context, index) {
                if (index == 0)
                  return Container(
                    decoration: widget.post.neon.contains(widget.user)
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.pink[400],
                          )
                        : null,
                    child: Card(
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                      elevation: 0,
                      shadowColor: Colors.pink[200],
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Padding(
                                child: FutureBuilder(
                                  future: getPfp(widget.post.userName),
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
                              Padding(
                                child: GestureDetector(
                                  child: Text(widget.post.userName),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ProfilePage(
                                                  widget.post.userName,
                                                  widget.user,
                                                  solo: true,
                                                )));
                                  },
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                              ),
                            ],
                          ),
                          Image.network(
                            widget.post.imageUrl,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.favorite),
                                onPressed: () {
                                  this.changelix(
                                      () => widget.post.likePost(widget.user));
                                },
                                color:
                                    widget.post.usersLiked.contains(widget.user)
                                        ? Colors.redAccent[700]
                                        : Colors.black,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 5),
                                child: Text(
                                  widget.post.usersLiked.length.toString(),
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                alignment: Alignment.center,
                                icon: widget.post.neon.contains(widget.user)
                                    ? Icon(Icons.label_important_rounded)
                                    : Icon(
                                        Icons.label_important_outline_rounded),
                                onPressed: widget.post.neon
                                        .contains(widget.user)
                                    ? null
                                    : () async {
                                        Neon neon = new Neon(
                                            widget.post.rand,
                                            widget.post.userName,
                                            widget.user,
                                            widget.post.imageUrl);
                                        if (await neon.monthExists())
                                          oneAlertBox(context,
                                              "You can Neon only one widget.post per month!");
                                        else {
                                          neon.toDatabase();
                                          if (await neon.monthExists()) {
                                            neon.updateActivty();
                                            oneAlertBox(context,
                                                "Neon added succesfully!");
                                            widget.post.neon.add(widget.user);
                                            setState(() {});
                                          } else
                                            oneAlertBox(context,
                                                "Something went wrong! ");
                                        }
                                      },
                              ),
                            ],
                          ),
                          ListTile(
                            leading: FutureBuilder(
                              future: getPfp(widget.post.userName),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data.toString().isNotEmpty)
                                    return ClipOval(
                                      child: Image.network(
                                        snapshot.data,
                                        height: 35,
                                        width: 35,
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
                            title: RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: widget.post.userName + "  ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 17),
                                children: [
                                  TextSpan(
                                      text: widget.post.caption,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ))
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            thickness: 1.5,
                          ),
                        ],
                      ),
                    ),
                  );
                else
                  return ListTile(
                    leading: FutureBuilder(
                      future: getPfp(comments[index - 1].owner),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.toString().isNotEmpty)
                            return ClipOval(
                              child: Image.network(
                                snapshot.data,
                                height: 35,
                                width: 35,
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
                    title: RichText(
                      text: TextSpan(
                          text: comments[index - 1].owner + "  ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 17),
                          children: [
                            TextSpan(
                              text: comments[index - 1].comment,
                              style: TextStyle(fontWeight: FontWeight.normal),
                            )
                          ]),
                    ),
                  );
              },
            ),
          ),
          TextField(
            controller: commentCont,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.message),
              labelText: "Add a comment",
              suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  splashColor: Colors.pinkAccent[100],
                  onPressed: () {
                    if (commentCont.text.isNotEmpty) {
                      databaseReference
                          .child("widget.posts/" +
                              widget.post.userName +
                              "/" +
                              widget.post.rand)
                          .child("comments/")
                          .push()
                          .set({
                        "user": widget.user,
                        "comment": commentCont.text
                      });
                      widget.post.comments
                          .add(Comment(widget.user, commentCont.text));
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
  }
}
