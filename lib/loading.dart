import 'package:flutter/material.dart';
import 'package:main/sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  String validatorString;
  Future<String> getValidationData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var tempUsername = sharedPreferences.getString(("user"));
    print(tempUsername.toString() + "yeeeeeeeeeeettt");
    return tempUsername;
  }

  @override
  void initState() {
    super.initState();

    getValidationData().then((value) {
      setState(() {
        this.validatorString = value;
        if (validatorString != null)
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(validatorString)),
              (route) => false);
        else
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => SignInPage()),
              (route) => false);
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Text(
      "Loading....",
      style: TextStyle(fontSize: 25),
    )));
  }
}
