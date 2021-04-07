import 'dart:async';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'database.dart';
import 'neon.dart';
import 'widgets.dart';

final reference = FirebaseDatabase.instance.reference();

class Post {
  final String imageUrl;
  final String userName;
  final String caption;
  Set usersLiked = {};
  Set comments = {};
  Set hasLiked = {};
  Set neon = {};
  var rand;
  //DatabaseReference postRef = reference.child('posts/' + this.userName);
  Post(this.userName, this.imageUrl, this.caption, {this.rand});

  Future<String> uploadToDatabase() async {
    var id;
    /* DataSnapshot snapshot =
          await reference.child('posts/' + this.userName).once();
      if (snapshot.value != null) {
        num = snapshot.value.numChildren();
        num += 1;
      } else
        num = 1;*/
    id = databaseReference.child('posts/' + this.userName).push();
    id.set({
      'post': this.imageUrl,
      'caption': this.caption,
      'usersLiked': [],
      'comments': [],
      'hasliked': [],
      'neon': []
    });

    return id.key;
  }

  void updateLix(String liker) {
    databaseReference.child('posts/' + this.userName + '/' + this.rand).update({
      "usersLiked": this.usersLiked.toList(),
    });
  }

  void likePost(String user) async {
    usersLiked.contains(user) ? usersLiked.remove(user) : usersLiked.add(user);
    updateLix(user);
    if (this.userName != user) {
      hasLiked.contains(user) ? print('ho') : updateActivity(user, true);
    }
  }

  void updateActivity(String liker, bool liked) async {
    hasLiked.add(liker);
    databaseReference.child('posts/' + this.userName + "/" + this.rand).update(
      {'hasLiked': this.hasLiked.toList()},
    );
    DataSnapshot setTemp =
        await databaseReference.child("activity/" + this.userName).once();
    if (setTemp.value != null) {
      Map<dynamic, dynamic> actTemp = setTemp.value;
      actTemp.addAll({liker: "liked"});
      await databaseReference.child("activity/" + this.userName).set(actTemp);
    } else {
      databaseReference
          .child("activity/" + this.userName)
          .set({liker: "liked"});
    }
  }
}

//creating this func to retrive the values fron the dtabse and store them in a list
Post createPost(String userName, var value, var key) {
  //List<Post> posts = [];
  Map<String, dynamic> attributes = {
    'post': '',
    'caption': '',
    'usersLiked': [],
    'comments': [],
    'hasLiked': [],
    'neon': []
  };
  value.forEach((key, value) {
    attributes[key] = value;
  });

  var post = new Post(
    userName,
    attributes['post'],
    attributes["caption"],
    rand: key,
  );
  print(post.usersLiked);
  post.usersLiked = new Set.from(attributes['usersLiked']);
  post.hasLiked = new Set.from(attributes['hasLiked']);
  post.neon = new Set.from(attributes['neon']);
  return post;
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
                post.likePost(user);
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
