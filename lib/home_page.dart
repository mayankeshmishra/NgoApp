import 'package:flutter/material.dart';
import 'package:ngo_app/photoUpdate.dart';
import './authentication.dart';
import './photoUpdate.dart';
import './posts.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSignedOut});
  final AuthImplementation auth;
  final VoidCallback onSignedOut;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Posts> postsList = [];

  @override
  void initState() {
    super.initState();

    DatabaseReference postsRef =
        FirebaseDatabase.instance.reference().child("Posts");
    postsRef.once().then((DataSnapshot snap) {
      var KEYS = snap.value.keys;
      var DATA = snap.value;

      postsList.clear();
      for (var indivisualKey in KEYS) {
        Posts posts = Posts(
          DATA[indivisualKey]['image'],
          DATA[indivisualKey]['description'],
          DATA[indivisualKey]['date'],
          DATA[indivisualKey]['time'],
        );

        postsList.add(posts);
      }
      setState(() {
        print('Length:$postsList.length');
      });
    });
  }

  void _logoutUser() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print("Error= " + e.toString());
    }
  }

  Widget PostsUI(String image, String description, String date, String time) {
    return Card(
      elevation: 10,
      margin: EdgeInsets.all(15),
      child: Container(
        padding: EdgeInsets.all(14),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  date,
                  style: Theme.of(context).textTheme.subtitle,
                  textAlign: TextAlign.center,
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.subtitle,
                  textAlign: TextAlign.center,
                )
              ],
            ),
            SizedBox(height: 10),
            Image.network(image, fit: BoxFit.fill),
            SizedBox(height: 10),
            Text(
              description,
              style: Theme.of(context).textTheme.subhead,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NGO"),
      ),
      body: Container(
        child: postsList.length == 0
            ? Center(child: Text("No Posts to show"))
            : ListView.builder(
              itemCount: postsList.length,
              itemBuilder: (_,index){
                return PostsUI(postsList[index].image,postsList[index].description,postsList[index].date,postsList[index].time,);
              }
              ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.pink,
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.local_car_wash),
                iconSize: 50,
                color: Colors.white,
                onPressed: _logoutUser,
              ),
              IconButton(
                icon: Icon(Icons.add_a_photo),
                iconSize: 50,
                color: Colors.white,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UploadPhotoPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
