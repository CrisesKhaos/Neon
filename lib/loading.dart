import 'dart:math';

import 'package:flutter/material.dart';
import 'package:main/sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';

import 'home_page.dart';

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  String validatorString;
  Future<String> getValidationData() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tempUsername = sharedPreferences.getString(("user"));
    print(tempUsername.toString() + "yeeeeeeeeeeettt");
    return tempUsername;
  }

  List<String> texts = [
    "Do you know joe?",
    "The floor is made up of floor",
    "Americans on average eat 18 acres of pizza every day",
    "The house fly hums in the middle octave key of F",
    "Joe Deez has been diagnosed with ligma",
    "Every sixty seconds in Africa, a minute passes",
    "Salt used to be a currency",
    "Junk food is as addictive as drugs",
    "It’s impossible to tickle yourself",
    "Ezra is a bot",
    "In 2016, Mozart sold more CDs than Beyonce",
    "The country of Russia is bigger than Pluto",
    "Bears don’t poop during hibernation",
    "A second is called a second for a reason",
    "A blob of toothpaste is called a nurdle",
    "Ice cream warms the body",
    "Pepsi is named after indigestion"
  ];

  @override
  void initState() {
    super.initState();

    getValidationData().then((value) {
      setState(() {
        this.validatorString = value;
      });
    });
  }

  Widget build(BuildContext context) {
    return SplashScreen(
        seconds: 4,
        navigateAfterSeconds: validatorString != null ? HomePage(validatorString) : SignInPage(),
        title: Text(
          texts[Random().nextInt(texts.length)],
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontFamily: "Glacial", fontSize: 20),
        ),
        image: Image.asset('assets/icon/icon.png'),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100,
        loaderColor: Colors.pink[200]);
  }
}
