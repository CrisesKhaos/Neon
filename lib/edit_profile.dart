// ignore: unused_import
import 'widgets.dart';
import 'package:flutter/material.dart';
import 'package:main/creds_database.dart';

class PreEditProfile extends StatefulWidget {
  final String userName;
  PreEditProfile(this.userName);
  @override
  _PreEditProfileState createState() => _PreEditProfileState();
}

class _PreEditProfileState extends State<PreEditProfile> {
  TextEditingController passController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: databaseReference.child("credentials/" + widget.userName).once(),
      builder: (context, _snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Enter Passsword"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: passController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                    borderSide: BorderSide(width: 10, color: Colors.yellow)),
                labelText: "Enter Your Password",
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send_rounded),
                  onPressed: () {
                    _snapshot.data.value['pass'] == passController.text
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EditProfile(widget.userName)),
                          )
                        : oneAlertBox(context, "Wrong password entered");
                    passController.clear();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class EditProfile extends StatefulWidget {
  final String userName;
  @override
  EditProfile(this.userName);
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: databaseReference.child("credentials/" + widget.userName).once(),
      builder: (context, _snapshot) {
        if (_snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Edit Profile'),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_circle,
                  size: 170,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    //enabled: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 10, color: Colors.yellow)),
                      labelText: _snapshot.data.key,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    //enabled: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.mail_outline),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 10, color: Colors.yellow)),
                      labelText: _snapshot.data.value['mail'],
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 10, color: Colors.yellow)),
                        labelText: "Confirm Password"),
                  ),
                ),
                Row(
                  children: [
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        child: Text("Change Password"),
                        onPressed: null,
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        } else {
          return LinearProgressIndicator();
        }
      },
    );
  }
}
