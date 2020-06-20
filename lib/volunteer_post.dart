import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:ngo_app/home_page.dart';
import './home_page.dart';

class VolunteerPhotoPage extends StatefulWidget {
  @override
  _VolunteerPhotoPageState createState() => _VolunteerPhotoPageState();
}

class _VolunteerPhotoPageState extends State<VolunteerPhotoPage> {
  File sampleImage;
  String _myValue;
  String _formLink;
  String url;
  final formKey = GlobalKey<FormState>();

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      sampleImage = tempImage;
    });
  }

  bool validateAndSave(){
    final form=formKey.currentState;
    if(form.validate()){
      form.save();
      return true;
    }
    else{
      return false;
    }
  }

  void uploadImage() async{
    if(validateAndSave()){
      //To store in Firebase Storage
      final StorageReference postImageRef=FirebaseStorage.instance.ref().child("Post Images");
      var timeKey=DateTime.now();
      final StorageUploadTask uploadTask=postImageRef.child(timeKey.toString()+".jpg").putFile(sampleImage);

      //To get URL of Stored Image from Firebase Storage
      var ImageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
      url=ImageUrl.toString();
      print("Image Url="+url);

      goToHomePage();
      //To save URL in Firebase Database
      saveToDatabase(url);

    }
  }

  void saveToDatabase(url){
    var dbTimeKey=DateTime.now();
    var formatDate=DateFormat("MMM d,yyyy");
    var formatTime=DateFormat('EEE, hh::mm aaa');

    String date=formatDate.format(dbTimeKey);
    String time=formatTime.format(dbTimeKey);

    DatabaseReference ref=FirebaseDatabase.instance.reference();

    var data = {
      "image":url,
      "description": _myValue,
      "link":_formLink,
      "date":date,
      "time":time,
    };

    ref.child("Posts").push().set(data);

  }

  void goToHomePage(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
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
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) {
                return value.isEmpty ? 'Description is required' : null;
              },
              onSaved: (value) {
                return _myValue = value;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Google Form\'s Link'),
              validator: (value) {
                return value.isEmpty ? 'Link is required' : null;
              },
              onSaved: (value) {
                return _formLink = value;
              },
            ),
            SizedBox(height:15),
            RaisedButton(
              elevation: 10,
              child:Text('Create Post'),
              textColor: Colors.white,
              color:Colors.pink,
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
        title: Text("Volunteers Requirement Post"),
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
