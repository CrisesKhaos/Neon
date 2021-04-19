// ignore: import_of_legacy_library_into_null_safe

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:main/edit_profile.dart';
import 'package:main/post.dart';
import 'package:main/view_user_posts.dart';
import 'package:main/widgets.dart';
import 'neon.dart';
import 'package:main/home_page.dart';

//* pls send help i have no idea what i did but it works
class UppImage {
  final Map<dynamic, dynamic> values;
  final String key;
  UppImage(this.values, this.key);
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
  final String user;
  final String visitor;
  final bool solo;
  ProfilePage(this.user, this.visitor, {this.solo = false});
}

class _ProfilePageState extends State<ProfilePage> {
  var gradColor1 = Colors.pink[400];
  var gradColor2 = Colors.cyan[400];
  var following = 'Follow';
  List<UppImage> allPosts = [];
  bool visitorIsUser = false;
  Set followersTemp = {};
  Set visitorfollowingTemp = {};

  void changelix(Function lix) {
    this.setState(() {
      lix();
    });
  }

  void getPostsImages() async {
    databaseReference
        .child('posts/' + widget.user)
        .orderByChild('time')
        .onChildAdded
        .listen((Event event) async {
      if (!mounted) return;
      setState(() {
        allPosts.add(UppImage(event.snapshot.value, event.snapshot.key));
      });
    });
  }

  Future<int> getPosts() async {
    List x = [];
    DataSnapshot temp = await databaseReference.child('posts/' + widget.user).orderByKey().once();
    x.addAll(temp.value.keys);
    return x.length;
  }

