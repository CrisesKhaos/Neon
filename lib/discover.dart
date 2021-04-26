// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:main/comments.dart';
import 'package:main/post.dart';
import 'package:main/send_post.dart';
import 'package:main/user_details.dart';
import 'package:main/user_profile_page.dart';
import 'dart:math';

import 'package:main/widgets.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'neon.dart';

final databaseReference = FirebaseDatabase.instance.reference();

class DiscoverPage extends StatefulWidget {
  //curerent user is the person visitingf
  final String currentUser;
  DiscoverPage(this.currentUser);
  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  List<UserDetails> _userDetails = [];
  List<UserDetails> _disUsers = [];
  final databaseReference = FirebaseDatabase.instance.reference();
  List<Post> discover = [];

  getPosts() async {
    List allPosts = [];
    DataSnapshot following =
        await databaseReference.child("user_details/" + widget.currentUser).child('following').once();
    if (following.value != null)
      following.value.forEach((value) async {
        DataSnapshot posts = await databaseReference.child("recently_liked/" + value).once();
        if (posts.value != null)
          posts.value.forEach((key, value) async {
            if (!allPosts.contains(value['postId'])) {
              allPosts.add(value['postId']);
              DataSnapshot postV =
                  await databaseReference.child("posts" + value['name']).child(value['postId']).once();
              Post tpost = createPost(value['name'], postV.value, value['postId']);
              setState(() {
                discover.add(tpost);
              });
            }
          });
      });

    int lucky = Random().nextInt(following.value.length);
    databaseReference.child('timelines/' + following.value[lucky]).orderByChild('time').onChildAdded.listen(
      (Event event) async {
        String element = event.snapshot.value['post'];
        List postValues = element.split('(split)');
        if (!allPosts.contains(postValues[1]) && postValues[0] != widget.currentUser) {
          allPosts.add(postValues[1]);
          DataSnapshot postSnapshot =
              await databaseReference.child('posts/' + postValues[0] + "/" + postValues[1]).once();
          if (postSnapshot.value != null) {
            Post tempPost = createPost(postValues[0], postSnapshot.value, postSnapshot.key);
            setState(() {
              discover.add(tempPost);
            });
          } else
            print("null");
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    returnUserlist().then((users) {
      setState(() {
        this._userDetails = users;
        this._disUsers = users;
      });
    });
    getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.photo_size_select_actual_rounded)),
              Tab(icon: Icon(Icons.search)),
            ],
          ),
        ),
        body: TabBarView(children: [
          GridView.builder(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
              physics: ScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
              ),
              itemCount: discover.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DiscoverTimeline(discover, widget.currentUser, index)));
                  },
                  onLongPress: () {
                    displayImage(context, discover[index], discover[index].rand);
                  },
                  child: Hero(
                    tag: discover[index].rand,
                    child: Image.network(
                      discover[index].imageUrl,
                      height: 100,
                      width: 100,
                    ),
                  ),
                );
              }),
          ListView.builder(
            itemCount: _disUsers.length + 1,
            itemBuilder: (context, index) {
              if (index == 0)
                return Padding(
                  padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.supervised_user_circle_rounded),
                      border: OutlineInputBorder(borderSide: BorderSide(width: 5, color: Colors.yellow)),
                      labelText: "Search for a user",
                    ),
                    onChanged: (text) {
                      text = text.toLowerCase();
                      setState(() {
                        _disUsers = _userDetails.where((element) {
                          String userName = element.user.toString().toLowerCase();
                          return userName.contains(text);
                        }).toList();
                      });
                    },
                  ),
                );
              else {
                var shownUser = _disUsers[index - 1];
                return Card(
                  margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                  elevation: 5,
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfilePage(
                                  shownUser.user,
                                  widget.currentUser,
                                  solo: true,
                                )),
                      );
                    },
                    leading: Icon(
                      Icons.account_circle,
                      size: 50,
                    ),
                    title: Text(
                      shownUser.user,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                );
              }
            },
          ),
        ]),
      ),
    );
  }
}

class DiscoverTimeline extends StatefulWidget {
  final List<Post> timeline;
  final String usertemp;
  final int index;
  DiscoverTimeline(this.timeline, this.usertemp, this.index);
  @override
  _DiscoverTimelineState createState() => _DiscoverTimelineState();
}

class _DiscoverTimelineState extends State<DiscoverTimeline> {
  void changelix(Function lix) {
    this.setState(() {
      lix();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Posts"),
      ),
      body: ScrollablePositionedList.builder(
          initialScrollIndex: widget.index,
          itemCount: widget.timeline.length,
          itemBuilder: (context, index) {
            Post post = widget.timeline[index];
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
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                        Padding(
                          child: Text(post.userName),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                      ],
                    ),
                    Hero(
                      tag: post.imageUrl,
                      child: Image.network(
                        post.imageUrl,
                        loadingBuilder:
                            (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
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
                            this.changelix(() => post.likePost(widget.usertemp));
                          },
                          color: post.usersLiked.contains(widget.usertemp)
                              ? Colors.redAccent[700]
                              : Colors.black,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                          child: Text(
                            post.usersLiked.length.toString(),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Spacer(),
                        IconButton(
                            icon: Icon(Icons.send_rounded),
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => SendPost(widget.usertemp, post)));
                            }),
                        IconButton(
                          alignment: Alignment.center,
                          icon: post.neon.contains(widget.usertemp)
                              ? Icon(Icons.label_important_rounded)
                              : Icon(Icons.label_important_outline_rounded),
                          onPressed: post.neon.contains(widget.usertemp)
                              ? null
                              : () async {
                                  Neon neon =
                                      new Neon(post.rand, post.userName, widget.usertemp, post.imageUrl);
                                  if (await neon.monthExists())
                                    oneAlertBox(context, "You can Neon only one post per month!");
                                  else {
                                    neon.toDatabase();
                                    if (await neon.monthExists()) {
                                      neon.updateActivty();
                                      oneAlertBox(context, "Neon added succesfully!");
                                      post.neon.add(widget.usertemp);
                                      setState(() {});
                                    } else
                                      oneAlertBox(context, "Something went wrong! ");
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
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
                              builder: (context) => CommentsPage(post, widget.usertemp),
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
                                    .child("posts/" + post.userName + "/" + post.rand)
                                    .child("comments/")
                                    .push()
                                    .set({"user": widget.usertemp, "comment": commentCont.text});
                                post.comments.add(Comment(widget.usertemp, commentCont.text));
                                databaseReference.child("activty/" + post.userName).push().set({
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
