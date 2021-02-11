// ignore: unused_import
import 'dart:ffi';

import 'package:firebase_database/firebase_database.dart';
// ignore: unused_import
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:main/widgets.dart';
import 'post.dart';

final databaseReference = FirebaseDatabase.instance.reference();

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
  final String user;
  final String visitor;
  ProfilePage(this.user, this.visitor);
}

class _ProfilePageState extends State<ProfilePage> {
  var gradColor1 = Colors.pink[400];
  var gradColor2 = Colors.cyan[400];
  var following = 'Follow';
  bool visitorIsUser = false;
  Set followersTemp = {};
  Set visitorfollowingTemp = {};
  Set<Widget> allPosts = {};

  @override
  void initState() {
    print(widget.visitor);
    print(widget.user);
    super.initState();

    if (widget.visitor == widget.user) {
      setState(() {
        visitorIsUser = true;
        following = "Edit Profile";
      });
      print(visitorIsUser);
    } else {
      databaseReference
          .child('user_details/' + widget.user)
          .once()
          .then((snapshot) {
        snapshot.value['followers'] != null
            ? snapshot.value['followers'].contains(widget.visitor)
                ? this.setState(() {
                    gradColor1 = Colors.teal[400];
                    gradColor2 = Colors.tealAccent[400];
                    following = 'Following';
                  })
                : print('u are not following himm')
            : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: databaseReference.child('user_details/' + widget.user).once(),
      builder: (BuildContext context, AsyncSnapshot<DataSnapshot> snapshot) {
        if (snapshot.hasData) {
          Map<dynamic, dynamic> values = snapshot.data.value;
          int flwing = values['following'].length - 1;
          int flwers = values['followers'].length - 1;
          print(values['followers'].length - 1);
          return Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                    padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.account_circle,
                          size: 170,
                        )
                        /*: Image.network(
                              values['pfp'],
                              height: 170,
                              width: 170,
                            )*/
                      ],
                    )),
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
                              child: Text('00',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 27,
                                    color: Colors.white,
                                  )),
                            ),
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
                                  builder: (context) => ListWithAppBar(
                                      values['following'],
                                      "Following",
                                      widget.visitor),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.lightBlue,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                    child: Text(
                                        values['following'] == null
                                            ? "0"
                                            : flwing.toString(),
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
                              builder: (context) => ListWithAppBar(
                                  values['followers'],
                                  "Followers",
                                  widget.visitor),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.lightBlue,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                child: Text(
                                    values['followers'] == null
                                        ? "0"
                                        : flwers.toString(),
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
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(5, 10, 0, 10),
                      height: 50.0,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        elevation: 20,
                        onPressed: () async {
                          if (visitorIsUser == false) {
                            DataSnapshot snapshotVisitor =
                                await databaseReference
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
                                print(visitorfollowingTemp);
                                visitorfollowingTemp =
                                    snapshotVisitor.value.toSet();
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
                              } else {
                                gradColor1 = Colors.pink[400];
                                gradColor2 = Colors.cyan[400];
                                following = 'Follow';
                              }
                            });
                          } else
                            null;
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
                            constraints: BoxConstraints(
                                maxWidth: 400.0, minHeight: 50.0),
                            alignment: Alignment.center,
                            child: Text(
                              following,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(5, 10, 0, 15),
                      height: 70.0,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        onPressed: () async {
                          List<Post> neons;
                          DataSnapshot _neonsData = await databaseReference
                              .child("Neons/" + widget.user)
                              .once();
                          _neonsData.value?.forEach((key, value) {
                            value?.forEach((key, value) async {
                              DataSnapshot posttemp = await databaseReference
                                  .child("posts/" + value["user"])
                                  .child(value['post'])
                                  .once();
                              print(posttemp.value);
                            });
                          });
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
                            constraints: BoxConstraints(
                                maxWidth: 400.0,
                                maxHeight: 500.0,
                                minHeight: 500.0),
                            alignment: Alignment.center,
                            child: Text(
                              "Neons",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                /*
              FutureBuilder(
                  future:
                      databaseReference.child('posts/' + widget.user).once(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DataSnapshot> _postssnapshot) {
                    Map<dynamic, dynamic> userPosts = _postssnapshot.data.value;
                    print(userPosts);
                    userPosts.forEach((key, value) {
                      if (key == "post")
                        allPosts.add(Image.network(
                          value,
                          width: 100,
                          height: 100,
                        ));
                    });
                    print(allPosts);
                    return GridView(
                      children: allPosts.toList(),
                    );
                  })*/
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