  void displayImage(BuildContext context, Post post, String tag) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return GestureDetector(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Hero(
                    tag: tag,
                    child: Card(
                      elevation: 40,
                      shadowColor: Colors.pink[200],
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Padding(
                                child: Text(post.userName),
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              ),
                            ],
                          ),
                          Image.network(post.imageUrl),
                          Row(
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.favorite),
                                onPressed: () {
                                  changelix(() => post.likePost(widget.visitor));
                                },
                                color: post.usersLiked.contains(post.userName)
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
                        ],
                      ),
                    )),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          );
        });
  }

  updateTimeline() async {
    DataSnapshot x = await databaseReference.child('posts/' + widget.user).once();
    List hello = x.value.keys.toList();
    hello.forEach((element) {
      databaseReference.child("timelines/" + widget.visitor).push().set(widget.user + '(split)' + element);
    });
  }

  void initState() {
    super.initState();

    if (widget.visitor == widget.user) {
      setState(() {
        visitorIsUser = true;
        following = "Edit Profile";
      });
    } else {
      databaseReference.child('user_details/' + widget.user).once().then((snapshot) {
        snapshot.value['followers'] != null
            ? snapshot.value['followers'].contains(widget.visitor)
                ? this.setState(() {
                    gradColor1 = Colors.teal[400];
                    gradColor2 = Colors.tealAccent[400];
                    following = 'Following';
                  })
                : print('u are not following himm')
            // ignore: unnecessary_statements
            : null;
      });
    }
    getPostsImages();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: databaseReference.child('user_details/' + widget.user).once(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          Map<dynamic, dynamic> values = snapshot.data.value;
          int flwing = values['following'].length - 1;
          int flwers = values['followers'].length - 1;
          return Scaffold(
            appBar: widget.solo ? AppBar(title: Text("@" + widget.user)) : null,
            body: ListView(
              scrollDirection: Axis.vertical,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                      child: Row(
                        children: [
                          values["pfp"].toString().isEmpty
                              ? Icon(
                                  Icons.account_circle,
                                  size: 190,
                                )
                              : GestureDetector(
                                  onTap: () {
                                    oneImageBox(context, values['pfp']);
                                  },
                                  child: ClipOval(
                                    child: Image.network(
                                      values['pfp'],
                                      height: 160,
                                      width: 160,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 5, 5, 15),
                                child: Container(
                                  constraints:
                                      BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 180),
                                  child: Text(
                                    values['name'],
                                    style: TextStyle(fontSize: 23),
                                    softWrap: true,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 0, 5, 15),
                                child: Container(
                                  constraints:
                                      new BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 190),
                                  child: Text(
                                    values['bio'],
                                    softWrap: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Card(
                            color: Colors.lightBlue,
                            child: Column(
                              children: [
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                    child: FutureBuilder(
                                      future: getPosts(),
                                      builder: (context, AsyncSnapshot numPosts) {
                                        if (numPosts.hasData) {
                                          return Text(numPosts.data.toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 27,
                                                color: Colors.white,
                                              ));
                                        } else
                                          return Text("0",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 27,
                                                color: Colors.white,
                                              ));
                                      },
                                    )),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 3),
                                    child: Text(
                                      'Posts',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.white,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                            child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ListWithAppBar(values['following'], "Following", widget.visitor),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: Colors.lightBlue,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                        child: Text(values['following'] == null ? "0" : flwing.toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 27,
                                              color: Colors.white,
                                            )),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 0, 0, 3),
                                          child: Text(
                                            'Following',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w300,
                                              color: Colors.white,
                                            ),
                                          )),
                                    ],
                                  ),
                                ))),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ListWithAppBar(values['followers'], "Followers", widget.visitor),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.lightBlue,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                    child: Text(values['followers'] == null ? "0" : flwers.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 27,
                                          color: Colors.white,
                                        )),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 3),
                                      child: Text(
                                        'Followers',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.white,
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    //!FollowButton and Neon button
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 10, 0, 10),
                          height: 50.0,
                          // ignore: deprecated_member_use
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                            elevation: 20,
                            onPressed: () async {
                              if (visitorIsUser == false) {
                                DataSnapshot snapshotVisitor = await databaseReference
                                    .child('user_details/' + widget.visitor)
                                    .child('following')
                                    .once();
                                setState(() {
                                  if (values['followers'] != null) {
                                    followersTemp = values['followers'].toSet();
                                    followersTemp.contains(widget.visitor)
                                        ? followersTemp.remove(widget.visitor)
                                        : followersTemp.add(widget.visitor);
                                  } else
                                    followersTemp = {widget.visitor};

                                  if (snapshotVisitor.value != null) {
                                    visitorfollowingTemp = snapshotVisitor.value.toSet();
                                    visitorfollowingTemp.contains(widget.user)
                                        ? visitorfollowingTemp.remove(widget.user)
                                        : visitorfollowingTemp.add(widget.user);
                                  } else
                                    visitorfollowingTemp = {widget.visitor};
                                  databaseReference
                                      .child('user_details/' + widget.user)
                                      .child('followers')
                                      .set(followersTemp.toList());
                                  databaseReference
                                      .child('user_details/' + widget.visitor)
                                      .child('following')
                                      .set(visitorfollowingTemp.toList());
                                  if (following != 'Following') {
                                    gradColor1 = Colors.teal[400];
                                    gradColor2 = Colors.tealAccent[400];
                                    following = 'Following';
                                    databaseReference.child('activity/' + widget.user).push().set({
                                      "action": "following",
                                      "user": widget.visitor,
                                      "time": DateTime.now().microsecondsSinceEpoch
                                    });
                                    updateTimeline();
                                  } else {
                                    gradColor1 = Colors.pink[400];
                                    gradColor2 = Colors.cyan[400];
                                    following = 'Follow';
                                  }
                                });
                              } else
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PreEditProfile(widget.user)),
                                );
                            },
                            padding: EdgeInsets.all(0.0),
                            child: Ink(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      gradColor1,
                                      gradColor2,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Container(
                                constraints: BoxConstraints(maxWidth: 400.0, minHeight: 50.0),
                                alignment: Alignment.center,
                                child: Text(
                                  following,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 10, 0, 15),
                          height: 70.0,
                          // ignore: deprecated_member_use
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NeonPage(
                                          widget.user,
                                          widget.visitor,
                                        )),
                              );
                            },
                            padding: EdgeInsets.all(0.0),
                            child: Ink(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.purple,
                                      Colors.pink,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Container(
                                constraints:
                                    BoxConstraints(maxWidth: 400.0, maxHeight: 500.0, minHeight: 500.0),
                                alignment: Alignment.center,
                                child: Text(
                                  "Neons",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 25),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                //!End of neon and following
                Divider(
                  color: Colors.black38,
                  endIndent: 10,
                  indent: 10,
                  thickness: 2,
                  height: 5,
                ),
                GridView.builder(
                    padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 150,
                      mainAxisSpacing: 7,
                      crossAxisSpacing: 7,
                    ),
                    itemCount: allPosts.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserPosts(widget.user, widget.visitor, index)));
                        },
                        onLongPress: () {
                          Post post = createPost(widget.user, allPosts[index].values, allPosts[index].key);
                          displayImage(context, post, allPosts[index].values['post']);
                        },
                        child: Hero(
                          tag: allPosts[index].values['post'],
                          child: Image.network(
                            allPosts[index].values['post'],
                            height: 100,
                            width: 100,
                          ),
                        ),
                      );
                    }),
              ],
            ),
          );
        } else {
          return LinearProgressIndicator();
        }
      },
    );
  }
}
