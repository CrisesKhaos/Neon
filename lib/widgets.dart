import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:main/user_profile_page.dart';

import 'post.dart';

//Widget diplayPost(Post post) {}

class ListWithAppBar extends StatefulWidget {
  final List list;
  final String heading;
  final String visitor;
  ListWithAppBar(this.list, this.heading, this.visitor);
  @override
  _ListWithAppBarState createState() => _ListWithAppBarState();
}

class _ListWithAppBarState extends State<ListWithAppBar> {
  @override
  Widget build(BuildContext context) {
    print(widget.heading);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.heading),
      ),
      body: ListView.builder(
        itemCount: widget.list.length,
        itemBuilder: (context, index) {
          var shownUser = widget.list[index];
          return ListTile(
            leading: Icon(
              Icons.account_circle_rounded,
              size: 50,
            ),
            title: Text(
              shownUser,
              style: TextStyle(fontSize: 20),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(shownUser, widget.visitor),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void oneAlertBox(BuildContext context, String title) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          actions: <Widget>[
            // ignore: deprecated_member_use
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                            ),
                          ],
                        ),
                        Image.network(post.imageUrl),
                        Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.favorite),
                              onPressed: () {},
                              color: post.usersLiked.contains(post.userName)
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
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 7, 10),
                                child: Text(
                                  post.userName,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                )),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 10, 10),
                              child: Text(post.caption),
                            )
                          ],
                        )
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

bool containsSpecial(String value) {
  //var dumdum = new RegExp(r'[$#]');

  Set<String> chars = {
    " ",
    "!",
    "%",
    "&",
    "'",
    "(",
    ")",
    "*",
    "+",
    "-",
    "/",
    ":",
    ";",
    "<",
    "=",
    ">",
    "?",
    "@",
    "[",
    "\\",
    "]",
    "^",
    '`',
    "{",
    "|",
    "}",
    "~"
  };
  bool rvalue = false;
  for (int i = 0; i < value.length; i++) {
    if (chars.contains(value[i])) {
      rvalue = true;
      break;
    }
  }
  return rvalue;
}

String giveMonth(int num) {
  const List<String> months = [
    "January",
    "Feburary",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    'December'
  ];
  return months[num - 1];
}

Future<String> getPfp(String whos) async {
  DataSnapshot x =
      await databaseReference.child("user_details/" + whos + "/pfp").once();
  return x.value;
}
