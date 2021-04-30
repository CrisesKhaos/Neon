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
                border: OutlineInputBorder(borderSide: BorderSide(width: 10, color: Colors.yellow)),
                labelText: "Enter Your Password",
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send_rounded),
                  onPressed: () {
                    _snapshot.data.value['pass'] == passController.text
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditProfile(widget.userName)),
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
  TextEditingController bioCont = new TextEditingController();
  DataSnapshot uDetails;
  DataSnapshot _snapshot;
  bool samePass = true;
  bool passChanged = false;
  bool goodPass = false;
  bool mailChanged = false;
  bool bioChanged = false;
  String url;
  String passError;
  final uuid = Uuid();
  getDetails() async {
    DataSnapshot y = await databaseReference.child("user_details/" + widget.userName).once();
    DataSnapshot x = await databaseReference.child("credentials/" + widget.userName).once();
    setState(() {
      uDetails = y;
      _snapshot = x;
    });
  }

  void giveError(String errorType) {
    this.setState(() => passError = errorType);
  }

  @override
  void initState() {
    super.initState();
    getDetails().whenComplete(
      () {
        this.mailController.text = _snapshot.value['mail'];
        this.bioCont.text = uDetails.value["bio"];
        url = uDetails.value["pfp"];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
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
                  border: OutlineInputBorder(borderSide: BorderSide(width: 10, color: Colors.yellow)),
                  labelText: _snapshot.key,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            //? bio text field
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: this.bioCont,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.biotech),
                  border: OutlineInputBorder(borderSide: BorderSide(width: 10, color: Colors.yellow)),
                  labelText: "Biology",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
                onChanged: (value) {
                  if (!bioChanged && value.trim() != uDetails.value["bio"])
                    setState(() {
                      bioChanged = true;
                    });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: this.mailController,
                //enabled: false,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.mail_outline),
                  border: OutlineInputBorder(borderSide: BorderSide(width: 10, color: Colors.yellow)),
                  labelText: "E-mail",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
                onChanged: (text) {
                  if (text.trim() != _snapshot.value["mail"].trim())
                    setState(() {
                      if (!mailChanged) mailChanged = true;
                    });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: this.passController,
                autocorrect: false,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(borderSide: BorderSide(width: 10, color: Colors.yellow)),
                  labelText: "New Password",
                  errorText: passError,
                  errorMaxLines: 5,
                ),
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
                    );
                    setState(() {
                      goodPass = false;
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: this.confirmController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(borderSide: BorderSide(width: 10, color: Colors.yellow)),
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
                    passController.text == confirmController.text ? samePass = true : samePass = false;
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
                      if (!goodPass)
                        awesomeDialog(context, "Smol brain", "Enter a valid password", false);
                      else if (passController.text.isEmpty && mailChanged == true)
                        databaseReference.child("credentials/" + widget.userName).update({
                          "mail": this.mailController.text,
                        });
                      else if (passController.text.isNotEmpty && samePass == false)
                        oneAlertBox(context, "Your passwords do not match");
                      else if (passController.text.isNotEmpty && samePass == true)
                        databaseReference
                            .child("credentials/" + widget.userName)
                            .update({"mail": this.mailController.text, "pass": this.confirmController.text});
                      if (bioChanged)
                        databaseReference.child("user_details/" + widget.userName).update({
                          "bio": bioCont.text.trim(),
                        });
                      if (goodPass)
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage(widget.userName)),
                            (route) => false);
                      return;
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
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

      var snpsht = await _storage.ref().child('pfp/' + user + '/' + this.uuid.v4()).putFile(croppedImage);
      postUrl = await snpsht.ref.getDownloadURL();
      databaseReference.child('user_details/' + user).update({"pfp": postUrl});
    } else {
      print("No path my man");
    }
    //return postUrl;
  }
}
