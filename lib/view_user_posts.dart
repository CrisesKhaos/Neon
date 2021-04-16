import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:main/comments.dart';
import 'package:main/widgets.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'neon.dart';
import 'post.dart';
import 'home_page.dart';

class UserPosts extends StatefulWidget {
  final String usertemp;
  final int index;
  final String whos;

  UserPosts(this.whos, this.usertemp, this.index);
  @override
  _UserPostsState createState() => _UserPostsState();
}

class _UserPostsState extends State<UserPosts> {
  List<Post> timeline = [];
  bool hasPosts = true;
  ItemScrollController _scrollController;
  void changelix(Function lix) {
    this.setState(() {
      lix();
    });
  }

  Future<bool> isNeoned(Post post) async {
    if (post.neon != null) {
      if (post.neon.contains(widget.usertemp))
        return true;
      else
        return false;
    } else
      return false;
  }

  void hello() async {
    databaseReference
        .child('posts/' + widget.whos)
        .orderByChild('time')
        .onChildAdded
        .listen((Event event) async {
      Post post =
          createPost(widget.whos, event.snapshot.value, event.snapshot.key);

      setState(() {
        timeline.add(post);
      });
    });
  }

  Future<String> getPfp(String whos) async {
    DataSnapshot x =
        await databaseReference.child("user_details/" + whos + "/pfp").once();
    return x.value;
  }

  @override
  void initState() {
    super.initState();
    hello();
    setState(() {
      this.timeline = timeline.reversed.toList();
    });
    _scrollController = ItemScrollController();
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks)
      setState(() {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollController
            .scrollTo(index: widget.index, duration: Duration(seconds: 1)));
      });
  }

  @override
  Widget build(BuildContext context) {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks)
      setState(() {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollController
            .scrollTo(index: widget.index, duration: Duration(seconds: 1)));
      });

    return Scaffold(
      appBar: AppBar(
        title: Text("Posts"),
      ),
      body: ScrollablePositionedList.builder(
          itemScrollController: _scrollController,
          itemCount: timeline.length,
          itemBuilder: (context, index) {
            Post post = timeline[index];
            TextEditingController commentCont = new TextEditingController();

            return Container(
              decoration: post.neon.contains(widget.usertemp)
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.pink[400],
                    )
                  : null,
              child: Card(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                elevation: 10,
                shadowColor: Colors.pink[200],
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          child: FutureBuilder(
                            future: getPfp(post.userName),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                        Padding(
                          child: Text(post.userName),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                      ],
                    ),
                    Hero(
                      tag: post.imageUrl,
                      child: Image.network(
                        post.imageUrl,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.favorite),
                          onPressed: () {
                            this.changelix(
                                () => post.likePost(widget.usertemp));
                          },
                          color: post.usersLiked.contains(widget.usertemp)
                              ? Colors.redAccent[700]
                              : Colors.black,
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                          child: Text(
                            post.usersLiked.length.toString(),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          alignment: Alignment.center,
                          icon: post.neon.contains(widget.usertemp)
                              ? Icon(Icons.label_important_rounded)
                              : Icon(Icons.label_important_outline_rounded),
                          onPressed: post.neon.contains(widget.usertemp)
                              ? null
                              : () async {
                                  Neon neon = new Neon(post.rand, post.userName,
                                      widget.usertemp, post.imageUrl);
                                  if (await neon.monthExists())
                                    oneAlertBox(context,
                                        "You can Neon only one post per month!");
                                  else {
                                    neon.toDatabase();
                                    if (await neon.monthExists()) {
                                      neon.updateActivty();
                                      oneAlertBox(
                                          context, "Neon added succesfully!");
                                      post.neon.add(widget.usertemp);
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
                                  CommentsPage(post, widget.usertemp),
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
                                  "user": widget.usertemp,
                                  "comment": commentCont.text
                                });
                                post.comments.add(
                                    Comment(widget.usertemp, commentCont.text));
                                databaseReference
                                    .child("activty/" + post.userName)
                                    .push()
                                    .set({
                                  "postId": post.rand,
                                  "post": post.imageUrl,
                                  "action": "comment",
                                  "user": widget.usertemp,
                                  "time": DateTime.now().microsecondsSinceEpoch
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
              ),
            );
          }),
    );
  }
}
