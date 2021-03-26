import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:http/http.dart';
import 'package:main/user_profile_page.dart';

class ListWithAppBar extends StatefulWidget {
  final List list;
  final String heading;
  final String visitor;
  ListWithAppBar(this.list, this.heading, this.visitor);
  @override
  _ListWithAppBarState createState() => _ListWithAppBarState();
}

class _ListWithAppBarState extends State<ListWithAppBar> {
  @override
  Widget build(BuildContext context) {
    print(widget.heading);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.heading),
      ),
      body: ListView.builder(
        itemCount: widget.list.length,
        itemBuilder: (context, index) {
          var shownUser = widget.list[index];
          return ListTile(
            leading: Icon(
              Icons.account_circle_rounded,
              size: 50,
            ),
            title: Text(
              shownUser,
              style: TextStyle(fontSize: 20),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(shownUser, widget.visitor),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void oneAlertBox(BuildContext context, String title) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}

bool containsSpecial(String value) {
  //var dumdum = new RegExp(r'[$#]');

  Set<String> chars = {
    " ",
    "!",
    "%",
    "&",
    "'",
    "(",
    ")",
    "*",
    "+",
    "-",
    "/",
    ":",
    ";",
    "<",
    "=",
    ">",
    "?",
    "@",
    "[",
    "\\",
    "]",
    "^",
    '`',
    "{",
    "|",
    "}",
    "~"
  };
  bool rvalue = false;
  for (int i = 0; i < value.length; i++) {
    if (chars.contains(value[i])) {
      rvalue = true;
      break;
    }
  }
  return rvalue;
}
