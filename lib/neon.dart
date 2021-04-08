// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'post.dart';
import 'home_page.dart';

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
    print(tempPost.neon);
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
    /*databaseReference
        .child('Neons/' + owner)
        .child(DateTime.now().year.toString())
        .child(DateTime.now().month.toString())
        .set({"post": this.post, "user": this.user});*/
    updatePost();
  }
}

class NeonPage extends StatefulWidget {
  final String user;
  final String visitor;
  final List<Post> neons;
  NeonPage(this.user, this.visitor, this.neons);
  @override
  _NeonPageState createState() => _NeonPageState();
}

class _NeonPageState extends State<NeonPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink,
          title: Text(
            widget.user + 's' + ' Neons',
            style: TextStyle(fontSize: 25),
          ),
        ),
        body: PostList(widget.visitor));
  }
}
