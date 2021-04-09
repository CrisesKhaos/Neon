// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_database/firebase_database.dart';
import 'package:main/post.dart';

final databaseReference = FirebaseDatabase.instance.reference();

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
      (key, _value) async {
        print(_value);
        List postValues = _value.split('(split)');
        //var postPath = postValues[0] + '/'+ postValues[1];
        DataSnapshot postSnapshot = await databaseReference
            .child('posts/' + postValues[0] + "/" + postValues[1])
            .once();
        print(postSnapshot.value);
        Post post =
            createPost(postValues[0], postSnapshot.value, postValues[1]);

        posts.add(post);
      },
    );
    print(posts);
    return posts;
  }
}
