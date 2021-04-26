// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:main/post.dart';
import 'package:main/user_details.dart';
import 'package:main/user_profile_page.dart';
import 'dart:math';

import 'package:main/widgets.dart';

final databaseReference = FirebaseDatabase.instance.reference();

class DiscoverPage extends StatefulWidget {
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
                    // Navigator.push(
                    // context,
                    // MaterialPageRoute(
                    // builder: (context) => UserPosts(widget.user, widget.visitor, index)));
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
