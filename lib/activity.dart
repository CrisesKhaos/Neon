import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:main/creds_database.dart';

class ActivityPage extends StatefulWidget {
  final user;
  @override
  _ActivityPageState createState() => _ActivityPageState();

  ActivityPage(this.user);
}

class _ActivityPageState extends State<ActivityPage> {
  List<Map<dynamic, dynamic>> main = [];

  Future<String> getPfp(String whos) async {
    DataSnapshot x =
        await databaseReference.child("user_details/" + whos + "/pfp").once();
    return x.value;
  }

  void getActivity() {
    databaseReference
        .child("activity/" + widget.user)
        .orderByChild('time')
        .onChildAdded
        .listen((event) {
      if (!mounted) return;
      setState(() {
        main.add(event.snapshot.value);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getActivity();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      this.main = main.reversed.toList();
    });
    print(main);
    if (main.length != 0)
      return Scaffold(
        body: ListView.builder(
          itemCount: main.length,
          itemBuilder: (ctx, index) {
            return Card(
              margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
              elevation: 5,
              child: Container(
                decoration: main[index]['action'] == 'neon'
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        shape: BoxShape.rectangle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple,
                            Colors.pink,
                          ],
                        ),
                      )
                    : null,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 5),
                  onTap: () {},
                  leading: FutureBuilder(
                    future: getPfp(main[index]["user"]),
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
                      return Container();
                    },
                  ),
                  title: main[index]["action"] == "liked"
                      ? Text(
                          main[index]["user"] + " liked your post.",
                          style: TextStyle(fontSize: 17),
                        )
                      : main[index]['action'] == "following"
                          ? Text(
                              main[index]["user"] + " started following you.",
                              style: TextStyle(fontSize: 17),
                            )
                          : main[index]['action'] == "comment"
                              ? Text(
                                  main[index]["user"] +
                                      " commented on your post:",
                                  style: TextStyle(fontSize: 17),
                                )
                              : main[index]['action'] == 'neon'
                                  ? Text(
                                      main[index]["user"] +
                                          " neoned your post!",
                                      style: TextStyle(
                                          fontSize: 17, color: Colors.white),
                                    )
                                  : null,
                  trailing: main[index]["action"] == "liked" ||
                          main[index]['action'] == 'comment' ||
                          main[index]['action'] == 'neon'
                      ? Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Image.network(main[index]["post"]),
                        )
                      : Text(''),
                  subtitle: main[index]['action'] == 'comment'
                      ? Text(main[index]['comment'])
                      : null,
                ),
              ),
            );
          },
        ),
      );
    else
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "😐",
              style: TextStyle(
                fontSize: 100,
              ),
            ),
            Text(
              "No activity yet",
              style: TextStyle(fontSize: 25),
            )
          ],
        ),
      );
  }
}
