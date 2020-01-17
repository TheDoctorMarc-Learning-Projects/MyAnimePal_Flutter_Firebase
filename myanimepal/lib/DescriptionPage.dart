import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myanimepal/statuses.dart';
import 'statuses.dart';

class DescriptionPage extends StatefulWidget {
  FirebaseUser user;
  DocumentSnapshot aniManga;
  List<DocumentSnapshot> reviews;
  List<int> reviewScores;
  List<String> usersProfileURLS;
  bool isAnime, userHasIt;
  String status = "Not Initialized", profileURL = "Not Initialized";
  int episodes = 0, score = 0, totalScoreEntries = 0, totalScore = 0;
  double meanScore = 0;
  DescriptionPage({@required this.user, @required this.aniManga}) {
    reviews = List<DocumentSnapshot>();
    reviewScores = List<int>();
    usersProfileURLS = List<String>();
    isAnime = isAnimeFromPath(aniManga.reference.path.toString());
  }

  @override
  DescriptionPageState createState() => DescriptionPageState();
}

class DescriptionPageState extends State<DescriptionPage> {
  TextEditingController watchedController, scoreController;
  bool addingReview = false;

  setup() async {
    await setupStatus();
    await loadUserScores();
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

    // ...And profile images!!
    loadUserProfileURLs(widget.reviews);

    // Gather Data
    var userDoc = await Firestore.instance
        .collection('users')
        .document(widget.user.displayName)
        .get();
    widget.profileURL = userDoc.data['profileURL'].toString();

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

    if (!mounted) return;
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
            if (!mounted) return;
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
            if (!mounted) return;
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
                  if (!mounted) return;
                  setState(() {
                    int maxValue = int.parse((widget.isAnime)
                        ? widget.aniManga.data["Episodes"].toString()
                        : widget.aniManga.data["Chapters"].toString());
                    if (int.parse(value) > maxValue) {
                      value = maxValue.toString();
                      //  watchedController.text = value;
                    }
                    setUserValue((widget.isAnime) ? 'Watched' : 'Readed',
                        int.parse(value));
                  });
                },
              ),
            ),
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
                if (!mounted) return;
                setState(() {
                  setUserValue("Status", value);
                });
              },
            ),
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
                  if (!mounted) return;
                  setState(() {
                    if (int.parse(value) > 10) {
                      value = '10';
                      //      scoreController.text = value;
                    }
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
            height: MediaQuery.of(context).size.width * 0.8,
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
          SizedBox(height: 10),
          (addingReview) ? addReviewWorkflow() : addReviewButton(),
          SizedBox(height: 10),
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

    if (score > 10) {
      score = 10;
    }
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

  reviews() {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.reviews.length,
        itemBuilder: (context, index) {
          var reviewDocument = widget.reviews[index];
          return Column(
            children: <Widget>[
              SizedBox(height: 20),
              ClipRRect(
                  borderRadius: BorderRadius.circular(40.0),
                  child: Container(
                      padding: EdgeInsets.all(20.0),
                      decoration: BoxDecoration(color: Colors.blueGrey.shade50),
                      child: Column(children: <Widget>[
                        ListTile(
                          leading: Image.network(widget.usersProfileURLS[index],
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: MediaQuery.of(context).size.width * 0.3),
                          trailing: Text(
                              "Score: " +
                                  ((widget.reviewScores.isEmpty)
                                      ? '-'
                                      : widget.reviewScores[index].toString()),
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          title: Text(reviewDocument.documentID,
                              textScaleFactor: 0.8,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(height: 5),
                        Text(
                          reviewDocument.data['Body'],
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(height: 10),
                        (reviewDocument.documentID == widget.user.displayName)
                            ? deleteReviewButton()
                            : Container()
                      ])))
            ],
          );
        });
  }

  addReviewButton() {
    return FloatingActionButton(
      child: Text(
        'Add Review',
        textAlign: TextAlign.center,
        textScaleFactor: 0.8,
      ),
      onPressed: () {
        if (!mounted) return;
        setState(() {
          setupStatus();
          addingReview = true;
        });
      },
    );
  }

  deleteReviewButton() {
    return RaisedButton(
      color: Colors.red.shade100,
      child: Text(
        'Delete',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        if (!mounted) return;
        setState(() {
          deleteReview();
          setupStatus();
        });
      },
    );
  }

  addReviewWorkflow() {
    return TextField(
      onSubmitted: (value) {
        setState(() {
          setupStatus();
          addReview(value);
          addingReview = false;
        });
      },
    );
  }

  void addReview(String text) async {
    await Firestore.instance
        .collection((widget.isAnime) ? 'animes' : 'mangas')
        .document(widget.aniManga.documentID)
        .collection('reviews')
        .document(widget.user.displayName)
        .setData({'Body': text});
  }

  void deleteReview() async {
    await Firestore.instance.runTransaction((Transaction myTransaction) async {
      await myTransaction.delete(Firestore.instance
          .collection((widget.isAnime) ? 'animes' : 'mangas')
          .document(widget.aniManga.documentID)
          .collection('reviews')
          .document(widget.user.displayName));
    });
  }

  loadUserScores() async // must look at each review and 1) retrieve the user then 2) search for the animanga score
  {
    for (int i = 0; i < widget.reviews.length; ++i) {
      var aniManga = await Firestore.instance
          .collection('users')
          .document(widget.reviews[i].documentID)
          .collection((widget.isAnime) ? 'animes' : 'mangas')
          .document(widget.aniManga.documentID)
          .get();

      widget.reviewScores.add(int.parse(aniManga.data["Score"].toString()));
    }

    if (!mounted) return;
    setState(() {});
  }

  void loadUserProfileURLs(List<DocumentSnapshot> reviews) async {
    for (int i = 0; i < reviews.length; ++i) {
      var userDoc = await Firestore.instance
          .collection('users')
          .document(reviews[i].documentID)
          .get();
      widget.usersProfileURLS.add(userDoc.data['profileURL'].toString());
    }
  }
}
