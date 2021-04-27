import 'dart:io';
import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:main/widgets.dart';
import 'post.dart';
import 'package:uuid/uuid.dart';
import 'home_page.dart';

class NewPostPage extends StatefulWidget {
  final String userName;
  NewPostPage(this.userName);
  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final uuid = Uuid();
  String url;
  TextEditingController captioncont = new TextEditingController();
  final databaseReference = FirebaseDatabase.instance.reference();
  @override
  Widget build(BuildContext context) {
    if (url == null) uploadImage(widget.userName);
    print(url);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              if (url != null) {
                var post = new Post(widget.userName, url, captioncont.text);
                var id = await post.uploadToDatabase();
                List userFollowers = await getFollowers(widget.userName);
                updateTimelines(userFollowers, id);
                //toHomePage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage(widget.userName)),
                );
              } else
                oneAlertBox(context, "Select an Image");
            },
          )
        ],
      ),
      body: ListView(
        children: [
          if (url != null)
            Card(
              elevation: 5,
              color: Colors.pinkAccent[50],
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Image.network(url),
              ),
              margin: EdgeInsets.fromLTRB(10, 10, 10, 20),
            )
          else
            Placeholder(
              color: Colors.black,
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: TextField(
              minLines: 5,
              maxLines: 5,
              controller: captioncont,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide(width: 5, color: Colors.yellow)),
                labelText: 'Enter a caption',
              ),
            ),
          ),
        ],
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

      var snpsht = await _storage.ref().child('posts/' + user + '/' + uuid.v4()).putFile(croppedImage);
      postUrl = await snpsht.ref.getDownloadURL();
      print(postUrl);
      setState(() {
        url = postUrl;
      });
    } else {
      print("No path my man");
    }
    //return postUrl;
  }

  Future<List<dynamic>> getFollowers(String user) async {
    List<dynamic> followersList = [];
    DataSnapshot followersSnapshot =
        await databaseReference.child('user_details/' + widget.userName).child('followers').once();

    followersList = followersSnapshot.value.toList();

    return followersList;
  }

  void updateTimelines(List followers, String id) {
    followers.forEach((tempFollower) {
      databaseReference
          .child('timelines/' + tempFollower)
          .push()
          .set({"post": widget.userName + "(split)" + id, "time": DateTime.now().microsecondsSinceEpoch});
    });
  }
} //Class End
