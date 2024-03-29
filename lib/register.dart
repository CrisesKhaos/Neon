import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:main/sign_in.dart';
import 'package:main/widgets.dart';
import 'creds_database.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_database/firebase_database.dart';
import 'package:email_validator/email_validator.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final databaseReference = FirebaseDatabase.instance.reference();
  TextEditingController userController = new TextEditingController();
  TextEditingController passController = new TextEditingController();
  TextEditingController mailController = new TextEditingController();
  TextEditingController confirmController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  var userError;
  var passError;
  var mailError;
  bool userAvailable = false;
  bool goodPass = false;
  bool goodmail = false;
  bool samePass = false;
  bool goodname = false;
  bool passhidden = true;
  DatabaseReference userSnap;

  void giveError(var errorType, {String type}) {
    this.setState(() {
      if (type == "pass")
        passError = errorType;
      else if (type == "mail")
        mailError = errorType;
      else
        userError = errorType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(physics: ScrollPhysics(), children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: MediaQuery.of(context).size.height + 50,
              width: MediaQuery.of(context).size.width,
            ),
            Container(
              height: MediaQuery.of(context).size.height / 2,
              width: 9 * MediaQuery.of(context).size.width / 10,
              decoration: BoxDecoration(color: Color.fromRGBO(255, 0, 103, 1)),
            ),
            Positioned(
              right: 39,
              top: (MediaQuery.of(context).size.height / 10) - 30,
              child: RichText(
                text: TextSpan(
                  text: "welcome to",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: 'Glacial',
                      fontStyle: FontStyle.normal,
                      letterSpacing: 12.4),
                ),
              ),
            ),
            Positioned(
              right: 30,
              top: (MediaQuery.of(context).size.height / 10) - 20,
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
              top: (MediaQuery.of(context).size.height / 4) - 25,
              width: MediaQuery.of(context).size.width,
              child: Card(
                elevation: 15,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                  Radius.circular(15),
                )),
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: <Widget>[
                    Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 35, 20, 10),
                          child: TextField(
                            controller: userController,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(width: 5, color: Colors.yellow)),
                                labelText: "USERNAME",
                                suffixIcon: userController.text.isNotEmpty
                                    ? userAvailable
                                        ? Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.green,
                                          )
                                        : Icon(
                                            Icons.cancel_rounded,
                                            color: Colors.red[800],
                                          )
                                    : null,
                                errorText: userError,
                                errorMaxLines: 2),
                            onChanged: (text) {
                              //? wtf is happening here pls sendhelp
                              userSnap = databaseReference.child('credentials/' + userController.text);

                              userSnap.once().then((snapshot) {
                                if (snapshot.value != null && userController.text != "")
                                  setState(() {
                                    userAvailable = false;
                                  });
                                else if (containsSpecial(text)) {
                                  giveError(
                                      "Username cannot contain any special character except '_' and '.' ");
                                  setState(() {
                                    userAvailable = false;
                                  });
                                } else if (userController.text != "")
                                  setState(() {
                                    userError = null;
                                    userAvailable = true;
                                  });
                              });
                            },
                          ),
                        )),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.perm_contact_cal_sharp),
                            border:
                                OutlineInputBorder(borderSide: BorderSide(width: 5, color: Colors.yellow)),
                            labelText: "Full Name",
                          ),
                          onChanged: (text) {
                            if (nameController.text.isNotEmpty)
                              setState(() {
                                goodname = true;
                              });
                            else
                              setState(() {
                                goodname = false;
                              });
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: TextField(
                          controller: mailController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.local_post_office_outlined),
                            border:
                                OutlineInputBorder(borderSide: BorderSide(width: 5, color: Colors.yellow)),
                            labelText: "E-Mail",
                          ),
                          onChanged: (text) {
                            if (EmailValidator.validate(text))
                              setState(() {
                                goodmail = true;
                              });
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: TextField(
                          controller: passController,
                          obscureText: passhidden,
                          autocorrect: false,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline),
                              border:
                                  OutlineInputBorder(borderSide: BorderSide(width: 5, color: Colors.yellow)),
                              labelText: "PASSWORD",
                              errorText: passError,
                              suffixIcon: passController.text.isNotEmpty
                                  ? passhidden
                                      ? IconButton(
                                          icon: Icon(Icons.remove_red_eye),
                                          onPressed: () {
                                            setState(() {
                                              passhidden = !passhidden;
                                            });
                                          },
                                        )
                                      : IconButton(
                                          icon: Icon(Icons.remove_red_eye_outlined),
                                          onPressed: () {
                                            setState(() {
                                              passhidden = !passhidden;
                                            });
                                          },
                                        )
                                  : null,
                              errorMaxLines: 5),
                          onChanged: (text) {
                            if (text.length > 7 &&
                                text.contains(RegExp(r'[A-Z]')) &&
                                text.contains(RegExp(r'[a-z]')) &&
                                text.contains(RegExp(r'[0-9]'))) {
                              setState(() {
                                goodPass = true;
                                passError = null;
                              });
                            } else {
                              giveError(
                                  "Your password should be more than 8 characters and should contain\n- a mix  of Upper and Lower-Case letters [Aa -Zz]\n- at least one number [0-9]",
                                  type: "pass");
                              setState(() {
                                goodPass = false;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: TextField(
                          controller: confirmController,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline),
                            border:
                                OutlineInputBorder(borderSide: BorderSide(width: 5, color: Colors.yellow)),
                            labelText: "CONFIRM PASSWORD",
                            suffixIcon: confirmController.text.isNotEmpty
                                ? samePass
                                    ? Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.green,
                                      )
                                    : Icon(
                                        Icons.cancel_rounded,
                                        color: Colors.red[800],
                                      )
                                : null,
                          ),
                          onChanged: (text) {
                            if (text == passController.text)
                              setState(() {
                                samePass = true;
                              });
                            else
                              setState(() {
                                samePass = false;
                              });
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                      // ignore: deprecated_member_use
                      child: RaisedButton(
                          color: Color.fromRGBO(32, 179, 179, 1),
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 5),
                          //highlightedBorderColor: Colors.pink,
                          //borderSide: BorderSide(width: 2, color: Colors.pinkAccent[100]),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                          child: Text(
                            "Register",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            //? fix this
                            if (userAvailable && goodPass && goodmail) {
                              registerUser(userController.text.toLowerCase().trim(), passController.text,
                                  mailController.text, nameController.text);
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HomePage(userController.text.toLowerCase().trim())),
                                  (route) => false);
                            } else if (!userAvailable)
                              oneAlertBox(context, 'Enter a valid username my man');
                            else if (!goodPass)
                              oneAlertBox(context, "Enter a valid password");
                            else if (!samePass)
                              oneAlertBox(context, "Your passwords do not match!");
                            else if (!goodname)
                              oneAlertBox(context, "Please enter a name");
                            else if (!goodmail) oneAlertBox(context, "Your E-Mail is invalid");
                          }),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account ? ",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: "Sign in",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(255, 0, 103, 1),
                                ),
                                recognizer: new TapGestureRecognizer()
                                  ..onTap = () => Navigator.push(
                                      context, MaterialPageRoute(builder: (context) => SignInPage())),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
