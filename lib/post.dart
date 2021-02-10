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
  var rand;
  //DatabaseReference postRef = reference.child('posts/' + this.userName);
  Post(this.userName, this.imageUrl, this.caption, {this.rand});

  Future<String> uploadToDatabase() async {
    var id;
    if (this.userName != null) {
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
      });
    }

    return id.key;
  }

  void updateLix() {
    print(rand);
    databaseReference.child('posts/' + this.userName + '/' + this.rand).update({
      "usersLiked": this.usersLiked.toList(),
    });
  }

  void likePost(String user) {
    usersLiked.contains(user) ? usersLiked.remove(user) : usersLiked.add(user);
    updateLix();
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
  return post;
}
