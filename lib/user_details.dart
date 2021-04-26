// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_database/firebase_database.dart';

final databaseReference = FirebaseDatabase.instance.reference();

class UserDetails {
  final user;
  String pfp = "";
  String bio = "";
  List<dynamic> followers = [];
  List<dynamic> following = [];
  UserDetails(this.user);

  void getDetails() async {
    DataSnapshot _dataSnapshot = await databaseReference.child('user_details/' + this.user).once();
    this.pfp = _dataSnapshot.value['pfp'];
    this.bio = _dataSnapshot.value['bio'];
    this.followers = _dataSnapshot.value["followers"];
    this.following = _dataSnapshot.value["following"];
  }
}

Future<List<UserDetails>> returnUserlist() async {
  List<UserDetails> usersDetails = [];

  DataSnapshot _dataSnapshot = await databaseReference.child('user_details').once();
  _dataSnapshot.value.forEach((key, value) {
    UserDetails userDetail = new UserDetails(key);
    usersDetails.add(userDetail);
  });
  return usersDetails;
}
