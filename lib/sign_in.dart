import 'package:flutter/material.dart';
import 'home_page.dart';
import 'creds_database.dart';
import 'register.dart';
import 'widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(),
    );
  }
}

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String name;
  var userError;
  var passError;
  String validatorString;
  TextEditingController userController = new TextEditingController();
  TextEditingController passController = new TextEditingController();
  @override
  void initState() {
    super.initState();
    getValidationData().then((value) {
      setState(() {
        this.validatorString = value;
        print(value + "yeeet");
        if (validatorString != null) toHomePage(validatorString);
      });
    });
  }

  Future<String> getValidationData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var tempUsername = sharedPreferences.getString(("user"));
    print(tempUsername.toString() + "yeeeeeeeeeeettt");
    return tempUsername;
  }

  void giveError(var errorType, {pass}) {
    this.setState(() {
      if (pass == null)
        userError = errorType;
      else
        passError = errorType;
    });
  }

  void toHomePage(String username) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => HomePage(userController.text)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 50, 0),
              child: TextField(
                  controller: userController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(width: 5, color: Colors.yellow)),
                    labelText: "USERNAME",
                    errorText: userError,
                  ),
                  onChanged: (text) {
                    containsSpecial(text)
                        ? giveError("Invalid username")
                        : giveError(null);
                  }),
            )),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.fromLTRB(50, 30, 0, 0),
            child: TextField(
              controller: passController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                    borderSide: BorderSide(width: 5, color: Colors.yellow)),
                labelText: "PASSWORD",
                errorText: passError,
              ),
              onChanged: (text) {
                if (text.isNotEmpty) giveError(null, pass: 1);
              },
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
          // ignore: deprecated_member_use
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.pinkAccent[200],
                padding: EdgeInsets.symmetric(horizontal: 130, vertical: 5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
              ),
              //highlightedBorderColor: Colors.pink,
              //borderSide: BorderSide(width: 2, color: Colors.pinkAccent[100]),
              child: Text(
                "Sign In",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                if (userController.text.isEmpty)
                  giveError("Enter a username");
                else if (passController.text.isEmpty)
                  giveError("Enter a password", pass: true);
                else if (await checkCredentials(
                    userController.text.toLowerCase(), passController.text)) {
                  final SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  sharedPreferences.setString(
                      ("user"), userController.text.toLowerCase());
                  print(getValidationData());
                  toHomePage(userController.text);
                } else {
                  oneAlertBox(context,
                      "The username and password you entered do not match");
                }
              }),
        ),
        /*Container(
          //padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
          child: OutlineButton(
            padding: EdgeInsets.symmetric(horizontal: 70, vertical: 5),
            highlightedBorderColor: Colors.pink,
            borderSide: BorderSide(width: 2, color: Colors.pinkAccent[100]),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage('assets/google_logo.png'),
                    height: 20,
                  ),
                  Padding(padding: EdgeInsets.only(left: 20)),
                  Text(
                    "Sign in with Google",
                    style: TextStyle(color: Colors.pink[400]),
                  ),
                ]),
            onPressed: () => {
              signInGoogle().then(
                (userCredential) => {
                  this.user = userCredential,
                  toHomePage(user.user.displayName),
                },
              )
            },
          ),
        ),*/
        Container(
          // ignore: deprecated_member_use
          child: OutlineButton(
            padding: EdgeInsets.symmetric(vertical: 7, horizontal: 125),
            child: Text(
              'Register',
              style: TextStyle(color: Colors.pinkAccent[200]),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            borderSide: BorderSide(width: 2, color: Colors.pinkAccent[100]),
            highlightedBorderColor: Colors.pink,
            onPressed: () {
              // ignore: unused_local_variable

              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RegisterPage()));
            },
          ),
        )
      ],
    );
  }
}
