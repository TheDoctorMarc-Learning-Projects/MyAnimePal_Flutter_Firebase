import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myanimepal/statuses.dart';
import 'package:search_widget/search_widget.dart';
import 'DescriptionPage.dart';
import 'PersonalPage.dart';

class FirstPage extends StatefulWidget {
  FirebaseUser user;
  List<DocumentSnapshot> animeData, mangaData, aniMangaData;
  FirstPage(
      {@required this.user,
      @required this.animeData,
      @required this.mangaData}) {
    aniMangaData = animeData + mangaData;
  }

  @override
  FirstPageState createState() => FirstPageState();
}

class FirstPageState extends State<FirstPage> {
  DocumentSnapshot selectedItem;
  bool animes = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          title: Text(
            "MyAnimePal", // TODO: Show this in the user list, not here
            style: TextStyle(color: Colors.black, fontSize: 15),
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[
            Image.network(
                "https://firebasestorage.googleapis.com/v0/b/myanimepal.appspot.com/o/MyAnimePalLogo.png?alt=media&token=57926b6e-1808-43c8-9d99-e4b5572ef93e")
          ],
        ),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              searchBar(),
              SizedBox(height: 10),
              toggleAniMangaViewButton(),
              SizedBox(height: 10),
              (animes) ? animangaList("animes") : animangaList("mangas"),
            ]));
  }

  searchBar() {
    return SearchWidget<DocumentSnapshot>(
        dataList: widget.aniMangaData,
        listContainerHeight: MediaQuery.of(context).size.height / 4,
        queryBuilder: (query, list) {
          return list
              .where((item) =>
                  item.documentID.toLowerCase().contains(query.toLowerCase()))
              .toList();
        },
        popupListItemBuilder: (item) {
          return Container(
              padding: const EdgeInsets.all(12),
              child: Text(
                item.documentID,
                style: const TextStyle(fontSize: 16),
              ));
        },
        selectedItemBuilder: (item, deleteSelectedItem) {
          return Container(
              padding: const EdgeInsets.all(12),
              child: Text(
                item.documentID,
                style: const TextStyle(fontSize: 16),
              ));
        },

        // TODO: go to the anime specific page when clicked
        onItemSelected: (item) {
          setState(() {
            selectedItem = item;
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    DescriptionPage(user: widget.user, aniManga: item)));
          });
        });
  }

  toggleAniMangaViewButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 70.0,
          width: 70.0,
          child: FittedBox(
            child: FloatingActionButton(
              heroTag: "btn1",
              splashColor: Colors.cyan,
              child: Text(
                "Anime/Manga",
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                setState(() {
                  animes = !animes;
                });
              },
            ),
          ),
        ),
        SizedBox(
          width: 16,
        ),
        Container(
          height: 70.0,
          width: 70.0,
          child: FittedBox(
            child: FloatingActionButton(
              backgroundColor: Colors.lightBlue[900],
              heroTag: "btn2",
              splashColor: Colors.cyan,
              child: Text(
                "Personal Page",
                style: TextStyle(
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                setState(() {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PersonalPage(
                      user: widget.user,
                      animeData: widget.animeData,
                      mangaData: widget.mangaData,
                    ),
                  ));
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  animangaList(String list) {
    return StreamBuilder(
      stream: Firestore.instance.collection(list).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return Flexible(
          // TODO: this is just a test. display only X ammunt of animes and mangas,
          // separe them, add a button to see the  anime/ manga page
          child: ListView.builder(
            itemCount: (list == "animes")
                ? widget.animeData.length
                : widget.mangaData.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = (list == "animes")
                  ? widget.animeData[index]
                  : widget.mangaData[index];
              Map<String, dynamic> data = doc.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 40),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 32, right: 32, bottom: 16),
                    child: InkWell(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(data["ImagePath"]),
                          ),
                        ),
                      ),
                      onDoubleTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => DescriptionPage(
                                user: widget.user, aniManga: doc)));
                        //Open the second page with this meal
                      },
                    ),
                  ),
                  Center(
                    child: Text(
                      doc.documentID,
                      textScaleFactor: 2,
                    ),
                  ),
                  ListTile(
                    leading: Text(
                      "Genre: " + data["Genre"].toString(),
                      textScaleFactor: 1.3,
                      textAlign: TextAlign.center,
                    ),
                    trailing: Text(
                      "Mean Score: " + data["Mean Score"].toString(),
                      textScaleFactor: 1.3,
                    ),
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }
}