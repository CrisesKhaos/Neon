import 'package:firebase_database/firebase_database.dart';
import 'package:main/post.dart';

final databaseReference = FirebaseDatabase.instance.reference();

DatabaseReference savePost(Post post) {
  var id = databaseReference.child('posts/').push();
  //id.set(post.toJson());
  return id;
}

void updatePost(Post post, DatabaseReference id) {
  //id.update(post.toJson());
}

Future<List<Post>> returnpostList(String timelineUser) async {
  DataSnapshot dataSnapshot =
      await databaseReference.child('timelines/' + timelineUser).once();
  List<Post> posts = [];
  // looops through every user
  //key is the user
  //value is evert post of the user
  // if (dataSnapshot.value != null) {
  //Map<dynamic, dynamic> values = await dataSnapshot.value;
  //print(values);
  if (dataSnapshot.value != null) {
    dataSnapshot.value.forEach(
      (key, value) async {
        List postValues = value.split('(split)');
        //var postPath = postValues[0] + '/'+ postValues[1];
        print(postValues);

        DataSnapshot postSnapshot = await databaseReference
            .child('posts/' + postValues[0] + "/" + postValues[1])
            .once();
        print(postSnapshot.value);
        Post post =
            createPost(postValues[0], postSnapshot.value, postValues[1]);
        print(post);

        posts.add(post);
      },
    );
    print('i got till here');
    print('hmmmmmmmmmmmmmmm');
    return posts;
  }
}
