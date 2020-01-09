import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'statuses.dart';

class DescriptionPage extends StatefulWidget { // TODO: If the animanga is not in the user's list, button to add it
  FirebaseUser user;
  DocumentSnapshot aniManga;
  bool isAnime;
  DescriptionPage({@required this.user, @required this.aniManga}) {
    String path = aniManga.reference.path.toString();
    String discriminator = path.substring(0, path.indexOf("/"));
    isAnime = (discriminator == 'animes');
  }

  @override
  DescriptionPageState createState() => DescriptionPageState();
}

class DescriptionPageState extends State<DescriptionPage> {
  String status = "Test";// TODO: Get anime/manga status from firebase (the user can have it, or not)

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
        ),
        body: infoWidget());
  }

  infoWidget() {
    return Container(
      padding: const EdgeInsets.all(35.0),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(widget.aniManga.data["ImagePath"]),
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.25,
                child: TextField(
                  decoration: InputDecoration(
                      hintText: "Total: " +
                          ((widget.isAnime)
                              ? widget.aniManga.data["Episodes"].toString()
                              : widget.aniManga.data["Chapters"].toString()),
                      labelText: (widget.isAnime)
                          ? 'Watched'
                          : 'Readed'), // TODO: update this in firebase
                  keyboardType: TextInputType.number,
                ),
              ),
            /*  Container(
                width: MediaQuery.of(context).size.width * 0.2,
                child: */DropdownButton(
                  hint: Text(status),
                  value: null,
                  items: ((widget.isAnime) ? animeStatuses : mangaStatuses)
                      .map((String item) {
                    return DropdownMenuItem
                    (
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),

                  onChanged: (String value)
                  {
                    setState(() {
                      status = value; 
                      // TODO: update in firebase
                    });
                  },
                ),
            /*  ),*/
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                child: TextField(
                  decoration: InputDecoration(
                      hintText: "1-10",
                      labelText: "Score"), // TODO: update this in firebase
                  keyboardType: TextInputType.number,
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          Center(
            child: Text(
              widget.aniManga.data["Description"].toString(),
              // textScaleFactor: 2,
            ),
          ),
        ],
      )),
    );
  }
}
