import 'package:firebase_database/firebase_database.dart';

final _databaseReference = FirebaseDatabase.instance.reference();

Map<String, dynamic> toJson(String user, String pass, String mail) {
  return {
    'pass': pass,
    'mail': mail,
  };
}

void registerUser(String userName, String pass, String mail, String name) {
  _databaseReference.child('credentials/' + userName).set(toJson(userName, pass, mail));
  _databaseReference.child('user_details/' + userName).set({
    'followers': [userName],
    'following': [userName],
    'pfp': '',
    'bio': '',
    'name': name,
  });
}

Future<bool> checkCredentials(String userName, String pass) async {
  //String temp = '';
  //bool value = false;
  //
  Map<String, dynamic> rvalue = {
    'pass': "",
  };

  DataSnapshot dataSnapshot = await _databaseReference.child('credentials/' + userName).once();
  print('hiiiiiiiiii');

  try {
    dataSnapshot.value.forEach((key, value) {
      rvalue[key] = value;
    });
  } on NoSuchMethodError {
    print('Wrong username or password entered');
  }

  if (rvalue['pass'] == pass)
    return true;
  else
    return false;
}
