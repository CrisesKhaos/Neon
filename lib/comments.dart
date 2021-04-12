import 'package:flutter/material.dart';
import 'package:main/creds_database.dart';
import 'package:main/post.dart';
import 'widgets.dart';

class Comment {
  final String owner;
  final String comment;

  Comment(this.owner, this.comment);
}

class CommentsPage extends StatefulWidget {
  final Post post;
  CommentsPage(this.post);
  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  List<Comment> comments = [];

  getComments20() async {
    databaseReference
        .child("posts/" + widget.post.userName + "/" + widget.post.rand)
        .child("comments")
        .once()
        .then((snap) {
      print(snap.value);
      snap.value.forEach((key, value) {
        setState(() {
          comments.add(
            new Comment(value['user'], value['comment']),
          );
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();

    getComments20();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comments"),
      ),
      body: ListView.builder(
        itemCount: this.comments.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: FutureBuilder(
              future: getPfp(comments[index].owner),
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
                return CircularProgressIndicator();
              },
            ),
            title: RichText(
              text: TextSpan(
                  text: comments[index].owner + "  ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 20),
                  children: [
                    TextSpan(
                      text: comments[index].comment,
                      style: TextStyle(fontWeight: FontWeight.normal),
                    )
                  ]),
            ),
          );
        },
      ),
    );
  }
}
