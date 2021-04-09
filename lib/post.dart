import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'database.dart';

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
    if (user != this.userName)
      hasLiked.contains(user) ? print('ho') : updateActivity(user, true);
  }

  void updateActivity(String liker, bool liked) async {
    hasLiked.add(liker);
    databaseReference.child('posts/' + this.userName + "/" + this.rand).update(
      {'hasLiked': this.hasLiked.toList()},
    );
    databaseReference.child("activity/" + this.userName).push().set({
      "post": this.imageUrl,
      "action": "liked",
      "liker": liker,
    });
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
  post.usersLiked = new Set.from(attributes['usersLiked']);
  post.hasLiked = new Set.from(attributes['hasLiked']);
  post.neon = new Set.from(attributes['neon']);
  return post;
}
