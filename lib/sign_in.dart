import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'creds_database.dart';
// ignore: unused_import
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
        if (validatorString != null) toHomePage(validatorString);
      });
    });
  }

  Future<String> getValidationData() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tempUsername = sharedPreferences.getString(("user"));
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

  void dispose() {
    super.dispose();
    userController.dispose();
    passController.dispose();
  }

  void toHomePage(String username) {
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (context) => HomePage(userController.text)), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: MediaQuery.of(context).size.height - 100,
                width: MediaQuery.of(context).size.width,
              ),
              Container(
                height: MediaQuery.of(context).size.height / 2,
                width: 9 * MediaQuery.of(context).size.width / 10,
                decoration: BoxDecoration(color: Color.fromRGBO(255, 0, 103, 1)),
              ),
              Positioned(
                right: 30,
                top: (MediaQuery.of(context).size.height / 10) - 10,
                child: RichText(
                  text: TextSpan(
                      text: "neon",
                      style: TextStyle(
                        fontSize: 70,
                        color: Colors.white,
                        fontFamily: 'Vonique',
                        fontStyle: FontStyle.normal,
                      ),
                      children: [
                        TextSpan(
                            text: " ",
                            style: TextStyle(
                              fontSize: 15,
                              color: Color.fromRGBO(255, 0, 103, 1),
                            )),
                        TextSpan(
                            text: ".",
                            style: TextStyle(
                              color: Color.fromRGBO(255, 0, 103, 1),
                            ))
                      ]),
                ),
              ),
              Positioned(
                right: 41,
                top: MediaQuery.of(context).size.height / 10 + 65,
                child: RichText(
                  text: TextSpan(
                    text: "built different",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontFamily: 'Glacial',
                        fontStyle: FontStyle.normal,
                        letterSpacing: 7.1),
                  ),
                ),
              ),
              Positioned(
                top: (MediaQuery.of(context).size.height / 4) + 25,
                width: MediaQuery.of(context).size.width,
                child: Card(
                  elevation: 15,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  )),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 80, 20, 30),
                          child: TextField(
                              controller: userController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(width: 5, color: Colors.yellow)),
                                labelText: "USERNAME",
                                errorText: userError,
                              ),
                              onChanged: (text) {
                                containsSpecial(text) ? giveError("Invalid username") : giveError(null);
                              }),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: TextField(
                            style: TextStyle(color: Colors.black),
                            controller: passController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline),
                              border:
                                  OutlineInputBorder(borderSide: BorderSide(width: 5, color: Colors.yellow)),
                              labelText: "PASSWORD",
                              errorText: passError,
                            ),
                            onChanged: (text) {
                              if (text.isNotEmpty) giveError(null, pass: 1);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 50, 0, 50),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromRGBO(32, 179, 179, 1),
                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 5),
                              shape:
                                  RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
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
                                sharedPreferences.setString(("user"), userController.text.toLowerCase());
                                toHomePage(userController.text);
                                dispose();
                              } else {
                                oneAlertBox(context, "The username and password you entered do not match");
                              }
                            }),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 42,
                right: 110,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: RichText(
                      text: TextSpan(
                        text: "Dont have an account ? ",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: "Sign up",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(255, 0, 103, 1),
                            ),
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () => Navigator.push(
                                  context, MaterialPageRoute(builder: (context) => RegisterPage())),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


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