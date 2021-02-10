import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:main/user_details.dart';
import 'package:main/user_profile_page.dart';

import 'home_page.dart';

final databaseReference = FirebaseDatabase.instance.reference();

class DiscoverPage extends StatefulWidget {
  final String currentUser;
  DiscoverPage(this.currentUser);
  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  List<UserDetails> _userDetails = [];
  final databaseReference = FirebaseDatabase.instance.reference();
  @override
  void initState() {
    super.initState();
    returnUserlist().then((users) {
      setState(() {
        this._userDetails = users;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _userDetails.length,
        itemBuilder: (context, index) {
          var shownUser = _userDetails[index];
          shownUser.getDetails();
          print(shownUser.pfp);
          return Card(
            margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
            elevation: 5,
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(shownUser.user, widget.currentUser)),
                );
              },
              leading: Icon(
                Icons.account_circle,
                size: 50,
              ),
              title: Text(
                shownUser.user,
                style: TextStyle(fontSize: 20),
              ),
            ),
          );
        },
      ),
    );
  }
}
