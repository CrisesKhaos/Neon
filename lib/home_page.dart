import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:main/comments.dart';
import 'package:main/discover.dart';
import 'package:main/message.dart';
import 'package:main/neon.dart';
import 'package:main/new_post.dart';
// ignore: unused_import
import 'package:main/new_post_select.dart';
import 'package:main/send_post.dart';
import 'package:main/user_profile_page.dart';
import 'package:main/widgets.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
                              "https://i.insider.com/59e4a9a2d4e920b4108b5560?width=1029&format=jpeg",
                            ),
                            scale: 3.0,
                            fit: BoxFit.fill),
                      ),
                    ),
                    //Image.network(
                    //"https://i.insider.com/59e4a9a2d4e920b4108b5560?width=1029&format=jpeg"),
                    Spacer(),

                    // ignore: deprecated_member_use
                    FlatButton(
                      onPressed: () async {
                        final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                        sharedPreferences.remove("user").then((value) {
                          Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(builder: (context) => SignInPage()), (route) => false);
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
            ? _currentIndex != 0
                ? AppBar(
                    leading: _currentIndex == 0
                        ? IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => NewPostImagePage(widget.userName)));
                            },
                          )
                        : _currentIndex == 4
                            ? Icon(Icons.lock)
                            : null,
                    actions: _currentIndex == 0
                        ? [
                            _currentIndex == 0
                                ? IconButton(
                                    icon: Icon(Icons.send_rounded),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MessageListPage(widget.userName)));
                                    },
                                  )
                                : null
                          ]
                        : null,
                    elevation: 20,
                    centerTitle: _currentIndex == 0 ? true : false,
                    title: Text(
                      _currentIndex == 1
                          ? ("Blips ")
                          : _currentIndex == 3
                              ? "Activity"
                              : widget.userName,
                      style: TextStyle(fontSize: 25),
                    ),
                    backgroundColor: Colors.pink,
                  )
                : null
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
              icon: FutureBuilder(
                future: getPfp(widget.userName),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.toString().isNotEmpty)
                      return ClipOval(
                        child: Image.network(
                          snapshot.data,
                          height: 26,
                          width: 26,
                          fit: BoxFit.cover,
                        ),
                      );
                    else
                      return Icon(
                        Icons.account_circle,
                        size: 24,
                      );
                  }
                  return Container();
                },
              ),
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
                    : _currentIndex == 1
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "👨‍🔧",
                                  style: TextStyle(
                                    fontSize: 100,
                                  ),
                                ),
                                Text(
                                  "Work Underway",
                                  style: TextStyle(fontSize: 25),
                                )
                              ],
                            ),
                          )
                        : PostList(widget.userName));
  }
}

//! convert this into a class or a function or a page ffs
class PostList extends StatefulWidget {
  //final List<Post> listItems;
  final String usertemp;

  PostList(this.usertemp);

  @override
  PostListState createState() => PostListState();
}

class PostListState extends State<PostList> {
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
    databaseReference.child('timelines/' + widget.usertemp).orderByChild('time').onChildAdded.listen(
      (Event event) async {
        String element = event.snapshot.value['post'].toString();
        List postValues = element.split('(split)');
        DataSnapshot postSnapshot =
            await databaseReference.child('posts/' + postValues[0] + "/" + postValues[1]).once();
        if (postSnapshot.value != null) {
          Post tempPost = createPost(postValues[0], postSnapshot.value, postSnapshot.key);
          if (postSnapshot.value['comments'] != null) {
            postSnapshot.value["comments"].forEach((key, value) {
              tempPost.comments.add(new Comment(value["user"], value['comment']));
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
    _scrollController = ItemScrollController();
    hello();
  }

  Future<String> getPfp(String whos) async {
    DataSnapshot x = await databaseReference.child("user_details/" + whos + "/pfp").once();
    return x.value;
  }

  @override
  Widget build(BuildContext context) {
    if (timeline.length != 0)
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => NewPostImagePage(widget.usertemp)));
            },
          ),
          elevation: 20,
          centerTitle: true,
          title: GestureDetector(
            child: Text(
              'NEON',
              style: TextStyle(
                fontSize: 30,
                fontStyle: FontStyle.normal,
                fontFamily: "Glacial",
              ),
            ),
            onTap: () => _scrollController.scrollTo(index: 0, duration: Duration(seconds: 1)),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.send_rounded),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => MessageListPage(widget.usertemp)));
              },
            )
          ],
          backgroundColor: Colors.pink,
        ),
        body: ScrollablePositionedList.builder(
            itemScrollController: _scrollController,
            itemCount: timeline.length,
            itemBuilder: (context, index) {
              Post post = timeline[timeline.length - (1 + index)];
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
                  elevation: 5,
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
                            child: GestureDetector(
                              child: Text(post.userName),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfilePage(
                                              post.userName,
                                              widget.usertemp,
                                              solo: true,
                                            )));
                              },
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          ),
                        ],
                      ),
                      Image.network(
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
                                      awesomeDialog(context, "Bruh Momentum",
                                          "You can neon only one post per month", false);
                                    else {
                                      neon.toDatabase();
                                      if (await neon.monthExists()) {
                                        neon.updateActivty();
                                        awesomeDialog(context, "Succes", "Neon added succesfully", true);
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
                                  if (widget.usertemp != post.userName)
                                    databaseReference.child("activity/" + post.userName).push().set({
                                      "postId": post.rand,
                                      "post": post.imageUrl,
                                      "comment": commentCont.text,
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
    else
      return Center(
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
              "No posts yet",
              style: TextStyle(fontSize: 25),
            )
          ],
        ),
      );
  }
}
