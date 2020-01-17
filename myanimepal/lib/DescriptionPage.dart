import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myanimepal/statuses.dart';
import 'statuses.dart';

class DescriptionPage extends StatefulWidget {
  FirebaseUser user;
  DocumentSnapshot aniManga;
  List<DocumentSnapshot> reviews;
  bool isAnime, userHasIt;
  String status = "Not Initialized";
  int episodes = 0, score = 0, totalScoreEntries = 0, totalScore = 0;
  double meanScore = 0;
  DescriptionPage({@required this.user, @required this.aniManga}) {
    reviews = List<DocumentSnapshot>();
    isAnime = isAnimeFromPath(aniManga.reference.path.toString());
  }

  @override
  DescriptionPageState createState() => DescriptionPageState();
}

class DescriptionPageState extends State<DescriptionPage> {
  TextEditingController watchedController, scoreController;

  setup() async {
    await setupStatus();
    watchedController =
        new TextEditingController(text: widget.episodes.toString());
    scoreController = new TextEditingController(text: widget.score.toString());
  }

  setupStatus() async {
    // Reload widget's aniManga!!
    var docRef = Firestore.instance
        .collection((widget.isAnime) ? 'animes' : 'mangas')
        .document(widget.aniManga.documentID);
    widget.aniManga = await docRef.get();

    // Also reviews for easy access!!
    var reviewDocs =
        await widget.aniManga.reference.collection('reviews').getDocuments();
    widget.reviews = reviewDocs.documents;

    // Gather Data
    widget.status = await getAniMangaUserValue(widget.user.displayName,
        widget.aniManga.documentID, widget.isAnime, "Status");
    widget.episodes = await getAniMangaUserValueC(
        widget.user.displayName,
        widget.aniManga.documentID,
        widget.isAnime,
        (widget.isAnime) ? "Watched" : "Readed");
    widget.score = await getAniMangaUserValueC(widget.user.displayName,
        widget.aniManga.documentID, widget.isAnime, "Score");

    widget.totalScore = await getAniMangaValueC(
        widget.aniManga.documentID, widget.isAnime, "Total Score");
    widget.totalScoreEntries = await getAniMangaValueC(
        widget.aniManga.documentID, widget.isAnime, "Total Score Entries");

    var stringVal = await getAniMangaValue(
        widget.aniManga.documentID, widget.isAnime, "Mean Score");
    widget.meanScore = double.parse(stringVal);
    setState(() {});
  }

  @override
  void initState() {
    setup();
    super.initState();
  }

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

  deleteAniMangaWorkflow() {
    return Container(
        height: 70.0,
        width: 70.0,
        child: FittedBox(
            child: FloatingActionButton(
          splashColor: Colors.cyan,
          child: Text(
            "Remove from List",
            textAlign: TextAlign.center,
            textScaleFactor: 0.7,
          ),
          onPressed: () {
            setState(() {
              deleteFromUser();
            });
          },
        )));
  }

  editAniMangaWorkflow() {
    return Column(
      children: <Widget>[
        deleteAniMangaWorkflow(),
        Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.25,
              child: TextField(
                controller: watchedController,
                decoration: InputDecoration(
                    hintText: "Total: " +
                        ((widget.isAnime)
                            ? widget.aniManga.data["Episodes"].toString()
                            : widget.aniManga.data["Chapters"].toString()),
                    labelText: (widget.isAnime) ? 'Watched' : 'Readed'),
                keyboardType: TextInputType.number,
                onSubmitted: (value) {
                  setState(() {
                    setUserValue((widget.isAnime) ? 'Watched' : 'Readed',
                        int.parse(value));
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
                controller: scoreController,
                decoration: InputDecoration(
                    hintText: "1-10",
                    labelText:
                        "Score"), // TODO: update this in firebase -> do not accept 0 score, only 1-10 ints
                keyboardType: TextInputType.number,
                onSubmitted: (value) {
                  setState(() {
                    setScore(int.parse(value));
                  });
                },
              ),
            )
          ],
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
              Text("Mean Score: " + getScoreString(widget.meanScore).toString(),
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
          SizedBox(height: 30),
          Text('Reviews', textScaleFactor: 2),
          reviews(),
        ],
      )),
    );
  }

  Future<bool> setUserValue(String valueName, dynamic value) async {
    await setAniMangaUserValue(widget.user.displayName,
        widget.aniManga.documentID, widget.isAnime, valueName, value);

    // Refresh data
    await setupStatus();
    return true;
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
      ((widget.isAnime) ? 'Watched' : 'Readed'): 0,
      'Genre': widget.aniManga.data['Genre'],
      'ImagePath': widget.aniManga.data['ImagePath'],
    });

    // Refresh data
    await setupStatus();
  }

  void deleteFromUser() async {
    await Firestore.instance.runTransaction((Transaction myTransaction) async {
      await myTransaction.delete(Firestore.instance
          .collection('users')
          .document(widget.user.displayName)
          .collection((widget.isAnime) ? 'animes' : 'mangas')
          .document(widget.aniManga.documentID));
    });

    // Refresh data
    await setupStatus();
  }

  void setScore(int score) async {
    int prevScore = widget.score;
    await setUserValue("Score", score);

    // Compute mean score
    computeMeanScore(widget.score - prevScore, prevScore != 0);
  }

  // Diff example: if the score was 4 and now its 8, diff is +4
  void computeMeanScore(int diff, bool prevScore) async {
    // If there wasn't a score, add to the score entry count
    if (prevScore == false) {
      await setAniMangaValue(
          widget.aniManga.documentID,
          widget.isAnime,
          "Total Score Entries",
          widget.aniManga.data["Total Score Entries"] + 1);
    }

    // If there was a score and now its 0, remove to the score entry count
    if (widget.score == 0 && prevScore == true) {
      await setAniMangaValue(
          widget.aniManga.documentID,
          widget.isAnime,
          "Total Score Entries",
          widget.aniManga.data["Total Score Entries"] - 1);
    }

    // Update the total score
    int totalScore = widget.aniManga.data["Total Score"];
    totalScore += diff;
    await setAniMangaValue(
        widget.aniManga.documentID, widget.isAnime, "Total Score", totalScore);

    // Refresh data before calculating the mean score!!
    await setupStatus();

    // Calculate the mean score dividing total score by total score entries
    double meanScore = (widget.aniManga.data["Total Score"] as num) /
        (widget.aniManga.data["Total Score Entries"] as num);
    await setAniMangaValue(
        widget.aniManga.documentID, widget.isAnime, "Mean Score", meanScore);

    // Refresh data
    await setupStatus();
  }

  reviews() { // TODO: if my review, button to delete it (one user review per aniManga)
    return Container(
        width: MediaQuery.of(context).size.width,
        height: ((20 + 500) * widget.reviews.length).toDouble(), // meaning-> 20 spacing + 200 container 
        child: ListView.builder(
            itemCount: widget.reviews.length,
            itemBuilder: (context, index) {
              var reviewDocument = widget.reviews[index];
              return Column(
                children: <Widget>[
                  SizedBox(height: 20),
                  Container(
                      padding: EdgeInsets.all(20.0),
                      height: 500,
                      decoration: BoxDecoration(color: Colors.blueGrey.shade50),
                      child: Column(children: <Widget>[
                        Text(reviewDocument.documentID,
                            textScaleFactor: 1.2,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Text(
                          reviewDocument.data['Body'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ]))
                ],
              );
            }));
  }
}
