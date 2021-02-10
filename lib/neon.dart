import 'package:firebase_database/firebase_database.dart';
import 'package:main/creds_database.dart';

class Neon {
  final String post;
  final String user;
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

  void toDatabase() async {
    databaseReference
        .child('Neons/' + owner)
        .child(DateTime.now().year.toString())
        .child(DateTime.now().month.toString())
        .set({"post": this.post, "user": this.user});
  }
}
