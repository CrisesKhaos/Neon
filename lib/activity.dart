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
  Future<String> getPfp(String whos) async {
    DataSnapshot x =
        await databaseReference.child("user_details/" + whos + "/pfp").once();
    return x.value;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: databaseReference.child("activity/" + widget.user).once(),
        builder: (context, AsyncSnapshot _snapshot) {
          if (_snapshot.hasData) {
            if (_snapshot.data.value != null) {
              Map<dynamic, dynamic> temp = _snapshot.data.value;
              List<Map<dynamic, dynamic>> names = [];
              temp.forEach((key, value) {
                names.add(value);
              });
              return ListView.builder(
                itemCount: names.length,
                itemBuilder: (ctx, index) {
                  return Card(
                    margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    elevation: 5,
                    child: ListTile(
                      onTap: () {},
                      leading: FutureBuilder(
                        future: getPfp(names[index]["liker"]),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
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
                      title: Text(
                        names[index]["liker"] + " liked your post",
                        style: TextStyle(fontSize: 20),
                      ),
                      trailing: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Image.network(names[index]["post"]),
                      ),
                    ),
                  );
                },
              );
            } else
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
          } else
            return LinearProgressIndicator();
        });
  }
}
