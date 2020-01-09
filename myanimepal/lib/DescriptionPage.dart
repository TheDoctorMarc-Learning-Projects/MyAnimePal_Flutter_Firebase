import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DescriptionPage extends StatefulWidget {
  FirebaseUser user;
  DocumentSnapshot aniManga;
  DescriptionPage({@required this.user, @required this.aniManga});

  @override
  DescriptionPageState createState() => DescriptionPageState();
}

class DescriptionPageState extends State<DescriptionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
      title: Text(
        widget.aniManga.documentID,
        style: TextStyle(color: Colors.black, fontSize: 15),
      ),
      backgroundColor: Colors.white,
      actions: <Widget>[
        Image.network(
            "https://firebasestorage.googleapis.com/v0/b/myanimepal.appspot.com/o/MyAnimePalLogo.png?alt=media&token=57926b6e-1808-43c8-9d99-e4b5572ef93e")
      ],
    ));
  }
}
