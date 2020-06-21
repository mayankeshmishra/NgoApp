import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ngo_app/home_page.dart';
import './home_page.dart';

class TransactionPhotoPage extends StatefulWidget {
  @override
  _TransactionPhotoPageState createState() => _TransactionPhotoPageState();
}

class _TransactionPhotoPageState extends State<TransactionPhotoPage> {
  File sampleImage;
  String _myValue;
  String _myAmount;
  String url;
  String uid = "";
  String ngoName;
  final formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;

  void initState() {
    super.initState();

    DatabaseReference postsRef =
        FirebaseDatabase.instance.reference().child("NGO");
    postsRef.once().then((DataSnapshot snap) async {
      var KEYS = snap.value.keys;
      var DATA = snap.value;
      String id = await inputData();
      for (var indivisualKey in KEYS) {
        if (DATA[indivisualKey]['id'] == id) {
          ngoName = DATA[indivisualKey]['name'];
        }
      }
      setState(() {});
    });
  }

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      sampleImage = tempImage;
    });
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  Future<String> inputData() async {
    final FirebaseUser user = await auth.currentUser();
    return (user.uid);
    // here you write the codes to input the data into firestore
  }

  void uploadImage() async {
    if (validateAndSave()) {
      //To store in Firebase Storage
      final StorageReference postImageRef =
          FirebaseStorage.instance.ref().child("Transaction Images");
      var timeKey = DateTime.now();
      final StorageUploadTask uploadTask =
          postImageRef.child(timeKey.toString() + ".jpg").putFile(sampleImage);

      //To get URL of Stored Image from Firebase Storage
      var ImageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
      url = ImageUrl.toString();

      goToHomePage();
      //To save URL in Firebase Database
      saveToDatabase(url);
    }
  }

  void saveToDatabase(url) {
    var dbTimeKey = DateTime.now();
    var formatDate = DateFormat("MMM d,yyyy");
    var formatTime = DateFormat('EEE, hh::mm aaa');

    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);

    DatabaseReference ref = FirebaseDatabase.instance.reference();

    var data = {
      "image": url,
      "description": _myValue,
      "amount": _myAmount,
      "date": date,
      "time": time,
      "name": ngoName,

    };

    ref.child("Transactions").push().set(data);
  }

  void goToHomePage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  Widget enableUpload() {
    return Container(
      margin: EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: ListView(
          children: <Widget>[
            Image.file(
              sampleImage,
              height: 330,
              width: 630,
            ),
            SizedBox(height: 15),
            TextFormField(
              decoration: InputDecoration(labelText: 'Amount Recieved'),
              validator: (value) {
                return value.isEmpty ? 'Amount is required' : null;
              },
              onSaved: (value) {
                return _myAmount = value;
              },
            ),
            SizedBox(height: 15),
            TextFormField(
              decoration:
                  InputDecoration(labelText: 'Description About Expenditure'),
              validator: (value) {
                return value.isEmpty ? 'Description is required' : null;
              },
              onSaved: (value) {
                return _myValue = value;
              },
            ),
            SizedBox(height: 15),
            RaisedButton(
              elevation: 10,
              child: Text('Upload'),
              textColor: Colors.white,
              color: Colors.pink,
              onPressed: uploadImage,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Transaction Image"),
        centerTitle: true,
      ),
      body: Center(
        child: sampleImage == null ? Text("Select an Image") : enableUpload(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Add Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
