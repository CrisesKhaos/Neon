// ignore: import_of_legacy_library_into_null_safe
// ignore: unused_import
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:main/discover.dart';
import 'package:main/neon.dart';
import 'package:main/user_details.dart';
import 'package:main/user_profile_page.dart';
import 'package:main/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'new_post.dart';
import 'activity.dart';
import 'post.dart';
import 'sign_in.dart';

final databaseReference = FirebaseDatabase.instance.reference();

class HomePage extends StatefulWidget {
  final String userName;
  final int tempcurrentIndex;

  HomePage(this.userName, {this.tempcurrentIndex = 0});
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String text;
  int _currentIndex = 0;
  var cntlr = TextEditingController();
  List<Post> posts = [];

  @override
  void dispose() {
    super.dispose();
    cntlr.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        endDrawer: _currentIndex == 4
            ? Drawer(
                elevation: 16.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DrawerHeader(
                      child: Text(
                        'Hello, ' + widget.userName,
                        style: TextStyle(fontSize: 50),
                      ),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                                "https://i.insider.com/59e4a9a2d4e920b4108b5560?width=1029&format=jpeg"),
                            scale: 3.0,
                            fit: BoxFit.fill),
                      ),
                    ),
                    //Image.network(
                    //"https://i.insider.com/59e4a9a2d4e920b4108b5560?width=1029&format=jpeg"),
                    Spacer(),

                    FlatButton(
                      onPressed: () async {
                        final SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();
                        sharedPreferences.remove("user").then((value) {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignInPage()),
                              (route) => false);
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            "Log Out",
                          ),
                          Spacer(),
                          Icon(Icons.two_wheeler_outlined),
                        ],
                      ),
                    )
                  ],
                ),
              )
            : null,
        appBar: _currentIndex != 2
            ? AppBar(
                leading: _currentIndex == 0
                    ? IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      NewPostPage(widget.userName)));
                        },
                      )
                    : _currentIndex == 4
                        ? Icon(Icons.lock)
                        : null,
                /*actions: _currentIndex == 0 || _currentIndex == 4
                    ? [
                        _currentIndex == 0
                            ? IconButton(
                                icon: Icon(Icons.send_rounded),
                                onPressed: () {},
                              )
                            : null
                      ]
                    : null*/
                elevation: 20,
                centerTitle: _currentIndex == 0 ? true : false,
                title: Text(
                  _currentIndex == 0
                      ? "NEON"
                      : _currentIndex == 1
                          ? "Blips "
                          : _currentIndex == 3
                              ? "Activity"
                              : widget.userName,
                  style: TextStyle(fontSize: 25),
                ),
                backgroundColor: Colors.pink,
              )
            : null,

        //?Bottom app bar starts
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.hourglass_empty_rounded),
              activeIcon: Icon(Icons.hourglass_bottom_rounded),
              label: "Blips",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: "Discover",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_outlined),
              activeIcon: Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              label: "Activity",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: "Profile",
            ),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),

        //?Body of the home page starts
        body: _currentIndex == 4
            ? ProfilePage(widget.userName, widget.userName)
            : _currentIndex == 2
                ? DiscoverPage(widget.userName)
                : _currentIndex == 3
                    ? ActivityPage(widget.userName)
                    : PostList(widget.userName));
  }
}

class PostList extends StatefulWidget {
  //final List<Post> listItems;
  final String usertemp;

  PostList(this.usertemp);

  @override
  PostListState createState() => PostListState();
}

class PostListState extends State<PostList> {
  List<Post> timeline = [];
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

  Widget diplayPost(BuildContext context, Post post, String user) {
    return Card(
      elevation: 40,
      shadowColor: Colors.pink[200],
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                child: Icon(Icons.person),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              Padding(
                child: Text(post.userName),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                  this.changelix(() => post.likePost(widget.usertemp));
                },
                color: post.usersLiked.contains(user)
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
                alignment: Alignment.center,
                icon: Icon(Icons.label_important_outline_rounded),
                onPressed: () async {
                  Neon neon = new Neon(post.rand, post.userName, user);
                  await neon.monthExists()
                      ? oneAlertBox(
                          context, "You can Neon only One post per month!")
                      : neon.toDatabase();
                },
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 7, 10),
                  child: Text(
                    post.userName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  )),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 10),
                child: Text(post.caption),
              )
            ],
          )
        ],
      ),
    );
  }

  void hello() async {
    DataSnapshot _snapshot =
        await databaseReference.child('timelines/' + widget.usertemp).once();
    List timeVals = _snapshot.value.values.toList();
    timeVals.forEach((element) async {
      List postValues = element.split('(split)');
      DataSnapshot postSnapshot = await databaseReference
          .child('posts/' + postValues[0] + "/" + postValues[1])
          .once();
      if (postSnapshot.value != null) {
        Post tempPost =
            createPost(postValues[0], postSnapshot.value, postSnapshot.key);
        setState(() {
          timeline.add(tempPost);
        });

        print('yeeeeet');
        print(timeline);
      } else
        print("null");
    });
    print("null");
    print(timeline);
    print("null2");
  }

  @override
  void initState() {
    super.initState();
    hello();
    print('hello');
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: timeline.length,
        itemBuilder: (context, index) {
          Post post = timeline[index];
          return Card(
            elevation: 40,
            shadowColor: Colors.pink[200],
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      child: Icon(Icons.person),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    Padding(
                      child: Text(post.userName),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                      alignment: Alignment.center,
                      icon: post.neon.contains(widget.usertemp)
                          ? Icon(Icons.label_important_rounded)
                          : Icon(Icons.label_important_outline_rounded),
                      onPressed: () async {
                        Neon neon =
                            new Neon(post.rand, post.userName, widget.usertemp);
                        await neon.monthExists()
                            ? oneAlertBox(context,
                                "You can Neon only One post per month!")
                            : neon.toDatabase();
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 7, 10),
                        child: Text(
                          post.userName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        )),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 10, 10),
                      child: Text(post.caption),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  /*
    if (widget.listItems != null)
      return Builder(builder: (context) {
        return ListView.builder(
          itemCount: this.widget.listItems.length,
          itemBuilder: (context, index) {
            var post = this.widget.listItems[index];

            return Card(
              elevation: 40,
              shadowColor: Colors.pink[200],
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        child: Icon(Icons.person),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                      Padding(
                        child: Text(post.userName),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                          this.changelix(() => post.likePost(widget.usertemp));
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
                        icon: Icon(Icons.label_important_outline_rounded),
                        onPressed: () async {
                          Neon neon = new Neon(
                              post.rand, post.userName, widget.usertemp);
                          await neon.monthExists()
                              ? oneAlertBox(context,
                                  "You can Neon only One post per month!")
                              : neon.toDatabase();
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 7, 10),
                          child: Text(
                            post.userName,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          )),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 10, 10),
                        child: Text(post.caption),
                      )
                    ],
                  )
                ],
              ),
            );
          },
        );
      });
    else
      return Text(
        'No posts yet ☹',
        textAlign: TextAlign.center,
      );*/
}
