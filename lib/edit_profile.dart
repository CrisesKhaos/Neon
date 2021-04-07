// ignore: unused_import
import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:main/home_page.dart';
import 'package:uuid/uuid.dart';
import 'widgets.dart';
import 'package:flutter/material.dart';

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
      builder: (context, AsyncSnapshot _snapshot) {
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
  TextEditingController confirmController = new TextEditingController();
  TextEditingController passController = new TextEditingController();
  TextEditingController mailController = new TextEditingController();
  DataSnapshot uDetails;
  bool samePass = true;
  bool passChanged = false;
  bool mailChanged = false;
  String url;
  final uuid = Uuid();
  void getDetails() async {
    DataSnapshot y =
        await databaseReference.child("user_details/" + widget.userName).once();
    setState(() {
      uDetails = y;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: databaseReference.child("credentials/" + widget.userName).once(),
      builder: (context, AsyncSnapshot _snapshot) {
        if (_snapshot.hasData) {
          getDetails();
          this.mailController.text = _snapshot.data.value['mail'];
          url = uDetails.value["pfp"];

          if (url.isEmpty) print(url);
          //this.userController.text = _snapshot.data.key;
          return Scaffold(
            appBar: AppBar(
              title: Text('Edit Profile'),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    url.isEmpty
                        ? Icon(
                            Icons.account_circle,
                            size: 170,
                          )
                        : ClipOval(
                            child: Image.network(
                              url,
                              height: 170,
                              width: 170,
                              fit: BoxFit.cover,
                            ),
                          ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        uploadImage(widget.userName);
                      },
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    enabled: false,
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
                    controller: this.mailController,
                    //enabled: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.mail_outline),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 10, color: Colors.yellow)),
                      labelText: "E-mail",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onChanged: (text) {
                      if (text.trim() != _snapshot.data["mail"].trim())
                        setState(() {
                          passChanged = false;
                        });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: this.passController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 10, color: Colors.yellow)),
                        labelText: "New Password"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: this.confirmController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 10, color: Colors.yellow)),
                      labelText: "Confirm New Password",
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
                      setState(() {
                        passController.text == confirmController.text
                            ? samePass = true
                            : samePass = false;
                      });
                    },
                  ),
                ),
                Row(
                  children: [
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        child: Text("Confirm"),
                        onPressed: () async {
                          if (passController.text.isEmpty &&
                              mailChanged == true)
                            databaseReference
                                .child("credentials/" + widget.userName)
                                .update({
                              "mail": this.mailController.text,
                            });
                          else if (passController.text.isNotEmpty &&
                              samePass == false)
                            oneAlertBox(context, "Your passwords do not match");
                          else if (passController.text.isNotEmpty &&
                              samePass == true)
                            databaseReference
                                .child("credentials/" + widget.userName)
                                .update({
                              "mail": this.mailController.text,
                              "pass": this.confirmController.text
                            });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    HomePage(widget.userName)),
                          );
                          return;
                        },
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

  void uploadImage(String user) async {
    var postUrl;
    final _imgpicker = ImagePicker();
    PickedFile image;
    final _storage = FirebaseStorage.instance;
    image = await _imgpicker.getImage(
      source: ImageSource.gallery,
    );
    //var file = File(image.path);

    if (image != null) {
      File croppedImage = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 50,
        maxHeight: 1000,
        maxWidth: 1000,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: "Crop",
          toolbarColor: Colors.pink,
          backgroundColor: Colors.black,
          activeControlsWidgetColor: Colors.pink,
          toolbarWidgetColor: Colors.white,
        ),
      );
      //var llength = await _storage.ref().child('posts/' + user).list();

      var snpsht = await _storage
          .ref()
          .child('pfp/' + user + '/' + this.uuid.v4())
          .putFile(croppedImage);
      postUrl = await snpsht.ref.getDownloadURL();
      databaseReference.child('user_details/' + user).update({"pfp": postUrl});
    } else {
      print("No path my man");
    }
    //return postUrl;
  }
}
