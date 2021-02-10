import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Neon",
      theme: ThemeData(
          primaryColor: Colors.pink,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: SignInPage(),
    );
  }
}

class TextInput extends StatefulWidget {
  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: this.controller,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.message),
        labelText: "Username",
        suffixIcon: IconButton(
          icon: Icon(Icons.send),
          splashColor: Colors.pinkAccent[100],
          onPressed: () => {},
        ),
      ),
    );
  }
}
