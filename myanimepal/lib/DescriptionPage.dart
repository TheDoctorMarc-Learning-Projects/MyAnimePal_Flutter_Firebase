import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myanimepal/statuses.dart';
import 'statuses.dart';

class DescriptionPage extends StatefulWidget {
  FirebaseUser user;
  DocumentSnapshot aniManga;
  bool isAnime, userHasIt;
  String status = "Not Initialized";
  int episodes = 0, score = 0;
  DescriptionPage({@required this.user, @required this.aniManga}) {
    isAnime = isAnimeFromPath(aniManga.reference.path.toString());
    setupStatus();
  }

  setupStatus() async {
    status = await getAniMangaUserValue(
        user.displayName, aniManga.documentID, isAnime, "Status");
    episodes = await getAniMangaUserValueB(user.displayName,
        aniManga.documentID, isAnime, (isAnime) ? "Watched" : "Readed");
    score = await getAniMangaUserValueB(
        user.displayName, aniManga.documentID, isAnime, "Score");
  }

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
        ),
        body: infoWidget());
  }

  addAniMangaWorkflow() {
    return Container(
        height: 70.0,
        width: 70.0,
        child: FittedBox(
            child: FloatingActionButton(
          splashColor: Colors.cyan,
          child: Text(
            "Add to List",
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            setState(() {
              addAniMangaToUser();
            });
          },
        )));
  }

  editAniMangaWorkflow() {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.25,
          child: TextField(
            decoration: InputDecoration(
                hintText: "Total: " +
                    ((widget.isAnime)
                        ? widget.aniManga.data["Episodes"].toString()
                        : widget.aniManga.data["Chapters"].toString()),
                labelText: (widget.isAnime) ? 'Watched' : 'Readed'),
            keyboardType: TextInputType.number,
            onSubmitted: (value) {
              setState(() {
                setUserValue(
                    (widget.isAnime) ? 'Watched' : 'Readed', int.parse(value));
              });
            },
          ),
        ),
        /*  Container(
                width: MediaQuery.of(context).size.width * 0.2,
                child: */
        DropdownButton(
          hint: Text(widget.status),
          value: null,
          items: ((widget.isAnime) ? animeStatuses : mangaStatuses)
              .map((String item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (String value) {
            setState(() {
              setUserValue("Status", value);
            });
          },
        ),
        /*  ),*/
        Container(
          width: MediaQuery.of(context).size.width * 0.2,
          child: TextField(
            decoration: InputDecoration(
                hintText: "1-10",
                labelText:
                    "Score"), // TODO: update this in firebase -> do not accept 0 score, only 1-10 ints
            keyboardType: TextInputType.number,
            onSubmitted: (value) {
              setState(() {
                setUserValue("Score", int.parse(value));
              });
            },
          ),
        )
      ],
    );
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text("Genre: " + widget.aniManga.data["Genre"],
                  textScaleFactor: 1.3),
              Text(
                  "Mean Score: " +
                      getScoreString(widget.aniManga.data["Mean Score"])
                          .toString(),
                  textScaleFactor: 1.3)
            ],
          ),
          SizedBox(height: 10),
          ((widget.status == "Not Initialized")
              ? CircularProgressIndicator()
              : (((widget.status == "Not Found")
                  ? addAniMangaWorkflow()
                  : editAniMangaWorkflow()))),
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

  void setUserValue(String valueName, dynamic value) async {
    await setAniMangaUserValue(widget.user.displayName,
        widget.aniManga.documentID, widget.isAnime, valueName, value);

    // Refresh data
    await widget.setupStatus();
  }

  void addAniMangaToUser() async {
    // Add to firebase, with some default values
    await Firestore.instance
        .collection('users')
        .document(widget.user.displayName)
        .collection((widget.isAnime) ? 'animes' : 'mangas')
        .document(widget.aniManga.documentID)
        .setData({
      'Status': ((widget.isAnime) ? 'Plan To Watch' : 'Plan To Read'),
      'Score': 0,
      ((widget.isAnime) ? 'Watched' : 'Readed'): 0
    });

    // Refresh data
    await widget.setupStatus();
  }
}