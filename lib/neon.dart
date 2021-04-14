import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'post.dart';
import 'home_page.dart';
import 'widgets.dart';

class Neon {
  final String post;
  //user the owner of the post which is being neoned
  final String user;
  //Owner is the person who is neoning the post
  final String owner;
  Neon(this.post, this.user, this.owner);
  Future<bool> monthExists() async {
    DataSnapshot neon = await databaseReference
        .child('Neons/' + owner)
        .child(DateTime.now().year.toString())
        .child(DateTime.now().month.toString())
        .once();
    return neon.value == null ? false : true;
  }

  void updatePost() async {
    DataSnapshot values =
        await databaseReference.child("posts/" + user).child(post).once();
    Post tempPost = createPost(user, values.value, this.post);
    Set hello = tempPost.neon;

    hello.add(owner);
    databaseReference.child('posts/' + this.user + "/" + this.post).update(
      {'neon': hello.toList()},
    );
    /*
        .then((_neoners) {
      if (_neoners.value == null) {
        List temp = [owner];
        databaseReference
            .child("posts/" + user)
            .child(post + "/neon")
            .set(temp);
      } else {
        Set temp = _neoners.value.toSet();
        print(temp);
        temp.add(owner);
        print(temp);

        databaseReference
            .child("posts/" + user + "/" + post)
            .update({"neon": temp.toList()});
      }
    });*/
  }

  void toDatabase() async {
    databaseReference
        .child('Neons/' + owner)
        .child(DateTime.now().year.toString())
        .set({
      DateTime.now().month.toString(): this.post + "(split)" + this.user
    });
    updatePost();
  }
}

class NeonPage extends StatefulWidget {
  final String user;
  final String visitor;
  NeonPage(this.user, this.visitor);
  @override
  _NeonPageState createState() => _NeonPageState();
}

class _NeonPageState extends State<NeonPage> {
  List<Post> neonTimeline = [];
  List months = [];

  void changelix(Function lix) {
    this.setState(() {
      lix();
    });
  }

  void getdata() async {
    DataSnapshot _snapshot =
        await databaseReference.child("Neons/" + widget.user).once();

    if (_snapshot.value != null) {
      Map<dynamic, dynamic> mainValues = _snapshot.value["2021"];
      List codes = mainValues.values.toList();
      List months = mainValues.keys.toList();
      setState(() {
        this.months = months;
      });
      codes.forEach((value) async {
        List postValues = value.split('(split)');
        print(postValues[0]);
        DataSnapshot postSnapshot = await databaseReference
            .child('posts/' + postValues[1] + "/" + postValues[0])
            .once();
        print(postSnapshot.value);
        if (postSnapshot.value != null) {
          Post tempPost =
              createPost(postValues[1], postSnapshot.value, postSnapshot.key);
          setState(() {
            neonTimeline.add(tempPost);
          });
        } else
          print("null");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getdata();
    print(neonTimeline);
  }

  @override
  Widget build(BuildContext context) {
    print(neonTimeline.length);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          widget.user + "'s" + ' Neons',
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: neonTimeline.length != 0
          ? ListView.builder(
              itemCount: neonTimeline.length,
              itemBuilder: (context, index) {
                Post post = neonTimeline[index];
                print(giveMonth(int.parse(months[index])));
                return Card(
                  elevation: 40,
                  shadowColor: Colors.pink[200],
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          giveMonth(int.parse(months[index])),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            child: FutureBuilder(
                              future: getPfp(post.userName),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.hasData) {
                                  print(snapshot.data);
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                          ),
                          Padding(
                            child: Text(post.userName),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
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
                              this.changelix(
                                  () => post.likePost(widget.visitor));
                            },
                            color: post.usersLiked.contains(widget.visitor)
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
                          Spacer(),
                          IconButton(
                            alignment: Alignment.center,
                            icon: post.neon.contains(widget.visitor)
                                ? Icon(Icons.label_important_rounded)
                                : Icon(Icons.label_important_outline_rounded),
                            onPressed: post.neon.contains(widget.visitor)
                                ? null
                                : () async {
                                    Neon neon = new Neon(post.rand,
                                        post.userName, widget.visitor);
                                    await neon.monthExists()
                                        ? oneAlertBox(context,
                                            "You can Neon only one post per month!")
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
              })
          : Center(
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
                    "No neons yet",
                    style: TextStyle(fontSize: 25),
                  )
                ],
              ),
            ),
    );
  }
}
