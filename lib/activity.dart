import 'package:flutter/material.dart';
import 'package:main/creds_database.dart';

class ActivityPage extends StatefulWidget {
  final user;
  @override
  _ActivityPageState createState() => _ActivityPageState();

  ActivityPage(this.user);
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: databaseReference.child("activity/" + widget.user).once(),
      builder: (context, _snapshot) {
        Map<dynamic, dynamic> temp = _snapshot.data.value;
        List names = temp.keys.toList();
        _snapshot.data.value.forEach((key, value) {});
        return ListView.builder(
          itemCount: temp.keys.toList().length,
          itemBuilder: (ctx, index) {
            return Card(
              margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
              elevation: 5,
              child: ListTile(
                onTap: () {},
                leading: Icon(
                  Icons.account_circle,
                  size: 50,
                ),
                title: Text(
                  names[index] + " liked your post",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
